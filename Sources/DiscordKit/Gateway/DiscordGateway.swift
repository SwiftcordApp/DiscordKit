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
    public var socket: RobustWebSocket?

    /// A cache for some data received from the Gateway
    ///
    /// Data from the `READY` event is stored in this cache. The data
    /// within this cache is updated with received events, and should
    /// remain fresh.
    ///
    /// Refer to ``CachedState`` for more details about the data in
    /// this cache.
    ///
    /// > New properties will not be added to the ``CachedState`` class
    /// > since it doesn't seem to play well with SwiftUI, causing all sorts of
    /// > stale UI issues (i.e. stale UI)
    @Published public var cache: CachedState = CachedState()

    /// An array of presences, kept updated as long as the Gateway connection is active
    ///
    /// Contains a dict of user presences, keyed by their respective user IDs
    @Published public var presences: [Snowflake: Presence] = [:]

    /// An array of guild folders
    @Published public var guildFolders: [GuildFolderItem] = []

    /// An array of the current user's DMs
    ///
    /// Includes both single DMs and group DMs
    @Published public var privateChannels: [Channel] = []

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

    // Event subscribing state
    private var subscribedGuildID: Snowflake?
    private var subscribedMemberIDs: [Snowflake] = []
    private var subscribedTypingGuildIDs: [Snowflake] = [] // Guild IDs already subscribed to for typing events

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

    /// Disconnects from the gateway gracefully
    public func disconnect() {
        log.debug("Disconnecting on request")
        // Clear cache
        cache = CachedState()
        cache.objectWillChange.send()
        socket?.close(code: .normalClosure)
    }

    public func send<T: OutgoingGatewayData>(op: GatewayOutgoingOpcodes, data: T) {
        guard let socket = socket else {
            log.warning("Not sending data to a non existant socket")
            return
        }
        socket.send(op: op, data: data)
    }

    /// Subscribe to guild events or member updates
    ///
    /// Either subscribes to typing events from members in a guild, or to presence updates from particular members
    ///
    /// > Unsubscribing from events from previous guilds are automatically handled
    ///
    /// - Parameters:
    ///  - id: ID of guild to subscribe to
    ///  - memberID: additional member ID to subscribe to
    public func subscribeGuildEvents(id: Snowflake, memberID: Snowflake? = nil) {
        if let memberID = memberID {
            if subscribedGuildID != id { subscribedMemberIDs.removeAll() }
            subscribedMemberIDs.append(memberID)
            send(
                op: .subscribeGuildEvents,
                data: SubscribeGuildEvts(guild_id: id, members: subscribedMemberIDs)
            )
            // Unsubscribe from events from previous guild after subscribing to the new guild
            // as per official client behaviour. It makes more sense to do it in the opposite order,
            // but who am I to judge.
            if subscribedGuildID != id, let previousGuild = subscribedGuildID {
                send(
                    op: .subscribeGuildEvents,
                    data: SubscribeGuildEvts(guild_id: previousGuild, members: [])
                )
            }
            subscribedGuildID = id
        } else if !subscribedTypingGuildIDs.contains(id) {
            // Subscribe to typing events from members in the guild if we haven't already
            send(
                op: .subscribeGuildEvents,
                data: SubscribeGuildEvts(guild_id: id, typing: true)
            )
            subscribedTypingGuildIDs.append(id)
        }
    }

    /// Request for member presence if not already available
    public func requestPresence(id: Snowflake, memberID: Snowflake) {
        if presences[memberID] == nil {
            subscribeGuildEvents(id: id, memberID: memberID)
        }
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

    private func handleProtoUpdate(proto: String) {
        let settings: Discord_UserSettings
        do {
            settings = try Discord_UserSettings(serializedData: Data(base64Encoded: proto)!)
        } catch {
            log.error("Proto decode error! \(String(describing: error))")
            return
        }
        // Update current user presence
        if let currentID = cache.user?.id {
            presences[currentID] = Presence(protoStatus: settings.status, id: currentID)
            log.debug("Updated presence for current user to \(self.presences[currentID]?.status.rawValue ?? "nil", privacy: .public)")
        } else {
            log.error("User ID is unset in cache!")
        }
        // Update guild folders
        guildFolders = settings.guildFolders.folders.map {
            .init(
                id: $0.hasID ? String($0.id.value) : nil,
                name: $0.hasName ? $0.name.value : nil,
                guild_ids: $0.guildIds.map({ id in String(id) }),
                color: $0.hasColor ? Int($0.color.value) : nil
            )
        }
    }
    private func handleEvent(_ event: GatewayEvent, data: GatewayData?) {
        switch (event, data) {
        case let (.ready, event as ReadyEvt):
            cache.configure(using: event)
            presences.removeAll()
            if let proto = event.user_settings_proto {
                handleProtoUpdate(proto: proto)
            } else { log.warning("No user settings proto, is this a bot account?") }
            log.info("[READY] Gateway wrapper ready")

        case let (.readySupplemental, evt as ReadySuppEvt):
            let flatPresences = evt.merged_presences.guilds.flatMap { $0 } + evt.merged_presences.friends
            for presence in flatPresences {
                presences.updateValue(presence, forKey: presence.user_id)
            }

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
            
        case let (.userSettingsProtoUpdate, protoUpdate as GatewaySettingsProtoUpdate):
            guard !protoUpdate.partial else {
                log.warning("Cannot handle partial proto update yet")
                break
            }
            guard protoUpdate.settings.type == 1 else {
                log.warning("Parsing of proto type other than 1 not supported")
                break
            }
            handleProtoUpdate(proto: protoUpdate.settings.proto)

            // Channel events
        case let (.channelCreate, channel as Channel):
            cache.append(channel)

        case let (.channelDelete, channel as Channel):
            cache.remove(channel)

        case let (.channelUpdate, channel as Channel):
            cache.replace(channel)

        case let (.messageCreate, message as DiscordKitCommon.Message):
            cache.appendOrReplace(message)

        case let (.presenceUpdate, update as PresenceUpdate):
            presences.updateValue(Presence(update: update), forKey: update.user.id)
            log.debug("Updating presence for user ID: \(update.user.id, privacy: .public)")

        default:
            break
        }

        cache.objectWillChange.send()
        onEvent.notify(event: (event, data))
        log.debug("[EVENT] Dispatched event <\(event.rawValue, privacy: .public)>")
    }
}
