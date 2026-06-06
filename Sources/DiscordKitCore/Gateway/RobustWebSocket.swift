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

#if canImport(WebSocket)
import WebSocket
#endif

/// A robust WebSocket that handles resuming, reconnection and heartbeats
/// with the Discord Gateway.
public class RobustWebSocket: NSObject {
    // swiftlint:disable:previous type_body_length

    /// An ``EventDispatch`` that is notified when an event dispatch
    /// is received from the Gateway.
    public let onEvent = EventDispatch<GatewayIncoming.Data>()

    /// An ``EventDispatch`` that is notified when the gateway closes
    /// with an auth failure, or when no connection info is available.
    public let onAuthFailure = EventDispatch<Void>()

    /// An ``EventDispatch`` that is notified when the session opens/closes
    /// or reachability status changes. Event is notified with
    /// a (sessionOpen: Bool, reachable: Bool) tuple.
    public let onConnStateChange = EventDispatch<(Bool, Bool)>()

    /// An ``EventDispatch`` that is notified when the saved session is
    /// no longer trusted and the next connection will identify fresh.
    public let onSessionInvalid = EventDispatch<Void>()

    private enum ConnectionState: String {
        case closed = "CLOSED"
        case willReconnect = "WILL_RECONNECT"
        case connecting = "CONNECTING"
        case identifying = "IDENTIFYING"
        case resuming = "RESUMING"
        case sessionEstablished = "SESSION_ESTABLISHED"
    }

    private struct GatewayBackoff {
        let minDelay: TimeInterval = 1
        let maxDelay: TimeInterval = 60
        var currentDelay: TimeInterval = 1
        var fails = 0

        mutating func succeed() {
            fails = 0
            currentDelay = minDelay
        }

        mutating func recordFail() {
            fails += 1
        }

        mutating func fail(minimumDelay: TimeInterval? = nil) -> TimeInterval {
            recordFail()
            let jitteredDelta = 2 * currentDelay * Double.random(in: 0..<1)
            currentDelay = min(currentDelay + jitteredDelta, maxDelay)
            return max(currentDelay, minimumDelay ?? 0)
        }
    }

    private static let log = Logger(label: "RobustWebSocket", level: nil)
    private static let helloTimeout: TimeInterval = 30
    private static let resumeFreshnessWindow: TimeInterval = 3 * 60
    private static let gatewayReconnectCloseCode = URLSessionWebSocketTask.CloseCode(rawValue: 4000)!
    private static let authFailureCloseCode = 4004

    private var session: URLSession!
    private var decompressor = DecompressionEngine()

    #if canImport(WebSocket)
    // We're using a 3rd party library on Linux because URLSessionWebSocketTask uses libcurl for its web socket communication.
    // However, libcurl's websocket implementation is currently experimental, and you must build and install curl from source to use it.
    // Because that is really bad UX, I elected to include an extremely hefty library to do our websocket stuff.
    // When curl includes websocket support on its stable build, this dependency should be dropped in favor of URLSessionWebSocketTask.
    private var socket: WebSocket?
    #else
    private var socket: URLSessionWebSocketTask?
    #endif

    #if canImport(Reachability)
    // swiftlint:disable:next force_try
    private let reachability = try! Reachability()
    private var reachabilityStarted = false
    #endif

    // Operation queue for the URLSessionWebSocketTask delegate callbacks.
    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private let maxMsgSize: Int
    private let reconnectInterval: ReconnectDelayClosure?
    let token: String
    private let lifecycleLock = NSRecursiveLock()

    private var state: ConnectionState = .closed {
        didSet {
            guard state != oldValue else { return }
            Self.log.debug("Gateway connection state changed", metadata: ["state": "\(state.rawValue)"])
        }
    }

    private var seq: Int? = 0
    private var sessionID: String?
    private var resumeGatewayURL: URL?
    private var gatewayBackoff = GatewayBackoff()
    private var nextReconnectIsImmediate = false

    private var pendingReconnect: Timer?
    private var reconnectGeneration = 0
    private var helloTimeoutTimer: Timer?
    private var initialHeartbeatTimer: Timer?
    private var heartbeatTimer: Timer?
    private var expeditedHeartbeatTimeout: Timer?

    private var heartbeatInterval: TimeInterval?
    private var heartbeatAck = true
    private var lastHeartbeatSentTime: Date?
    private var lastHeartbeatAckTime: Date?

    /// If the Gateway socket is connected.
    ///
    /// This is set to `true` after OP_HELLO is received, matching the old
    /// public behavior. No dispatches are considered usable until
    /// ``sessionOpen`` is `true`.
    private(set) final var connected = false {
        didSet { if !connected { sessionOpen = false } }
    }

    /// If the network is reachable (has network connectivity).
    ///
    /// ``onConnStateChange`` is notified when this changes.
    public final var reachable = false {
        didSet { onConnStateChange.notify(event: (sessionOpen, reachable)) }
    }

