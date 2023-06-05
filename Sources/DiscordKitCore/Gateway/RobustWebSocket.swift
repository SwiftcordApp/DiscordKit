//
//  RobustWebSocket.swift
//  DiscordAPI
//
//  Created by Vincent on 4/13/22.
//

import Foundation
import Logging

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(Reachability)
import Reachability
#endif

#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineFoundation
#endif

#if canImport(WebSocket)
import WebSocket
#endif

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
public class RobustWebSocket: NSObject {
    // swiftlint:disable:previous type_body_length

    /// An ``EventDispatch`` that is notified when an event dispatch
    /// is received from the Gateway
    public let onEvent = EventDispatch<GatewayIncoming.Data>()

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

    private var session: URLSession!, decompressor: DecompressionEngine!

    #if canImport(WebSocket)
    // We're using a 3rd party library on Linux because URLSessionWebSocketTask uses libcurl for its web socket communication.
    // However, libcurl's websocket implementation is currently experimental, and you must build and install curl from source to use it.
    // Because that is really bad UX, I elected to include an extremely hefty library to do our websocket stuff.
    // It absolutely kills compile times, and inflates binary size unneccessarlly.
    // When curl includes websocket support on its stable build, this dependency should be dropped in favor of URLSessionWebSocketTask.
    private var socket: WebSocket!
    #else
    private var socket: URLSessionWebSocketTask!
    #endif

    #if canImport(Reachability)
    // swiftlint:disable:next force_try
	private let reachability = try! Reachability()
    #endif

    // Logger instance
    private static let log = Logger(label: "RobustWebSocket", level: nil)

