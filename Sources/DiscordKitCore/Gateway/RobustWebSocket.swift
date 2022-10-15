//
//  RobustWebSocket.swift
//  DiscordAPI
//
//  Created by Vincent on 4/13/22.
//

import Foundation
import DiscordKitCommon
import Reachability
import OSLog
import Combine

/// A robust WebSocket that handles resuming, reconnection and heartbeats
/// with the Discord Gateway
///
/// ``RobustWebSocket`` is more than just a WebSocket wrapper; It handles
/// everything from identifying with the Gateway to resuming a broken
/// connection. Reconnection is _very_ reliable, and is one of the main
/// considerations when writing this class.
///
/// The reconnection logic is inspired by
/// [robust-websocket](https://github.com/appuri/robust-websocket),
/// a very robust WebSocket wrapper for JavaScript.
///
/// > Use ``DiscordGateway`` instead of this class - it uses ``RobustWebSocket``
/// > underlyingly and is higher-level for more ease of use.
public class RobustWebSocket: NSObject, ObservableObject {
    /// An ``EventDispatch`` that is notified when an event dispatch
    /// is received from the Gateway
    public let onEvent = EventDispatch<(GatewayEvent, GatewayData?)>()

    /// An ``EventDispatch`` that is notified when the gateway closes
    /// with an auth failure, or when the token is not present
    /// in the keychain
    public let onAuthFailure = EventDispatch<Void>()

    /// An ``EventDispatch`` that is notified when the session opens/closes
    /// or reachability status changes. Event is notified with
    /// a (sessionOpen: Bool, reachable: Bool) tuple.
    public let onConnStateChange = EventDispatch<(Bool, Bool)>()

    /// An ``EventDispatch`` that is notified when the session cannot be
    /// resumed, most likely when the socket has been disconnected for too
    /// long and the session is invalidated. A fresh reconnection will
    /// be attempted if/when this happens.
    public let onSessionInvalid = EventDispatch<Void>()

    private var session: URLSession!, socket: URLSessionWebSocketTask!,
                decompressor: DecompressionEngine!
	private let reachability = try! Reachability(), log = Logger(subsystem: Bundle.main.bundleIdentifier ?? DiscordREST.subsystem, category: "RobustWebSocket")

    private let queue: OperationQueue

    private let timeout: TimeInterval, maxMsgSize: Int,
                reconnectInterval: (URLSessionWebSocketTask.CloseCode?, Int) -> TimeInterval?
    private var attempts = 0, reconnects = -1,
                explicitlyClosed = false,
                seq: Int? = nil, canResume = false, sessionID: String? = nil,
                pendingReconnect: Timer? = nil, connTimeout: Timer? = nil

    internal let token: String

    /// The gateway close codes that signal a fatal error, and reconnection shouldn't be attempted
    private static let fatalCloseCodes = [4004] + Array(4010...4014)

    /// If the Gateway socket is connected
    ///
    /// This is set to `true` immediately after the socket connection
    /// is established, but the connection is most likely not ready.
    /// No events will be received until ``sessionOpen`` is `true`.
    private(set) var connected = false {
        didSet { if !connected { sessionOpen = false }}
    }
    /// If the network is reachable (has network connectivity)
    ///
    /// ``onConnStateChange`` is notified when this changes.
    public var reachable = false {
        didSet { onConnStateChange.notify(event: (sessionOpen, reachable)) }
    }
    /// If a session with the Gateway is established
    ///
    /// Set to `true` when the `READY` or `RESUMED` event is received.
    /// The socket is then considered "fully opened" once this is `true`.
    ///
    /// ``onConnStateChange`` is notified when this changes.
    public var sessionOpen = false {
        didSet { onConnStateChange.notify(event: (sessionOpen, reachable)) }
    }

    fileprivate var hbCancellable: AnyCancellable?
    fileprivate var hbTimeout: Timer?

    private func clearPendingReconnectIfNeeded() {
        if let reconnectTimer = pendingReconnect {
            reconnectTimer.invalidate()
            pendingReconnect = nil
        }
    }

    private func invalidateConnTimeout(reason: String = "") {
        if let timer = connTimeout {
            log.debug("Invalidating conn timeout, reason: \(reason)")
            timer.invalidate()
            connTimeout = nil
        }
    }
    private func onHello() {
        invalidateConnTimeout(reason: "Hello payload received")
        attempts = 0
        connected = true
    }

