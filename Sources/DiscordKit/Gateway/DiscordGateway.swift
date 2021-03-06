//
//  DiscordGateway.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation
import os
import DiscordKitCommon
import DiscordKitCore

/// Higher-level Gateway manager, mainly for handling and dispatching
/// Gateway events
///
/// Uses a ``RobustWebSocket`` for the socket connection with the Gateway
/// internally. You should use this class instead of ``RobustWebSocket``
/// since it hides away even more implementation details.
///
/// Conforms to `ObservableObject` for use in SwiftUI projects.
public class DiscordGateway: ObservableObject {
    // Events
    /// An ``EventDispatch`` that is notified when an event is dispatched
    /// from the Gateway
	public let onEvent = EventDispatch<(GatewayEvent, GatewayData?)>()

    /// Proxies ``RobustWebSocket/onAuthFailure``
	public let onAuthFailure = EventDispatch<Void>()

    // WebSocket object
    @Published public var socket: RobustWebSocket?

    /// A cache for some data received from the Gateway
    ///
    /// Data from the `READY` event is stored in this cache. The data
    /// within this cache is updated with received events, and should
    /// remain fresh.
    ///
    /// Refer to ``CachedState`` for more details about the data in
    /// this cache.
    ///
    /// > In the future, presence updates and REST API requests will
    /// > also be stored and kept fresh in this cache.
    @Published public var cache: CachedState = CachedState()

    private var evtListenerID: EventDispatch.HandlerIdentifier? = nil,
                authFailureListenerID: EventDispatch.HandlerIdentifier? = nil,
                connStateChangeListenerID: EventDispatch.HandlerIdentifier? = nil

    /// If the Gateway socket is connected
    ///
    /// `@Published` proxy of ``RobustWebSocket/sessionOpen``
    @Published public var connected = false
    /// If the network is reachable (has network connectivity)
    ///
    /// `@Published` proxy of ``RobustWebSocket/reachable``
    @Published public var reachable = false

    // Logger
    private let log = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? DiscordKitConfig.subsystem,
        category: "DiscordGateway"
    )

    /// Log out the current user, closing the Gateway socket connection
    ///
    /// This method removes the Discord token from the keychain and
    /// closes the Gateway socket. The socket will _not_ reconnect.
    public func logout() {
        guard let socket = socket else {
            log.warning("Cannot log out, socket hasn't been opened. Call connect() first.")
            return
        }

        log.debug("Logging out on request")

        // Remove token from the keychain
        /*Keychain.remove(key: "authToken")
        // Reset user defaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }*/
        // Clear cache
        cache = CachedState()
        cache.objectWillChange.send()

        socket.close(code: .normalClosure)
        onAuthFailure.notify()
    }

    /// Opens the socket connection with the Gateway
    ///
    /// > Important: This method will be called when a token is provided to ``init(token:)``,
    /// > so there is no need to call this method again.
    ///
    /// - Parameter token: Token to use to authenticate with the Gateway
    public func connect(token: String) {
        socket = RobustWebSocket(token: token)
        evtListenerID = socket!.onEvent.addHandler { [weak self] (t, d) in
            self?.handleEvent(t, data: d)
        }
        authFailureListenerID = socket!.onAuthFailure.addHandler { [weak self] in
            self?.onAuthFailure.notify()
        }
        connStateChangeListenerID = socket!.onConnStateChange.addHandler { [weak self] (c, r) in
            self?.connected = c
            self?.reachable = r
        }
        socket!.open()
    }

    public func send<T: OutgoingGatewayData>(op: GatewayOutgoingOpcodes, data: T) {
        guard let socket = socket else {
            log.warning("Not sending data to a non existant socket")
            return
        }
        socket.send(op: op, data: data)
    }

    private func handleEvent(_ event: GatewayEvent, data: GatewayData?) {
        switch (event, data) {
            case let (.ready, event as ReadyEvt):
                cache.configure(using: event)
                log.info("Gateway ready")

            // Guild events
            case let (.guildCreate, guild as Guild):
                cache.appendOrReplace(guild)

            case let (.guildDelete, guild as GuildUnavailable):
                cache.remove(guild)

            case let (.guildUpdate, guild as Guild):
                handleGuildUpdate(guild)

            // User updates
            case let (.userUpdate, currentUser as CurrentUser):
                cache.user = currentUser

            case let (.userSettingsUpdate, settings as UserSettings):
                cache.mergeOrReplace(settings)

            // Channel events
            case let (.channelCreate, channel as Channel):
                cache.append(channel)

            case let (.channelDelete, channel as Channel):
                cache.remove(channel)

            case let (.channelUpdate, channel as Channel):
                cache.replace(channel)

            case let (.messageCreate, message as Message):
                cache.appendOrReplace(message)

            case let (.presenceUpdate, update as PresenceUpdate):
                log.info("Presence update: \(String(describing: update))")

            default:
                break
        }

        cache.objectWillChange.send()
        onEvent.notify(event: (event, data))
        log.info("Dispatched event <\(event.rawValue, privacy: .public)>")
    }

    /// Inits an instance of ``DiscordGateway``
    ///
    /// - Parameter token: Optionally provide a Discord token to connect with. If one is provided,
    /// ``connect(token:)`` will be called. Otherwise, ``connect(token:)`` has to be called
    /// to set the token and connect.
    public init(token: String? = nil) {
        if let token = token {
            connect(token: token)
        }
    }

    private func removeHandlers() {
        if let evtListenerID = evtListenerID {
            _ = socket?.onEvent.removeHandler(handler: evtListenerID)
        }
        if let authFailureListenerID = authFailureListenerID {
            _ = socket?.onAuthFailure.removeHandler(handler: authFailureListenerID)
        }
        if let connStateChangeListenerID = connStateChangeListenerID {
            _ = socket?.onConnStateChange.removeHandler(handler: connStateChangeListenerID)
        }
    }

    deinit { removeHandlers() }

    // MARK: - Private Event Handlers

    private func handleGuildUpdate(_ updatedGuild: Guild) {
        guard let existingGuild = cache.guilds[updatedGuild.id] else {
            return
        }

        var modifiedGuild = updatedGuild

        // ``GatewayEvent.guildUpdate`` events are missing data that is only present in the initial ``GatewayEvent.ready`` event, so we need to copy those properties over manually.
        modifiedGuild.joined_at = existingGuild.joined_at
        modifiedGuild.large = existingGuild.large
        modifiedGuild.unavailable = existingGuild.unavailable
        modifiedGuild.member_count = existingGuild.member_count
        modifiedGuild.voice_states = existingGuild.voice_states
        modifiedGuild.members = existingGuild.members
        modifiedGuild.channels = existingGuild.channels
        modifiedGuild.threads = existingGuild.threads
        modifiedGuild.presences = existingGuild.presences
        modifiedGuild.stage_instances = existingGuild.stage_instances
        modifiedGuild.guild_scheduled_events = existingGuild.guild_scheduled_events

        cache.appendOrReplace(modifiedGuild)
    }
}