    // Operation queue for the URLSessionWebSocketTask
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        return queue
    }()

    private let timeout: TimeInterval, maxMsgSize: Int
    private var attempts = 0, reconnects = -1,
                explicitlyClosed = false,
                seq: Int?, canResume = false, sessionID: String?,
                pendingReconnect: Timer?, connTimeout: Timer?

    // MARK: - Configuration
    internal let token: String
    private let reconnectInterval: ReconnectDelayClosure

    /// The gateway close codes that signal a fatal error, and reconnection shouldn't be attempted
    private static let fatalCloseCodes = [4004] + Array(4010...4014)

    /// If the Gateway socket is connected
    ///
    /// This is set to `true` immediately after the socket connection
    /// is established, but the connection is most likely not ready.
    /// No events will be received until ``sessionOpen`` is `true`.
    private(set) final var connected = false {
        didSet { if !connected { sessionOpen = false }}
    }
    /// If the network is reachable (has network connectivity)
    ///
    /// ``onConnStateChange`` is notified when this changes.
    public final var reachable = false {
        didSet { onConnStateChange.notify(event: (sessionOpen, reachable)) }
    }
    /// If a session with the Gateway is established
    ///
    /// Set to `true` when the `READY` or `RESUMED` event is received.
    /// The socket is then considered "fully opened" once this is `true`.
    ///
    /// ``onConnStateChange`` is notified when this changes.
    public final var sessionOpen = false {
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
            Self.log.debug("Invalidating conn timeout", metadata: ["reason": "\(reason)"])
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
            Self.log.warning("Reconnection in progress, not reconnecting")
            return
        }
        guard !connected else {
            Self.log.warning("Already connected, not reconnecting")
            return
        }
        guard pendingReconnect == nil else {
            Self.log.warning("Already reconnecting, not reconnecting")
            return
        }
        guard !Self.fatalCloseCodes.contains(code?.rawValue ?? -1) else {
            Self.log.error("Gateway closed with fatal close code! Cannot reconnect")
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
            Self.log.info("Retrying connection", metadata: [
                "connectIn": "\(delay)",
                "attempt": "\(attempts)"
            ])
            DispatchQueue.main.async { [weak self] in
                self?.pendingReconnect = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                    Self.log.trace("Attempting reconnection now", metadata: ["attempt": "\(self?.attempts ?? 0)"])
                    self?.connect()
                }
            }
        } else {
            Self.log.warning("Not reconnecting: reconnectInterval callback returned nil")
        }
    }

    private func attachSockReceiveListener() {
        #if canImport(WebSocket)
        socket.onData = { message, _ in
            do {
                switch message {
                case .binary(let data):
                    if let decompressed = self.decompressor.push_data(data) {
                        try self.handleMessage(with: decompressed)
                    } else { Self.log.trace("Decompression did not return any result - compressed packet is not complete") }
                case .text(let str): try self.handleMessage(with: str)
                }
            } catch {
                 Self.log.warning("Error decoding message", metadata: ["error": "\(error.localizedDescription)"])
            }

        }

        socket.onError = {error, _ in
            Self.log.error("Receive error", metadata: ["error": "\(error.localizedDescription)"])
            self.forceClose()
        }

        #else

        Task {
            do {
                let message = try await socket.receive()
                do {
                    switch message {
                    case .data(let data):
                        if let decompressed = self.decompressor.push_data(data) {
                            try self.handleMessage(with: decompressed)
                        } else { Self.log.trace("Decompression did not return any result - compressed packet is not complete") }
                    case .string(let str): try self.handleMessage(with: str)
                    @unknown default: Self.log.warning("Unknown sock message case!")
                    }
                } catch {
                    Self.log.warning("Error decoding message", metadata: ["error": "\(error.localizedDescription)"])
                }
                self.attachSockReceiveListener()
            } catch {
                // If an error is encountered here, the connection is probably broken
                Self.log.error("Receive error", metadata: ["error": "\(error.localizedDescription)"])
                self.forceClose()
            }
        }
        #endif
    }

    private func connect() {
        guard !explicitlyClosed else { return }
        #if canImport(WebSocket)
        if socket?.isConnected == true {
            Self.log.warning("Closing existing socket connection")
            socket.disconnect()
        }
        #else
        if socket?.state == .running {
            Self.log.warning("Closing existing socket connection")
            socket.cancel()
        }
        #endif

        Self.log.info("[CONNECT]", metadata: [
            "ws": "\(DiscordKitConfig.default.gateway)",
            "version": "\(DiscordKitConfig.default.version)"
        ])
        pendingReconnect = nil

        #if canImport(WebSocket)
        socket = WebSocket()
        do {
            try socket.connect(to: DiscordKitConfig.default.gateway, headers: HTTPHeaders(dictionaryLiteral: ("User-Agent", DiscordKitConfig.default.userAgent)))
        } catch {
            Self.log.critical("Failed to connect to Gateway", metadata: ["Reason": "\(error.localizedDescription)"])
        }
        #else
        var gatewayReq = URLRequest(url: URL(string: DiscordKitConfig.default.gateway)!)
        // The difference in capitalisation is intentional
        gatewayReq.setValue(DiscordKitConfig.default.userAgent, forHTTPHeaderField: "User-Agent")
        socket!.maximumMessageSize = maxMsgSize
        #endif

        DispatchQueue.main.async { [weak self] in
            self?.connTimeout = Timer.scheduledTimer(withTimeInterval: self!.timeout, repeats: false) { [weak self] _ in
                self?.connTimeout = nil
                guard self?.connected != true else { return }
                #if canImport(Reachability)
                self?.reachability.stopNotifier()
                #endif
                Self.log.warning("Connection timed out", metadata: ["timeout": "\(self?.timeout ?? -1)"])
                self?.forceClose()
                Self.log.info("[RECONNECT] Preemptively attempting reconnection")
                self?.reconnect(code: nil)
            }
        }

        // Create new instance of decompressor
        // It's best to do it here, before resuming the task since sometimes, messages arrive before the compressor is initialised in the socket open handler.
        decompressor = DecompressionEngine()
        #if !canImport(WebSocket)
        socket!.resume()
        #endif

        #if canImport(Reachability)
        setupReachability()
        #endif
        attachSockReceiveListener()
    }

    // MARK: - Handlers
    // swiftlint:disable:next function_body_length
    private func handleMessage(with message: String) throws {
        guard let msgData = message.data(using: .utf8) else { return }
		let decoded = try DiscordREST.decoder.decode(GatewayIncoming.self, from: msgData)

        if let sequence = decoded.seq { seq = sequence }

        switch decoded.data {
        case .heartbeat:
            Self.log.debug("[HEARTBEAT] Sending expedited heartbeat as requested")
            send(.heartbeat, data: GatewayHeartbeat(seq))
        case .heartbeatAck: hbTimeout?.invalidate()
        case .hello(let hello):
            onHello()
            // Start heartbeating and send identify
            Self.log.info("[HELLO]", metadata: ["heartbeat_interval": "\(hello.heartbeat_interval)"])
            startHeartbeating(interval: Double(hello.heartbeat_interval) / 1000.0)

            // Check if we're attempting to and can resume
            if canResume, let sessionID = sessionID {
                Self.log.info("[RESUME] Resuming session", metadata: [
                    "sessionID": "\(sessionID)",
                    "seq": "\(self.seq ?? -1)"
                ])
                guard let resume = getResume(seq: seq, sessionID: sessionID)
                else { return }
                send(.resume, data: resume)
                return
            }
            Self.log.info("[IDENTIFY]", metadata: [
                "intents": "\(String(describing: DiscordKitConfig.default.intents))"
            ])
            // Send identify
            seq = nil // Clear sequence #
            guard let identify = getIdentify() else {
                Self.log.error("Could not get identify!")
                close(code: .normalClosure)
                onAuthFailure.notify()
                return
            }
            send(.identify, data: identify)
        case .invalidSession(canResume: let shouldResume):
            // Check if the session can be resumed
            if !shouldResume {
                Self.log.warning("[RECONNECT] Session is invalid, reconnecting without resuming")
                onSessionInvalid.notify()
                canResume = false
            }
            // Close the connection immediately and reconnect after 1-5s, as per Discord docs
            // Unfortunately Discord seems to reject the new identify no matter how long I
            // wait before sending it, so sometimes there will be 2 identify attempts before
            // the Gateway session is reestablished
            close(code: .normalClosure)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...5)) { [weak self] in
                Self.log.debug("[RECONNECT] Attempting to reconnect now")
                self?.open()
            }
            // attemptReconnect(resume: shouldResume)
        case .userReady(let ready):
            sessionID = ready.session_id
            canResume = true
            sessionOpen = true
        case .botReady(let ready):
            sessionID = ready.session_id
            canResume = true
            Self.log.info("[READY]", metadata: ["session": "\(ready.session_id)"])
            fallthrough
        case .resumed:
            sessionOpen = true
            // onEvent.notify(event: (type, decoded.data))
        case .reconnect:
            Self.log.warning("Gateway-requested reconnect: disconnecting and reconnecting immediately")
            forceClose()
        default: break
        }

        if decoded.opcode == .dispatchEvent {
            onEvent.notify(event: decoded.data)
        }
    }

    // MARK: - Initializers

    /// Inits an instance of ``RobustWebSocket`` with provided parameters or defaults
    ///
    /// Defaults are also provided for some parameters:
    /// - Connection timeout: 4s
    /// - Maximum socket payload size: 10MiB
    /// - Reconnection delay: `1.4^reconnectionTimes * 5 - 5`
    ///
    /// - Parameters:
    ///   - token: Discord token used for authentication
    ///   - timeout: The timeout before the connection attempt is aborted. The
    ///   socket will attempt to reconnect if connection times out.
    ///   - maxMessageSize: The maximum outgoing and incoming payload size for the socket.
    ///   - reconnectIntClosure: A closure called with `(closecode, reconnectionTimes)`
    ///   used to determine the reconnection delay.
    ///   - intents: Gateway intents to send in identify payload, should be set to nil for user accounts.
    public init(
        token: String,
        timeout: TimeInterval = 4,
        maxMessageSize: Int = 1024*1024*10, // 10MB
        reconnectIntClosure: @escaping ReconnectDelayClosure = { code, times in
            guard code != .policyViolation, code != .internalServerError, code?.rawValue != 4004 else { return nil }
            return min(pow(2, Double(times))*1.1 + 1.6, 60)
        }
    ) {
        self.timeout = timeout
        self.token = token
        reconnectInterval = reconnectIntClosure
        maxMsgSize = maxMessageSize
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: queue)
        connect()
    }

    // Gracefully disconnect when deinitialised
    deinit {
        close(code: .normalClosure)
    }
}

