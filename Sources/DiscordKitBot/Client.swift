//
//  Client.swift
//  
//
//  Created by Vincent Kwok on 21/11/22.
//

import Foundation
import Combine
import Logging
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

    // Logger
    private static let logger = Logger(label: "Client", level: nil)

    // public let event: EventDispatcher

    // MARK: Information about the bot
    /// The user object of the bot
    public fileprivate(set) var user: User?
    /// The application ID of the bot
    ///
    /// This is used for registering application commands, among other actions.
    public fileprivate(set) var applicationID: String?

    public init(intents: Intents = .unprivileged) {
        self.intents = intents
        // Override default config for bots
        DiscordKitConfig.default = .init(
            properties: .init(browser: DiscordKitConfig.libraryName, device: DiscordKitConfig.libraryName),
            intents: intents
        )
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
        gateway = .init(token: token)
        evtHandlerID = gateway?.onEvent.addHandler { [weak self] data in
            self?.handleEvent(data)
        }
        RunLoop.main.run()
    }

    /// Disconnect from the gateway, undoes ``login(token:)``
    ///
    /// Request that the gateway connection be gracefully closed. Also destroys
    /// the REST hander. Following this call, none of the APIs would function. Subsequently,
    /// connection can be restored by calling ``login(token:)`` again.
    public func disconnect() {
        // Remove event listeners and gracefully disconnect from Gateway
        gateway?.close(code: .normalClosure)
        if let evtHandlerID = evtHandlerID { _ = gateway?.onEvent.removeHandler(handler: evtHandlerID) }
        // Clear member vars
        gateway = nil
        rest = nil
    }
}

// Gateway API
extension Client {
    public var isReady: Bool { gateway?.sessionOpen == true }

    private func handleEvent(_ data: GatewayIncoming.Data) {
        switch data {
        case .botReady(let readyEvt):
            // Set several members with info about the bot
            applicationID = readyEvt.application.id
            user = readyEvt.user
            Self.logger.info("Bot client ready", metadata: [
                "user.id": "\(readyEvt.user.id)",
                "application.id": "\(readyEvt.application.id)"
            ])
            NotificationCenter.default.post(name: .ready, object: nil)
        default:
            break
        }
    }
}
