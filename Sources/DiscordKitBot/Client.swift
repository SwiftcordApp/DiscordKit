//
//  Client.swift
//  
//
//  Created by Vincent Kwok on 21/11/22.
//

import Foundation
import Combine
import DiscordKitCore

/// The main client class for bots to interact with Discord's API
public final class Client {
    private var rest: DiscordREST?

    // MARK: Gateway vars
    fileprivate var gateway: RobustWebSocket?
    private var evtHandlerID: EventDispatch.HandlerIdentifier?

    // MARK: Event publishers
    public let ready = PassthroughSubject<Void, Never>()
    public let messages = PassthroughSubject<BotMessage, Never>()

    // MARK: Configuration Members
    public let intents: Intents

    public init(intents: Intents = .unprivileged) {
        self.intents = intents
    }

    deinit {
        disconnect()
    }

    /// Login to the Discord API with a token
    ///
    /// Calling this function will cause a connection to the Gateway to be attempted.
    ///
    /// > Warning: Ensure this function is called _before_ any calls to the API are made,
    /// > and _after_ all event sinks have been registered. API calls made before this call
    /// > will fail, and no events will be received while the gateway is disconnected.
    public func login(token: String) {
        rest = .init(token: token)
        gateway = .init(token: token, intents: intents)
        evtHandlerID = gateway?.onEvent.addHandler { [weak self] (event, data) in
            self?.handleEvent(event, data: data)
        }
        RunLoop.main.run()
    }

    private func handleEvent(_ evt: GatewayEvent, data: GatewayData?) {
        
    }
}

// Gateway API
extension Client {
    public func disconnect() {
        // Remove event listeners and gracefully disconnect from Gateway
        gateway?.close(code: .normalClosure)
        if let evtHandlerID = evtHandlerID { _ = gateway?.onEvent.removeHandler(handler: evtHandlerID) }
        // Clear member vars
        gateway = nil
        rest = nil
    }

    public var isReady: Bool { gateway?.sessionOpen == true }
}