    // MARK: - (Re)Connection
    private func reconnect(code: URLSessionWebSocketTask.CloseCode?) {
        guard !explicitlyClosed else { return }
        guard connTimeout == nil else {
            log.warning("Reconnection in progress, not reconnecting")
            return
        }
        guard !connected else {
            log.warning("Already connected, not reconnecting")
            return
        }
        guard pendingReconnect == nil else {
            log.warning("Already reconnecting, not reconnecting")
            return
        }
        guard !Self.fatalCloseCodes.contains(code?.rawValue ?? -1) else {
            log.error("Gateway closed with fatal close code! Cannot reconnect")
            onAuthFailure.notify()
            close(code: .normalClosure)
            return
        }
        invalidateConnTimeout(reason: "Attemping a reconnection")

        attempts += 1
        // Probably impossible to resume, update the listeners accordingly
        if attempts > 7 { onSessionInvalid.notify() }

        let delay = reconnectInterval(code, attempts)
        if let delay = delay {
            log.info("Retrying connection in \(delay)s, attempt \(String(self.attempts))")
            DispatchQueue.main.async { [weak self] in
                self?.pendingReconnect = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                    self?.connect()
                }
            }
        } else {
            log.warning("Not reconnecting: reconnectInterval callback returned nil")
        }
    }

    private func attachSockReceiveListener() {
        socket.receive { [weak self] result in
            // print(result)
            switch result {
            case .success(let message):
                do {
                    switch message {
                    case .data(let data):
                        if let decompressed = self?.decompressor.push_data(data) {
                            try self?.handleMessage(with: decompressed)
                        } else { self?.log.debug("Data has not ended yet") }
                    case .string(let str): try self?.handleMessage(with: str)
                    @unknown default: self?.log.warning("Unknown sock message case!")
                    }
                } catch {
                    self?.log.warning("Error decoding message: \(error.localizedDescription, privacy: .public)")
                }
                self?.attachSockReceiveListener()
            case .failure(let error):
                // If an error is encountered here, the connection is probably broken
                self?.log.error("Error when receiving: \(error.localizedDescription, privacy: .public)")
                self?.forceClose()
            }
        }
    }
    private func connect() {
        guard !explicitlyClosed else { return }
        if socket?.state == .running {
            log.warning("Closing existing socket connection")
            socket.cancel()
        }

        log.info("[CONNECT] \(GatewayConfig.default.gateway), version: \(GatewayConfig.default.version)")
        pendingReconnect = nil

        var gatewayReq = URLRequest(url: URL(string: GatewayConfig.default.gateway)!)
        // The difference in capitalisation is intentional
		gatewayReq.setValue(DiscordREST.userAgent, forHTTPHeaderField: "User-Agent")
        socket = session.webSocketTask(with: gatewayReq)
        socket!.maximumMessageSize = maxMsgSize

        DispatchQueue.main.async { [weak self] in
            self?.connTimeout = Timer.scheduledTimer(withTimeInterval: self!.timeout, repeats: false) { [weak self] _ in
                self?.connTimeout = nil
                guard self?.connected != true else { return }
                // reachability.stopNotifier()
                self?.log.warning("Connection timed out after \(self!.timeout)s")
                self?.forceClose()
                self?.log.info("[RECONNECT] Preemptively attempting reconnection")
                self?.reconnect(code: nil)
            }
        }

        // Create new instance of decompressor
        // It's best to do it here, before resuming the task since sometimes, messages arrive before the compressor is initialised in the socket open handler.
        decompressor = DecompressionEngine()
        socket!.resume()

        setupReachability()
        attachSockReceiveListener()
    }

    // MARK: - Handlers
    private func handleMessage(with message: String) throws {
        /*
         For debugging JSON decoding errors, how wonderful!
        do {
            try JSONDecoder().decode(GatewayIncoming.self, from: message.data(using: .utf8)!)
            // process data
        } catch let DecodingError.dataCorrupted(context) {
            print(context)
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("error: ", error)
        }*/

        guard let msgData = message.data(using: .utf8) else { return }
		let decoded = try DiscordREST.decoder().decode(GatewayIncoming.self, from: msgData)

        if let sequence = decoded.s { seq = sequence }

        switch decoded.op {
        case .heartbeat:
            log.debug("Sending expedited heartbeat as requested")
            send(op: .heartbeat, data: GatewayHeartbeat(seq))
        case .heartbeatAck: hbTimeout?.invalidate()
        case .hello:
            onHello()
            // Start heartbeating and send identify
            guard let d = decoded.d as? GatewayHello else { return }
            log.debug("[HELLO] heartbeat interval: \(d.heartbeat_interval, privacy: .public)")
            startHeartbeating(interval: Double(d.heartbeat_interval) / 1000.0)

            // Check if we're attempting to and can resume
            if canResume, let sessionID = sessionID {
                log.info("[RESUME] Resuming session \(sessionID, privacy: .public), seq: \(String(describing: self.seq), privacy: .public)")
                guard let resume = getResume(seq: seq, sessionID: sessionID)
                else { return }
                send(op: .resume, data: resume)
                return
            }
            log.debug("[IDENTIFY]")
            // Send identify
            seq = nil // Clear sequence #
            // isReconnecting = false // Resuming failed/not attempted
            guard let identify = getIdentify() else {
                log.debug("Token not in keychain")
                // authFailed = true
                // socket.disconnect(closeCode: 1000)
                close(code: .normalClosure)
                onAuthFailure.notify()
                return
            }
            send(op: .identify, data: identify)
        case .invalidSession:
            // Check if the session can be resumed
            let shouldResume = (decoded.primitiveData as? Bool) ?? false
            if !shouldResume {
                log.warning("Session is invalid, reconnecting without resuming")
                onSessionInvalid.notify()
                canResume = false
            }
            /// Close the connection immediately and reconnect after 1-5s, as per Discord docs
            /// Unfortunately Discord seems to reject the new identify no matter how long I
            /// wait before sending it, so sometimes there will be 2 identify attempts before
            /// the Gateway session is reestablished
            close(code: .normalClosure)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...5)) { [weak self] in
                self?.log.debug("Attempting to reconnect now")
                self?.open()
            }
            // attemptReconnect(resume: shouldResume)
        case .dispatchEvent:
            guard let type = decoded.t else {
                log.warning("Event has nil type")
                return
            }
            switch type {
            case .ready:
                guard let d = decoded.d as? ReadyEvt else { return }
                sessionID = d.session_id
                canResume = true
                fallthrough
            case .resumed:
                sessionOpen = true
            default: break
            }
            onEvent.notify(event: (type, decoded.d))
        case .reconnect:
            log.warning("Gateway-requested reconnect: disconnecting and reconnecting immediately")
            forceClose()
        }
    }

    // MARK: - Initializers

    /// Inits an instance of ``RobustWebSocket`` with provided parameters
    ///
    /// A convenience init is also provided that uses reasonable defaults instead.
    ///
    /// - Parameters:
    ///   - token: Discord token used for authentication
    ///   - timeout: The timeout before the connection attempt is aborted. The
    ///   socket will attempt to reconnect if connection times out.
    ///   - maxMessageSize: The maximum outgoing and incoming payload size for the socket.
    ///   - reconnectIntClosure: A closure called with `(closecode, reconnectionTimes)`
    ///   used to determine the reconnection delay.
    public init(
        token: String,
        timeout: TimeInterval,
        maxMessageSize: Int,
        reconnectIntClosure: @escaping (URLSessionWebSocketTask.CloseCode?, Int) -> TimeInterval?
    ) {
        self.timeout = timeout
        self.token = token
        queue = OperationQueue()
        queue.qualityOfService = .utility
        reconnectInterval = reconnectIntClosure
        maxMsgSize = maxMessageSize
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: queue)
        connect()
    }

    /// Inits an instance of ``RobustWebSocket`` with all parameters set
    /// to reasonable defaults.
    ///
    /// The following are the default parameters:
    /// - Connection timeout: 4s
    /// - Maximum socket payload size: 10MiB
    /// - Reconnection delay: `1.4^reconnectionTimes * 5 - 5`
    ///
    /// - Parameter token: Discord token used for authentication
    public convenience init(token: String) {
        self.init(token: token, timeout: TimeInterval(4), maxMessageSize: 1024*1024*10) { code, times in
            guard code != .policyViolation, code != .internalServerError, code?.rawValue != 4004 else { return nil }

            return min(pow(2, Double(times))*1.1 + 1.6, 60)
        }
    }
}