public typealias ReconnectDelayClosure = (URLSessionWebSocketTask.CloseCode?, Int) -> TimeInterval?

// MARK: - WebSocketTask delegate functions
extension RobustWebSocket: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Self.log.info("[CONNECTED]")
    }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        connected = false
        reconnect(code: closeCode)
        // didCloseConnection?()
        // didReceive(event: .disconnected("", UInt16(closeCode.rawValue)))
        Self.log.warning("[WS CLOSED] closeCode: \(closeCode.rawValue)")
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Self.log.error("[WS CLOSED] closed with error: \(error?.localizedDescription ?? "no error description")")
        connected = false
        reconnect(code: nil)
    }
}

// MARK: - Reachability
// Reachability does not support Linux, and does not seem vital for bots, so im not gonna bother
#if canImport(Reachability)
public extension RobustWebSocket {
    private func setupReachability() {
        reachability.whenReachable = { [weak self] _ in
            self?.reachable = true
            Self.log.debug("Reset backoff", metadata: ["reason": "connection is reachable"])
            self?.clearPendingReconnectIfNeeded()
            self?.attempts = 0
            self?.reconnect(code: nil)
        }
        reachability.whenUnreachable = { [weak self] _ in
            self?.reachable = false
            Self.log.warning("Connection unreachable, sending expedited heartbeat")
            self?.sendHeartbeat(4*4)
        }
        do { try reachability.startNotifier() } catch { Self.log.error("Starting reachability notifier failed!") }
    }
}
#endif