    /// If a session with the Gateway is established.
    ///
    /// Set to `true` when the `READY`, `READY_SUPPLEMENTAL`, or `RESUMED`
    /// event is received.
    ///
    /// ``onConnStateChange`` is notified when this changes.
    public final var sessionOpen = false {
        didSet { onConnStateChange.notify(event: (sessionOpen, reachable)) }
    }

    // MARK: - Initializers

    /// Inits an instance of ``RobustWebSocket`` with provided parameters or defaults.
    ///
    /// Defaults:
    /// - HELLO timeout: 30s, matching the official client.
    /// - Maximum socket payload size: 10MiB.
    /// - Reconnection delay: official-client jittered backoff, min 1s and max 60s.
    ///
    /// - Parameters:
    ///   - token: Discord token used for authentication.
    ///   - timeout: Deprecated. Kept for source compatibility; the gateway
    ///   lifecycle uses the official 30 second HELLO timeout.
    ///   - maxMessageSize: The maximum outgoing and incoming payload size for the socket.
    ///   - reconnectIntClosure: Optional custom reconnection delay. Leave nil
    ///   to use official-client backoff behavior.
    public init(
        token: String,
        timeout: TimeInterval = 30,
        maxMessageSize: Int = 1024*1024*10,
        reconnectIntClosure: ReconnectDelayClosure? = nil
    ) {
        _ = timeout
        self.token = token
        self.maxMsgSize = maxMessageSize
        self.reconnectInterval = reconnectIntClosure
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: queue)
    }

    deinit {
        close(code: .normalClosure)
    }
}

public typealias ReconnectDelayClosure = (URLSessionWebSocketTask.CloseCode?, Int) -> TimeInterval?

// MARK: - Connection lifecycle
private extension RobustWebSocket {
    func withLifecycleLock<T>(_ body: () throws -> T) rethrows -> T {
        lifecycleLock.lock()
        defer { lifecycleLock.unlock() }
        return try body()
    }

    func isCurrentSocket(_ expectedSocket: AnyObject) -> Bool {
        guard let currentSocket = currentSocketObject else { return false }
        return currentSocket === expectedSocket
    }

    var canSendLifecyclePayloads: Bool {
        switch state {
        case .identifying, .resuming, .sessionEstablished:
            return connected
        case .closed, .willReconnect, .connecting:
            return false
        }
    }

    var canSendEstablishedPayloads: Bool {
        connected && state == .sessionEstablished
    }

    var canResumeSession: Bool {
        guard sessionID != nil else { return false }
        guard let lastHeartbeatAckTime = lastHeartbeatAckTime else { return true }
        return Date().timeIntervalSince(lastHeartbeatAckTime) <= Self.resumeFreshnessWindow
    }

    func connect() {
        withLifecycleLock {
            guard state == .willReconnect else {
                Self.log.warning("Ignoring connect attempt outside WILL_RECONNECT", metadata: ["state": "\(state.rawValue)"])
                return
            }

            state = .connecting
            nextReconnectIsImmediate = false
            invalidatePendingReconnect()
            cleanupCurrentSocket(closeCode: nil, reason: nil)

            let connectionURL = gatewayURL()
            Self.log.info("[CONNECT]", metadata: [
                "version": "\(DiscordKitConfig.default.version)",
                "url": "\(connectionURL)"
            ])

            decompressor = DecompressionEngine()

            #if canImport(WebSocket)
            let webSocket = WebSocket()
            socket = webSocket
            do {
                try webSocket.connect(
                    url: connectionURL,
                    headers: HTTPHeaders(dictionaryLiteral: ("User-Agent", DiscordKitConfig.default.userAgent))
                )
            } catch {
                if handleClose(
                    wasClean: false,
                    closeCode: nil,
                    reason: "Failed to connect to Gateway",
                    sourceSocket: webSocket
                ) {
                    Self.log.critical("Failed to connect to Gateway", metadata: ["reason": "\(error.localizedDescription)"])
                }
                return
            }
            #else
            var gatewayReq = URLRequest(url: connectionURL)
            gatewayReq.setValue(DiscordKitConfig.default.userAgent, forHTTPHeaderField: "User-Agent")
            let webSocket = session.webSocketTask(with: gatewayReq)
            webSocket.maximumMessageSize = maxMsgSize
            socket = webSocket
            #endif

            scheduleHelloTimeout(for: webSocket)
            attachSockReceiveListener(for: webSocket)

            #if !canImport(WebSocket)
            webSocket.resume()
            #endif

            #if canImport(Reachability)
            setupReachability()
            #endif
        }
    }