// MARK: - WebSocketTask delegate functions
extension RobustWebSocket: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        log.info("[CONNECTED]")
    }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        connected = false
        reconnect(code: closeCode)
        // didCloseConnection?()
        // didReceive(event: .disconnected("", UInt16(closeCode.rawValue)))
        log.warning("[WS CLOSED] closeCode: \(closeCode.rawValue)")
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        log.error("[WS CLOSED] closed with error: \(error?.localizedDescription ?? "no error description")")
        connected = false
        reconnect(code: nil)
    }
}

// MARK: - Reachability
public extension RobustWebSocket {
    private func setupReachability() {
        reachability.whenReachable = { [weak self] _ in
            self?.reachable = true
            self?.log.info("Reset backoff for reason: connection is reachable")
            self?.clearPendingReconnectIfNeeded()
            self?.attempts = 0
            self?.reconnect(code: nil)
        }
        reachability.whenUnreachable = { [weak self] _ in
            self?.reachable = false
            self?.log.info("Connection unreachable, sending expedited heartbeat")
            self?.sendHeartbeat(4*4)
        }
        do { try reachability.startNotifier() } catch { log.error("Starting reachability notifier failed!") }
    }
}

// MARK: - Heartbeating
public extension RobustWebSocket {
    @objc private func sendHeartbeat(_ interval: TimeInterval) {
        guard connected else { return }
        if let hbTimeout = hbTimeout, hbTimeout.isValid {
            log.warning("Skipping sending heartbeat - already waiting for one")
            return
        }

        log.debug("[HEARTBEAT] Sending heartbeat")
        send(op: .heartbeat, data: GatewayHeartbeat(seq))

        hbTimeout?.invalidate()
        DispatchQueue.main.async { [weak self] in
            self?.hbTimeout = Timer.scheduledTimer(withTimeInterval: interval * 0.25, repeats: false) { [weak self] _ in
                self?.log.warning("[HEARTBEAT] Force-closing connection, reason: socket timed out")
                self?.forceClose()
            }
        }
    }

