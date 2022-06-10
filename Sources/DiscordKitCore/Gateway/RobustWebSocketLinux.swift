//
//  RobustWebSocketLinux.swift
//  DiscordAPI
//
//  Created by Andrew on 6/10/22.
//

// This is the Linux/Windows Replacement for RobustWebSocket
#if os(Linux) || os(Windows)

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import DiscordKitCommon
import Logging
import OpenCombineShim

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

    private let log = Logger(label: DiscordREST.subsystem) //Logger(subsystem: Bundle.main.bundleIdentifier ?? DiscordREST.subsystem, category: "RobustWebSocket")

    private let queue: OperationQueue

    private let timeout: TimeInterval, maxMsgSize: Int//,
                //reconnectInterval: (URLSessionWebSocketTask.CloseCode?, Int) -> TimeInterval?

    private var attempts = 0, reconnects = -1, awaitingHb: Int = 0,
                reconnectWhenOnlineAgain = false, explicitlyClosed = false,
                seq: Int? = nil, canResume = false, sessionID: String? = nil,
                pendingReconnect: Timer? = nil, connTimeout: Timer? = nil

    internal let token: String

    /// If the Gateway socket is connected
    ///
    /// This is set to `true` immediately after the socket connection
    /// is established, but the connection is most likely not ready.
    /// No events will be received until ``reachable`` is `true`.
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

    private func clearPendingReconnectIfNeeded() {
        if let reconnectTimer = pendingReconnect {
            reconnectTimer.invalidate()
            pendingReconnect = nil
        }
    }

    private func hasConnected() {
        if let timer = connTimeout {
            timer.invalidate()
            connTimeout = nil
        }
        reconnectWhenOnlineAgain = true
        attempts = 0
        connected = true
    }

    // MARK: - (Re)Connection
    private func reconnect() {
        // TODO
    }

    private func attachSockReceiveListener() {
        // TODO
    }
    private func connect() {
        // TODO
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
        case .heartbeatAck: awaitingHb -= 1
        case .hello:
            hasConnected()
            // Start heartbeating and send identify
            guard let d = decoded.d as? GatewayHello else { return }
            log.debug("Hello payload is: \(String(describing: d))")
            startHeartbeating(interval: Double(d.heartbeat_interval) / 1000.0)

            // Check if we're attempting to and can resume
            if canResume, let sessionID = sessionID, let seq = seq {
                log.info("Attempting resume")
                guard let resume = getResume(seq: seq, sessionID: sessionID)
                else { return }
                send(op: .resume, data: resume)
                return
            }
            log.debug("Identifying with gateway...")
            // Send identify
            seq = nil // Clear sequence #
            // isReconnecting = false // Resuming failed/not attempted
            guard let identify = getIdentify() else {
                log.debug("Token not in keychain")
                // authFailed = true
                // socket.disconnect(closeCode: 1000)
                close()//code: .normalClosure)
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
            close()//code: .normalClosure)
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
            case .resumed: sessionOpen = true
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
        maxMessageSize: Int
    ) {
        self.timeout = timeout
        self.token = token
        queue = OperationQueue()
        queue.qualityOfService = .utility
        //reconnectInterval = reconnectIntClosure
        maxMsgSize = maxMessageSize
        super.init()
        //session = URLSession(configuration: .default, delegate: self, delegateQueue: queue)
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
        self.init(token: token, timeout: TimeInterval(4), maxMessageSize: 1024*1024*10)
    }
}

// MARK: - Heartbeating
public extension RobustWebSocket {
    private func sendHeartbeat() {
        guard connected else { return }

        log.debug("Sending heartbeat, awaiting \(self.awaitingHb) ACKs")
        if awaitingHb > 1 {
            log.error("Too many pending heartbeats, closing socket")
            forceClose()
        }
        send(op: .heartbeat, data: GatewayHeartbeat(seq))
        awaitingHb += 1
    }

    private func startHeartbeating(interval: TimeInterval) {
        log.debug("Sending heartbeats every \(interval)s")
        awaitingHb = 0

        guard hbCancellable == nil else { return }

        // First heartbeat after interval * jitter where jitter is a value from 0-1
        // ~ Discord API docs
        DispatchQueue.main.asyncAfter(
            deadline: .now() + interval * Double.random(in: 0...1),
            qos: .utility,
            flags: .enforceQoS
        ) {
            // Only ever start 1 publishing timer
            self.sendHeartbeat()

            self.hbCancellable = Timer.publish(every: interval, tolerance: 2, on: .main, in: .common)
                .autoconnect()
                .sink { _ in self.sendHeartbeat() }
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
    func forceClose() {
        // TODO
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
    func close() {
        // TODO
    }

    /// Initiates a Gateway socket connection
    ///
    /// This will open a socket connection to the Gateway, and identify with it
    /// after the connection has been opened. This method is already called in
    /// the init method, and can be used to explicitly open the connection after
    /// it has been closed with `close()`. This method has no effect if the socket
    /// is already opened.
    func open() {
        // TODO
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
        // TODO
    }
}
#endif