    func gatewayURL() -> URL {
        let base = strippedTrailingSlash(
            resumeGatewayURL?.absoluteString ?? "wss://gateway.discord.gg"
        )
        let separator = base.contains("?") ? "&" : "?"
        let compression = DiscordKitConfig.default.streamCompression ? "&compress=zlib-stream" : ""
        return URL(
            string: "\(base)\(separator)v=\(DiscordKitConfig.default.version)&encoding=json\(compression)"
        )!
    }

    func strippedTrailingSlash(_ urlString: String) -> String {
        guard urlString.hasSuffix("/") else { return urlString }
        return String(urlString.dropLast())
    }

    func setResumeGatewayURL(_ url: URL) {
        resumeGatewayURL = URL(string: strippedTrailingSlash(url.absoluteString))
    }

    func scheduleHelloTimeout(for sourceSocket: AnyObject) {
        invalidateHelloTimeout(reason: "Scheduling new HELLO timeout")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.withLifecycleLock {
                guard self.state == .connecting, self.isCurrentSocket(sourceSocket) else { return }
                self.helloTimeoutTimer = Timer.scheduledTimer(withTimeInterval: Self.helloTimeout, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    let reason = "The connection timed out after \(Self.helloTimeout)s - did not receive OP_HELLO in time."
                    if self.handleClose(
                        wasClean: false,
                        closeCode: nil,
                        reason: reason,
                        sourceSocket: sourceSocket,
                        clearResumeGatewayURL: true
                    ) {
                        Self.log.warning("[HELLO TIMEOUT]", metadata: ["reason": "\(reason)"])
                    }
                }
            }
        }
    }

    func onHello(_ hello: GatewayHello, from sourceSocket: AnyObject) {
        invalidateHelloTimeout(reason: "Hello payload received")
        let interval = Double(hello.heartbeat_interval) / 1000.0
        guard interval > 0 else {
            handleClose(
                wasClean: false,
                closeCode: nil,
                reason: "Invalid Gateway heartbeat interval",
                sourceSocket: sourceSocket
            )
            return
        }

        connected = true
        heartbeatAck = true
        heartbeatInterval = interval

        Self.log.info("[HELLO]", metadata: ["heartbeat_interval": "\(hello.heartbeat_interval)"])
        startHeartbeating(interval: interval, for: sourceSocket)
        doResumeOrIdentify()
        updateLastHeartbeatAckTime()
    }

    func doResumeOrIdentify() {
        if canResumeSession, let sessionID {
            doResume(sessionID: sessionID)
        } else {
            doIdentify()
        }
    }

    func doResume(sessionID: String) {
        state = .resuming
        Self.log.info("[RESUME] Resuming session", metadata: [
            "sessionID": "\(sessionID)",
            "seq": "\(seq ?? -1)"
        ])
        sendGatewayPayload(.resume, data: getResume(seq: seq, sessionID: sessionID), requiresEstablished: false)
    }

    func doIdentify() {
        seq = 0
        sessionID = nil

        Self.log.info("[IDENTIFY]", metadata: [
            "intents": "\(String(describing: DiscordKitConfig.default.intents))"
        ])

        state = .identifying
        sendGatewayPayload(.identify, data: getIdentify(), requiresEstablished: false)
    }

    @discardableResult
    func handleClose(
        wasClean: Bool,
        closeCode: URLSessionWebSocketTask.CloseCode?,
        reason: String?,
        sourceSocket: AnyObject? = nil,
        clearResumeGatewayURL: Bool = false
    ) -> Bool {
        withLifecycleLock {
            guard state != .closed else { return false }

            let codeValue = closeCode?.rawValue ?? 0
            if let sourceSocket = sourceSocket {
                guard cleanupCurrentSocketIfCurrent(sourceSocket, closeCode: nil, reason: nil) else {
                    return false
                }
            } else {
                cleanupCurrentSocket(closeCode: nil, reason: nil)
            }

            if clearResumeGatewayURL {
                resumeGatewayURL = nil
            }

            if codeValue == Self.authFailureCloseCode {
                Self.log.warning("[WS CLOSED] Gateway auth failure", metadata: [
                    "clean": "\(wasClean)",
                    "code": "\(codeValue)",
                    "reason": "\(reason ?? "")"
                ])
                state = .closed
                resetSession(wasClean: wasClean, closeCode: closeCode, reason: reason)
                onAuthFailure.notify()
                return true
            }

            state = .willReconnect

            if nextReconnectIsImmediate {
                Self.log.info("[WS CLOSED] Reconnecting immediately", metadata: [
                    "clean": "\(wasClean)",
                    "code": "\(codeValue)",
                    "reason": "\(reason ?? "")"
                ])
                connect()
                return true
            }

            scheduleReconnect(closeCode: closeCode, reason: reason)
            return true
        }
    }

    func scheduleReconnect(
        closeCode: URLSessionWebSocketTask.CloseCode?,
        reason: String?
    ) {
        withLifecycleLock {
            guard state == .willReconnect else { return }
            guard pendingReconnect == nil else {
                Self.log.debug("Reconnect already scheduled; ignoring duplicate request")
                return
            }

            let delay: TimeInterval?
            if let reconnectInterval = reconnectInterval {
                gatewayBackoff.recordFail()
                delay = reconnectInterval(closeCode, gatewayBackoff.fails)
            } else {
                delay = gatewayBackoff.fail()
            }

            guard let delay = delay else {
                Self.log.warning("Not reconnecting: reconnectInterval callback returned nil")
                return
            }

            if gatewayBackoff.fails > 4 {
                Self.log.warning("[WS CLOSED] Backoff exceeded; resetting resumable session")
                resetSession(wasClean: false, closeCode: closeCode, reason: reason)
                onSessionInvalid.notify()
            }

            Self.log.info("[WS CLOSED] Retrying connection", metadata: [
                "retryIn": "\(delay)",
                "attempt": "\(gatewayBackoff.fails)",
                "code": "\(closeCode?.rawValue ?? 0)",
                "reason": "\(reason ?? "")"
            ])

            let generation = reconnectGeneration
            let installTimer = { [weak self] in
                guard let self = self else { return }
                self.withLifecycleLock {
                    guard generation == self.reconnectGeneration, self.state == .willReconnect else { return }
                    guard self.pendingReconnect == nil else {
                        Self.log.debug("Reconnect already scheduled; ignoring duplicate timer install")
                        return
                    }
                    self.pendingReconnect = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                        guard let self = self else { return }
                        self.withLifecycleLock {
                            guard generation == self.reconnectGeneration, self.state == .willReconnect else { return }
                            self.pendingReconnect = nil
                            self.connect()
                        }
                    }
                }
            }

            if Thread.isMainThread {
                installTimer()
            } else {
                DispatchQueue.main.async(execute: installTimer)
            }
        }
    }

    func handleGatewayReconnect(from sourceSocket: AnyObject) {
        withLifecycleLock {
            guard isCurrentSocket(sourceSocket) else { return }
            Self.log.warning("[RECONNECT] Gateway requested reconnect")
            cleanupCurrentSocket(closeCode: Self.gatewayReconnectCloseCode, reason: nil)
            state = .willReconnect
            connect()
        }
    }

    func handleDecompressionFailure(from sourceSocket: AnyObject) {
        if handleClose(
            wasClean: false,
            closeCode: nil,
            reason: "A decompression error occurred",
            sourceSocket: sourceSocket
        ) {
            Self.log.warning("[DECOMPRESSION ERROR]")
        }
    }

    func handleHeartbeatTimeout() {
        withLifecycleLock {
            guard state != .closed else { return }
            Self.log.warning("[ACK TIMEOUT] Heartbeat ACK timed out")
            cleanupCurrentSocket(closeCode: Self.gatewayReconnectCloseCode, reason: nil)
            state = .willReconnect
            scheduleReconnect(closeCode: Self.gatewayReconnectCloseCode, reason: "Heartbeat ACK timed out")
        }
    }

    func resetSession(
        wasClean: Bool,
        closeCode: URLSessionWebSocketTask.CloseCode?,
        reason: String?
    ) {
        Self.log.warning("[RESET] Clearing resumable gateway session", metadata: [
            "clean": "\(wasClean)",
            "code": "\(closeCode?.rawValue ?? 0)",
            "reason": "\(reason ?? "")"
        ])
        sessionID = nil
        seq = 0
        lastHeartbeatAckTime = nil
    }

    func resetBackoff(reason: String = "", closeIfNotEstablished: Bool = true) {
        withLifecycleLock {
            Self.log.debug("Resetting gateway backoff", metadata: ["reason": "\(reason)"])
            invalidatePendingReconnect()
            gatewayBackoff.succeed()
            nextReconnectIsImmediate = true

            if state == .willReconnect {
                connect()
            } else if closeIfNotEstablished, state != .sessionEstablished {
                handleClose(wasClean: true, closeCode: nil, reason: reason)
            }
        }
    }
}