    private func startHeartbeating(interval: TimeInterval) {
        log.debug("Sending heartbeats every \(interval)s")

        if let hbCancellable = hbCancellable {
            log.debug("Cancelling existing heartbeat timer")
            hbCancellable.cancel()
        }
        if let hbTimeout = hbTimeout {
            log.debug("Cancelling existing hbTimeout timer")
            hbTimeout.invalidate()
        }

        // First heartbeat after interval * jitter where jitter is a value from 0-1
        // ~ Discord API docs
        DispatchQueue.main.asyncAfter(
            deadline: .now() + interval * Double.random(in: 0...1),
            qos: .utility,
            flags: .enforceQoS
        ) {
            // Only ever start 1 publishing timer
            self.sendHeartbeat(interval)

            self.hbCancellable = Timer.publish(every: interval, tolerance: 2, on: .main, in: .common)
                .autoconnect()
                .sink { _ in self.sendHeartbeat(interval) }
        }
    }
}

// MARK: - Extension with public exposed methods
public extension RobustWebSocket {
    /// Forcefully close the Gateway socket connection
    ///
    /// This method should only be called as a last resort, for example
    /// when the connection has gone offline and the socket isn't responding.
    /// It immediately cancels the underlying URLSession, closing the socket.
    ///
    /// - Parameters:
    ///   - code: A custom code to close the socket with (defaults to `.abnormalClosure`)
    ///   - shouldReconnect: If reconnection should be attempted after the connection
    ///   is closed. Defaults to `true`
    func forceClose(
        code: URLSessionWebSocketTask.CloseCode = .abnormalClosure,
        shouldReconnect: Bool = true
    ) {
        log.warning("Forcibly closing connection")
        socket.cancel(with: code, reason: nil)
        connected = false
        /*if shouldReconnect {
            log.info("[RECONNECT] Preemptively attempting reconnection")
            reconnect(code: nil)
        } else {
            sessionID = nil
            seq = nil
        }*/
    }

    /// Explicitly close the Gateway socket connection
    ///
    /// When this method is called, the Gateway socket will gracefully close
    /// and will not reconnect. This can be used when the user signs out, for example.
    ///
    /// The socket connection cannot be reconnected after ``close(code:)`` is
    /// called. To reconnect, recreate the ``RobustWebSocket`` instance.
    ///
    /// - Parameter code: The close code to close the socket with.
    func close(code: URLSessionWebSocketTask.CloseCode) {
        clearPendingReconnectIfNeeded()
        explicitlyClosed = true
        connected = false
        sessionID = nil
        seq = nil
        reachability.stopNotifier()

        socket.cancel(with: code, reason: nil)
    }

    /// Initiates a Gateway socket connection
    ///
    /// This will open a socket connection to the Gateway, and identify with it
    /// after the connection has been opened. This method is already called in
    /// the init method, and can be used to explicitly open the connection after
    /// it has been closed with `close()`. This method has no effect if the socket
    /// is already opened.
    func open() {
        guard socket.state != .running else { return }
        clearPendingReconnectIfNeeded()
        explicitlyClosed = false

        connect()
    }

    /// Send a outgoing payload to the Gateway
    ///
    /// This method has no effect if the Gateway socket is not connected
    ///
    /// - Parameters:
    ///   - op: The opcode of the outgoing payload
    ///   - data: A outgoing data struct that conforms to OutgoingGatewayData
    ///   - completionHandler: Called when the send completes, with an error if any.
    ///   Not called if set to `nil` (defaults to `nil`)
    func send<T: OutgoingGatewayData>(
        op: GatewayOutgoingOpcodes,
        data: T,
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        guard connected else { return }

        let sendPayload = GatewayOutgoing(op: op, d: data, s: seq)
        guard let encoded = try? DiscordREST.encoder().encode(sendPayload)
        else { return }

        log.debug("Outgoing Payload: <\(String(describing: op), privacy: .public)> \(String(describing: data), privacy: .sensitive(mask: .hash)) [seq: \(String(describing: self.seq), privacy: .public)]")

        socket.send(.data(encoded), completionHandler: completionHandler ?? { [weak self] err in
            if let err = err { self?.log.error("Socket send error: \(err.localizedDescription, privacy: .public)") }
        })
    }
}