// MARK: - Heartbeating
public extension RobustWebSocket {
    // @objc errors on linux. Im not sure why it's used here, but i'll keep it.
    #if os(macOS)
    @objc private func sendHeartbeat(_ interval: TimeInterval) {
        guard connected else { return }
        if let hbTimeout = hbTimeout, hbTimeout.isValid {
            Self.log.warning("Skipping sending heartbeat", metadata: ["reason": "already waiting for one"])
            return
        }

        Self.log.debug("[HEARTBEAT] Sending heartbeat")
        send(.heartbeat, data: GatewayHeartbeat(seq))

        hbTimeout?.invalidate()
        DispatchQueue.main.async { [weak self] in
            self?.hbTimeout = Timer.scheduledTimer(withTimeInterval: interval * 0.25, repeats: false) { [weak self] _ in
                Self.log.warning("[HEARTBEAT] Force-closing connection", metadata: ["reason": "socket timed out"])
                self?.forceClose()
            }
        }
    }

    @objc private func startHeartbeating(interval: TimeInterval) {
        Self.log.debug("Start heartbeating", metadata: ["interval": "\(interval)"])

        if let hbCancellable = hbCancellable {
            Self.log.debug("Cancelling existing heartbeat timer")
            hbCancellable.cancel()
        }
        if let hbTimeout = hbTimeout {
            Self.log.debug("Cancelling existing hbTimeout timer")
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
    #else
    private func sendHeartbeat(_ interval: TimeInterval) {
        guard connected else { return }
        if let hbTimeout = hbTimeout, hbTimeout.isValid {
            Self.log.warning("Skipping sending heartbeat", metadata: ["reason": "already waiting for one"])
            return
        }

        Self.log.debug("[HEARTBEAT] Sending heartbeat")
        send(.heartbeat, data: GatewayHeartbeat(seq))

        hbTimeout?.invalidate()
        DispatchQueue.main.async { [weak self] in
            self?.hbTimeout = Timer.scheduledTimer(withTimeInterval: interval * 0.25, repeats: false) { [weak self] _ in
                Self.log.warning("[HEARTBEAT] Force-closing connection", metadata: ["reason": "socket timed out"])
                self?.forceClose()
            }
        }
    }

    private func startHeartbeating(interval: TimeInterval) {
        Self.log.debug("Start heartbeating", metadata: ["interval": "\(interval)"])

        if let hbCancellable = hbCancellable {
            Self.log.debug("Cancelling existing heartbeat timer")
            hbCancellable.cancel()
        }
        if let hbTimeout = hbTimeout {
            Self.log.debug("Cancelling existing hbTimeout timer")
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
    #endif
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
    final func forceClose(
        code: URLSessionWebSocketTask.CloseCode = .abnormalClosure,
        shouldReconnect: Bool = true
    ) {
        Self.log.warning("Forcibly closing connection")
        #if canImport(WebSocket)
        socket.disconnect()
        #else
        socket.cancel(with: code, reason: nil)
        #endif
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
    final func close(code: URLSessionWebSocketTask.CloseCode) {
        clearPendingReconnectIfNeeded()
        explicitlyClosed = true
        connected = false
        sessionID = nil
        seq = nil

        #if canImport(Reachability)
        reachability.stopNotifier()
        #endif

        #if canImport(WebSocket)
        socket.disconnect()
        #else
        socket.cancel(with: code, reason: nil)
        #endif
    }

    /// Initiates a Gateway socket connection
    ///
    /// This will open a socket connection to the Gateway, and identify with it
    /// after the connection has been opened. This method is already called in
    /// the init method, and can be used to explicitly open the connection after
    /// it has been closed with `close()`. This method has no effect if the socket
    /// is already opened.
    final func open() {
        #if canImport(WebSocket)
        guard !socket.isConnected else { return }
        #else
        guard socket.state != .running else { return }
        #endif

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
    final func send<T: OutgoingGatewayData>(
        _ opcode: GatewayOutgoingOpcodes,
        data: T,
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        guard connected else { return }

        let sendPayload = GatewayOutgoing(opcode: opcode, data: data, seq: seq)
        guard let encoded = try? DiscordREST.encoder.encode(sendPayload)
        else { return }

        Self.log.trace("Outgoing Payload", metadata: [
            "opcode": "\(opcode)",
            "data": "\((T.self == GatewayIdentify.self ? nil : data))", // Don't log tokens.
            "seq": "\(seq ?? -1)"
        ])

        #if canImport(WebSocket)
        socket.send(encoded)
        #else
        Task {
            do {
                try await socket.send(.data(encoded))
            } catch {
                if let completionHandler = completionHandler {
                    completionHandler(error)
                } else {
                    Self.log.error("Socket send error", metadata: ["error": "\(error.localizedDescription)"])
                }
            }
        }
        #endif
    }
}