// MARK: - Socket I/O
private extension RobustWebSocket {
    func attachSockReceiveListener(for sourceSocket: AnyObject) {
        #if canImport(WebSocket)
        guard let socket = sourceSocket as? WebSocket else { return }
        guard withLifecycleLock({ isCurrentSocket(socket) }) else { return }

        socket.onData = { [weak self] message, _ in
            guard let self = self else { return }
            do {
                let payload = self.withLifecycleLock { () -> String? in
                    guard self.isCurrentSocket(socket) else { return nil }
                    switch message {
                    case .binary(let data):
                        switch self.decompressor.pushGatewayData(data) {
                        case .waitingForMoreData:
                            Self.log.trace("Decompression did not return any result - compressed packet is not complete")
                            return nil
                        case .payload(let decompressed):
                            return decompressed
                        case .failure:
                            self.handleDecompressionFailure(from: socket)
                            return nil
                        }
                    case .text(let str):
                        return str
                    }
                }

                if let payload {
                    try self.handleMessage(with: payload, from: socket)
                }
            } catch {
                Self.log.warning("Error decoding message", metadata: ["error": "\(error.localizedDescription)"])
            }
        }

        socket.onError = { [weak self] error, _ in
            guard let self = self else { return }
            if self.handleClose(
                wasClean: false,
                closeCode: nil,
                reason: "An error with the websocket occurred",
                sourceSocket: socket,
                clearResumeGatewayURL: true
            ) {
                Self.log.error("Receive error", metadata: ["error": "\(error.localizedDescription)"])
            }
        }
        #else
        guard let socket = sourceSocket as? URLSessionWebSocketTask else { return }
        guard withLifecycleLock({ isCurrentSocket(socket) }) else { return }

        Task { [weak self, weak socket] in
            guard let self = self, let socket = socket else { return }
            do {
                let message = try await socket.receive()
                do {
                    let payload = self.withLifecycleLock { () -> String? in
                        guard self.isCurrentSocket(socket) else { return nil }
                        switch message {
                        case .data(let data):
                            switch self.decompressor.pushGatewayData(data) {
                            case .waitingForMoreData:
                                Self.log.trace("Decompression did not return any result - compressed packet is not complete")
                                return nil
                            case .payload(let decompressed):
                                return decompressed
                            case .failure:
                                self.handleDecompressionFailure(from: socket)
                                return nil
                            }
                        case .string(let str):
                            return str
                        @unknown default:
                            Self.log.warning("Unknown sock message case")
                            return nil
                        }
                    }

                    if let payload {
                        try self.handleMessage(with: payload, from: socket)
                    }
                } catch {
                    Self.log.warning("Error decoding message", metadata: ["error": "\(error)"])
                }

                if self.withLifecycleLock({ self.isCurrentSocket(socket) }) {
                    self.attachSockReceiveListener(for: socket)
                }
            } catch {
                if self.handleClose(
                    wasClean: false,
                    closeCode: nil,
                    reason: "An error with the websocket occurred",
                    sourceSocket: socket,
                    clearResumeGatewayURL: true
                ) {
                    Self.log.error("Receive error", metadata: ["error": "\(error.localizedDescription)"])
                }
            }
        }
        #endif
    }

    // swiftlint:disable:next function_body_length
    func handleMessage(with message: String, from sourceSocket: AnyObject) throws {
        guard let msgData = message.data(using: .utf8) else { return }
        let decoded = try DiscordREST.decoder.decode(GatewayIncoming.self, from: msgData)

        let eventToNotify = withLifecycleLock { () -> GatewayIncoming.Data? in
            guard isCurrentSocket(sourceSocket) else { return nil }

            if let sequence = decoded.seq {
                seq = sequence
            }

            switch decoded.data {
            case .heartbeat:
                Self.log.debug("[HEARTBEAT] Sending expedited heartbeat as requested")
                handleHeartbeatRequest(from: sourceSocket)
            case .heartbeatAck:
                handleHeartbeatAck()
            case .hello(let hello):
                onHello(hello, from: sourceSocket)
            case .invalidSession(canResume: let shouldResume):
                handleInvalidSession(canResume: shouldResume)
            case .userReady(let ready):
                handleReady(sessionID: ready.session_id, resumeGatewayURL: ready.resume_gateway_url)
            case .botReady(let ready):
                handleReady(sessionID: ready.session_id, resumeGatewayURL: ready.resume_gateway_url)
            case .readySupplemental:
                handleSessionEstablished(event: "READY_SUPPLEMENTAL")
            case .resumed:
                handleSessionEstablished(event: "RESUMED")
            case .reconnect:
                handleGatewayReconnect(from: sourceSocket)
            default:
                break
            }

            sendHeartbeatIfDue()
            return decoded.opcode == .dispatchEvent ? decoded.data : nil
        }

        if let eventToNotify = eventToNotify {
            onEvent.notify(event: eventToNotify)
        }
    }

    func handleReady(sessionID: String, resumeGatewayURL: URL) {
        self.sessionID = sessionID
        setResumeGatewayURL(resumeGatewayURL)
        handleSessionEstablished(event: "READY")
        Self.log.info("[READY]", metadata: [
            "session": "\(sessionID)",
            "reconnectURL": "\(resumeGatewayURL)"
        ])
    }

    func handleSessionEstablished(event: String) {
        state = .sessionEstablished
        sessionOpen = true
        gatewayBackoff.succeed()
        Self.log.info("[\(event)]")
    }

    func handleInvalidSession(canResume shouldResume: Bool) {
        Self.log.warning("[INVALID_SESSION]", metadata: ["canResume": "\(shouldResume)"])
        if shouldResume {
            doResumeOrIdentify()
        } else {
            onSessionInvalid.notify()
            doIdentify()
        }
        updateLastHeartbeatAckTime()
    }
}

// MARK: - Heartbeating
private extension RobustWebSocket {
    func startHeartbeating(
        interval: TimeInterval,
        for sourceSocket: AnyObject,
        firstDelay: TimeInterval? = nil
    ) {
        withLifecycleLock {
            invalidateHeartbeatTimers()
        }

        let firstDelay = firstDelay ?? Double.random(in: 0..<interval)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.withLifecycleLock {
                guard self.isCurrentSocket(sourceSocket), self.connected, self.state != .closed else { return }
                self.initialHeartbeatTimer = Timer.scheduledTimer(withTimeInterval: firstDelay, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    self.withLifecycleLock {
                        guard self.isCurrentSocket(sourceSocket), self.connected, self.state != .closed else { return }
                        self.initialHeartbeatTimer = nil
                        self.handleHeartbeatIntervalTick(for: sourceSocket)
                        guard self.isCurrentSocket(sourceSocket), self.connected, self.state != .closed else { return }
                        self.heartbeatTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                            self?.handleHeartbeatIntervalTick(for: sourceSocket)
                        }
                    }
                }
            }
        }
    }

    func handleHeartbeatIntervalTick(for sourceSocket: AnyObject) {
        withLifecycleLock {
            guard isCurrentSocket(sourceSocket), connected, state != .closed else { return }
            if heartbeatAck {
                heartbeatAck = false
                sendQOSHeartbeat()
            } else if expeditedHeartbeatTimeout == nil {
                handleHeartbeatTimeout()
            }
        }
    }

    func handleHeartbeatRequest(from sourceSocket: AnyObject) {
        withLifecycleLock {
            guard isCurrentSocket(sourceSocket) else { return }
            sendQOSHeartbeat()
            if let interval = heartbeatInterval {
                startHeartbeating(interval: interval, for: sourceSocket, firstDelay: interval)
            }
        }
    }

    func handleHeartbeatAck() {
        withLifecycleLock {
            heartbeatAck = true
            updateLastHeartbeatAckTime()
            invalidateExpeditedHeartbeatTimeout()
            Self.log.debug("[HEARTBEAT_ACK]")
        }
    }

    func sendHeartbeatIfDue() {
        withLifecycleLock {
            guard connected, let heartbeatInterval = heartbeatInterval else { return }
            guard let lastHeartbeatSentTime = lastHeartbeatSentTime else { return }

            if Date().timeIntervalSince(lastHeartbeatSentTime) > heartbeatInterval + 5 {
                Self.log.debug("[HEARTBEAT] Sending extra heartbeat because incoming traffic exceeded heartbeat interval")
                sendQOSHeartbeat()
            }
        }
    }

    func sendQOSHeartbeat(qos: String? = nil) {
        withLifecycleLock {
            guard connected, state != .closed else { return }
            lastHeartbeatSentTime = Date()
            Self.log.debug("[QOS_HEARTBEAT]", metadata: ["seq": "\(seq ?? -1)"])
            sendGatewayPayload(
                .qosHeartbeat,
                data: GatewayQOSHeartbeat(seq: seq, qos: qos),
                requiresEstablished: false
            )
        }
    }

    func networkStateChange(
        timeout: TimeInterval,
        reason: String,
        reconnectImmediately: Bool = true
    ) {
        expeditedHeartbeat(
            timeout: timeout,
            reason: reason,
            reconnectImmediately: reconnectImmediately,
            closeIfNotEstablished: false
        )
    }

    func expeditedHeartbeat(
        timeout: TimeInterval,
        reason: String,
        reconnectImmediately: Bool = true,
        closeIfNotEstablished: Bool = true
    ) {
        var shouldResetBackoff = false
        var disconnectedStateToLog: String?

        withLifecycleLock {
            guard state != .closed else { return }

            let sourceSocket = currentSocketObject
            guard connected, let sourceSocket = sourceSocket else {
                if reconnectImmediately {
                    shouldResetBackoff = true
                } else {
                    disconnectedStateToLog = state.rawValue
                }
                return
            }

            heartbeatAck = false
            sendQOSHeartbeat()
            invalidateExpeditedHeartbeatTimeout()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.withLifecycleLock {
                    guard self.isCurrentSocket(sourceSocket), self.connected, self.state != .closed else { return }
                    self.expeditedHeartbeatTimeout = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
                        guard let self = self else { return }
                        self.withLifecycleLock {
                            guard self.isCurrentSocket(sourceSocket), self.connected, self.state != .closed else { return }
                            self.expeditedHeartbeatTimeout = nil
                            if !self.heartbeatAck {
                                self.handleHeartbeatTimeout()
                            }
                        }
                    }
                }
            }
        }

        if shouldResetBackoff {
            resetBackoff(reason: reason, closeIfNotEstablished: closeIfNotEstablished)
        } else if let disconnectedStateToLog {
            Self.log.debug("Expedited heartbeat requested while disconnected", metadata: [
                "state": "\(disconnectedStateToLog)",
                "reason": "\(reason)"
            ])
        }
    }

    func updateLastHeartbeatAckTime() {
        withLifecycleLock {
            lastHeartbeatAckTime = Date()
        }
    }
}

// MARK: - Cleanup
private extension RobustWebSocket {
    var currentSocketObject: AnyObject? {
        #if canImport(WebSocket)
        return socket
        #else
        return socket
        #endif
    }

    func takeCurrentSocket(matching expectedSocket: AnyObject? = nil) -> AnyObject? {
        lifecycleLock.lock()
        defer { lifecycleLock.unlock() }

        guard let currentSocket = currentSocketObject else { return nil }
        if let expectedSocket = expectedSocket, currentSocket !== expectedSocket {
            return nil
        }

        #if canImport(WebSocket)
        socket = nil
        #else
        socket = nil
        #endif

        return currentSocket
    }

    func cleanupCurrentSocket(
        closeCode: URLSessionWebSocketTask.CloseCode?,
        reason: String?
    ) {
        let socketToCleanup = takeCurrentSocket()
        cleanupSocket(socketToCleanup, closeCode: closeCode, reason: reason)
    }

    func cleanupCurrentSocketIfCurrent(
        _ expectedSocket: AnyObject,
        closeCode: URLSessionWebSocketTask.CloseCode?,
        reason: String?
    ) -> Bool {
        guard let socketToCleanup = takeCurrentSocket(matching: expectedSocket) else { return false }
        cleanupSocket(socketToCleanup, closeCode: closeCode, reason: reason)
        return true
    }

    func cleanupSocket(
        _ socketToCleanup: AnyObject?,
        closeCode: URLSessionWebSocketTask.CloseCode?,
        reason: String?
    ) {
        invalidateHeartbeatTimers()
        invalidateHelloTimeout(reason: "Cleaning up socket")
        invalidatePendingReconnect()
        invalidateExpeditedHeartbeatTimeout()

        heartbeatInterval = nil
        heartbeatAck = true
        lastHeartbeatSentTime = nil
        connected = false

        let reasonData = reason?.data(using: .utf8)

        #if canImport(WebSocket)
        if let socket = socketToCleanup as? WebSocket {
            socket.onData = nil
            socket.onError = nil
            if closeCode != nil {
                socket.disconnect()
            }
        }
        #else
        if let socket = socketToCleanup as? URLSessionWebSocketTask {
            if let closeCode = closeCode {
                socket.cancel(with: closeCode, reason: reasonData)
            } else {
                socket.cancel()
            }
        }
        #endif

        decompressor = DecompressionEngine()
    }

    func invalidateHeartbeatTimers() {
        initialHeartbeatTimer?.invalidate()
        initialHeartbeatTimer = nil
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }

    func invalidateHelloTimeout(reason: String = "") {
        if helloTimeoutTimer != nil {
            Self.log.debug("Invalidating HELLO timeout", metadata: ["reason": "\(reason)"])
        }
        helloTimeoutTimer?.invalidate()
        helloTimeoutTimer = nil
    }

    func invalidatePendingReconnect() {
        reconnectGeneration += 1
        pendingReconnect?.invalidate()
        pendingReconnect = nil
    }

    func invalidateExpeditedHeartbeatTimeout() {
        expeditedHeartbeatTimeout?.invalidate()
        expeditedHeartbeatTimeout = nil
    }
}

// MARK: - WebSocketTask delegate functions
extension RobustWebSocket: URLSessionWebSocketDelegate {
    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        guard withLifecycleLock({ isCurrentSocket(webSocketTask) }) else { return }
        Self.log.info("[CONNECTED]")
    }

    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) }
        if handleClose(wasClean: true, closeCode: closeCode, reason: reasonString, sourceSocket: webSocketTask) {
            Self.log.warning("[WS CLOSED]", metadata: [
                "closeCode": "\(closeCode.rawValue)",
                "reason": "\(reasonString ?? "")"
            ])
        }
    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        guard let error = error else { return }
        guard let webSocketTask = task as? URLSessionWebSocketTask else { return }
        if handleClose(
            wasClean: false,
            closeCode: nil,
            reason: "An error with the websocket occurred",
            sourceSocket: webSocketTask,
            clearResumeGatewayURL: true
        ) {
            Self.log.error("[WS ERROR]", metadata: ["error": "\(error.localizedDescription)"])
        }
    }
}

// MARK: - Reachability
#if canImport(Reachability)
private extension RobustWebSocket {
    func setupReachability() {
        guard !reachabilityStarted else { return }

        reachability.whenReachable = { [weak self] _ in
            self?.reachable = true
            self?.networkStateChange(timeout: 5, reason: "network detected online.")
        }
        reachability.whenUnreachable = { [weak self] _ in
            self?.reachable = false
            Self.log.warning("Network detected offline, sending expedited heartbeat")
            self?.networkStateChange(
                timeout: 15,
                reason: "network detected offline.",
                reconnectImmediately: false
            )
        }
        do {
            try reachability.startNotifier()
            reachabilityStarted = true
        } catch {
            Self.log.error("Starting reachability notifier failed")
        }
    }
}
#endif

// MARK: - Extension with public exposed methods
public extension RobustWebSocket {
    /// Forcefully close the Gateway socket connection.
    ///
    /// - Parameters:
    ///   - code: A custom code to close the socket with (defaults to `.abnormalClosure`).
    ///   - shouldReconnect: If reconnection should be attempted after the connection
    ///   is closed. Defaults to `true`.
    final func forceClose(
        code: URLSessionWebSocketTask.CloseCode = .abnormalClosure,
        shouldReconnect: Bool = true
    ) {
        withLifecycleLock {
            Self.log.warning("Forcibly closing connection")
            guard state != .closed else { return }
            cleanupCurrentSocket(closeCode: code, reason: nil)

            if shouldReconnect {
                state = .willReconnect
                scheduleReconnect(closeCode: code, reason: "Force-closed connection")
            } else {
                state = .closed
                resetSession(wasClean: false, closeCode: code, reason: "Force-closed connection")
            }
        }
    }

    /// Explicitly close the Gateway socket connection.
    ///
    /// The socket connection cannot be reconnected after ``close(code:)`` is
    /// called. To reconnect, recreate the ``RobustWebSocket`` instance.
    ///
    /// - Parameter code: The close code to close the socket with.
    final func close(code: URLSessionWebSocketTask.CloseCode) {
        withLifecycleLock {
            guard state != .closed || socket != nil else { return }
            state = .closed
            resetSession(wasClean: true, closeCode: code, reason: "Disconnect requested by user")
            gatewayBackoff.succeed()
            nextReconnectIsImmediate = false

            #if canImport(Reachability)
            reachability.stopNotifier()
            reachabilityStarted = false
            #endif

            cleanupCurrentSocket(closeCode: code, reason: "Disconnect requested by user")
        }
    }

    /// Initiates a Gateway socket connection.
    ///
    /// This method has no effect unless the socket is currently closed.
    final func open() {
        withLifecycleLock {
            guard state == .closed else { return }
            state = .willReconnect
            connect()
        }
    }

    /// Handles a desktop power-monitor resume signal.
    ///
    /// Mirrors the official desktop path by sending an expedited heartbeat
    /// with a 5 second ACK deadline.
    final func powerMonitorResumed() {
        expeditedHeartbeat(timeout: 5, reason: "power monitor resumed")
    }

    /// Send an outgoing payload to the Gateway.
    ///
    /// This method has no effect until the Gateway session is established.
    final func send<T: OutgoingGatewayData>(
        _ opcode: GatewayOutgoingOpcodes,
        data: T,
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        sendGatewayPayload(opcode, data: data, requiresEstablished: true, completionHandler: completionHandler)
    }
}

private extension RobustWebSocket {
    func canSendPayload(requiresEstablished: Bool) -> Bool {
        requiresEstablished ? canSendEstablishedPayloads : canSendLifecyclePayloads
    }

    func sendGatewayPayload<T: OutgoingGatewayData>(
        _ opcode: GatewayOutgoingOpcodes,
        data: T,
        requiresEstablished: Bool,
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        let sendPayload = GatewayOutgoing(opcode: opcode, data: data)
        guard let encoded = try? DiscordREST.encoder.encode(sendPayload) else { return }

        let hidesToken = T.self == GatewayIdentify.self || T.self == GatewayResume.self
        let loggedData = hidesToken ? "<redacted>" : String(describing: data)
        Self.log.trace("Outgoing Payload", metadata: [
            "opcode": "\(opcode)",
            "data": "\(loggedData)"
        ])

        #if canImport(WebSocket)
        withLifecycleLock {
            guard canSendPayload(requiresEstablished: requiresEstablished) else { return }
            socket?.send(encoded)
        }
        #else
        let socketForSend = withLifecycleLock { () -> URLSessionWebSocketTask? in
            guard canSendPayload(requiresEstablished: requiresEstablished) else { return nil }
            return socket
        }
        guard let socketForSend = socketForSend else { return }

        Task { [weak self, weak socketForSend] in
            guard let self = self,
                  let socket = socketForSend,
                  self.withLifecycleLock({
                      guard let currentSocket = self.socket else { return false }
                      return currentSocket === socket
                  }) else { return }
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
