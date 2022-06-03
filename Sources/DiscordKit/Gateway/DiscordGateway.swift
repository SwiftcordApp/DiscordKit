//
//  DiscordGateway.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 20/2/22.
//

import Foundation
import os
import SwiftUI
import DiscordKitCommon

/// Higher-level Gateway manager, mainly for handling and dispatching
/// Gateway events
///
/// Uses a ``RobustWebSocket`` for the socket connection with the Gateway
/// internally. You should use this class instead of ``RobustWebSocket``
/// since it hides away even more implementation details.
///
/// Conforms to `ObservableObject` for use in SwiftUI projects.
public class DiscordGateway: ObservableObject, Equatable {
    public static func == (lhs: DiscordGateway, rhs: DiscordGateway) -> Bool {
        lhs.cache == rhs.cache
    }

    // Events
    /// An ``EventDispatch`` that is notified when an event is dispatched
    /// from the Gateway
	public let onEvent = EventDispatch<(GatewayEvent, GatewayData?)>()

    /// Proxies ``RobustWebSocket/onAuthFailure``
	public let onAuthFailure = EventDispatch<Void>()

    // WebSocket object
    @Published public var socket: RobustWebSocket!

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
	private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? DiscordAPI.subsystem, category: "DiscordGateway")

    /// Log out the current user, closing the Gateway socket connection
    ///
    /// This method removes the Discord token from the keychain and
    /// closes the Gateway socket. The socket will _not_ reconnect.
    public func logout() {
        log.debug("Logging out on request")

        // Remove token from the keychain
        Keychain.remove(key: "authToken")
        // Reset user defaults
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        // Clear cache
        cache = CachedState()
        objectWillChange.send()

        socket.close(code: .normalClosure)
        onAuthFailure.notify()
    }

    /// Opens the socket connection with the Gateway
    ///
    /// Calls ``RobustWebSocket/open()``
    ///
    /// > The socket will be automatically opened when an instance of
    /// > ``DiscordGateway`` is created, so there is no need to call
    /// > this method right after initing an instance.
    public func connect() {
        socket.open()
    }

    private func handleEvent(_ event: GatewayEvent, data: GatewayData?) {
        switch (event, data) {
            case let (.ready, event as ReadyEvt):
                // Populate cache with data sent in ready event
                for guild in event.guilds {
                    cache.guilds.updateValue(guild, forKey: guild.id)
                }
                /* self.cache.guilds = (d.guilds
                     .filter({ g in !d.user_settings.guild_positions.contains(g.id) })
                     .sorted(by: { lhs, rhs in lhs.joined_at! > rhs.joined_at! }))
                 + d.user_settings.guild_positions.compactMap({ id in d.guilds.first { g in g.id == id } }) */
                cache.dms = event.private_channels
                cache.user = event.user

                for user in event.users {
                    cache.users.updateValue(user, forKey: user.id)
                }

                cache.userSettings = event.user_settings

                log.info("Gateway ready")

            // Guild events
            case let (.guildCreate, guild as Guild):
                cache.guilds.updateValue(guild, forKey: guild.id)

            case let (.guildDelete, guild as GuildUnavailable):
                cache.guilds.removeValue(forKey: guild.id)

            case let (.guildUpdate, guild as Guild):
                guard let oldGuild = cache.guilds[guild.id] else {
                    return
                }

                // Fuse the old guild with the updated guild
                var updatedGuild = guild
                updatedGuild.joined_at = oldGuild.joined_at
                updatedGuild.large = oldGuild.large
                updatedGuild.unavailable = oldGuild.unavailable
                updatedGuild.member_count = oldGuild.member_count
                updatedGuild.voice_states = oldGuild.voice_states
                updatedGuild.members = oldGuild.members
                updatedGuild.channels = oldGuild.channels
                updatedGuild.threads = oldGuild.threads
                updatedGuild.presences = oldGuild.presences
                updatedGuild.stage_instances = oldGuild.stage_instances
                updatedGuild.guild_scheduled_events = oldGuild.guild_scheduled_events
                cache.guilds[updatedGuild.id] = updatedGuild

            // User updates
            case let (.userUpdate, currentUser as CurrentUser):
                cache.user = currentUser

            case let (.userSettingsUpdate, settings as UserSettings):
                cache.userSettings = mergeUserSettings(cache.userSettings, new: settings)

            // Channel events
            case let (.channelCreate, channel as Channel):
                if let guildID = channel.guild_id {
                    cache.guilds[guildID]?.channels?.append(channel)
                }

            case let (.channelDelete, channel as Channel):
                if let guildID = channel.guild_id {
                    cache.guilds[guildID]?.channels?.removeAll { channel.id == $0.id }
                }

            case let (.channelUpdate, channel as Channel):
                if let guildID = channel.guild_id,
                   let chIdx = cache.guilds[guildID]?
                   .channels?
                   .firstIndex(where: { channel.id == $0.id }) {
                    cache.guilds[channel.guild_id!]?.channels?[chIdx] = channel
                }

            case let (.messageCreate, message as Message):
                if let guild = message.guild_id,
                   let idx = cache.guilds[guild]?
                   .channels?
                   .firstIndex(where: { $0.id == message.channel_id }) {
                    cache.guilds[guild]?.channels?[idx].last_message_id = message.id
                } else if let idx = cache.dms.firstIndex(where: { $0.id == message.channel_id }) {
                    cache.dms[idx].last_message_id = message.id
                }

            case let (.presenceUpdate, update as PresenceUpdate):
                log.info("Presence update: \(String(describing: update))")

            default:
                break
        }

        onEvent.notify(event: (event, data))
        log.info("Dispatched event <\(event.rawValue, privacy: .public)>")
    }

    /// Inits an instance of ``DiscordGateway``
    ///
    /// Refer to ``RobustWebSocket/init()`` for more details about parameters
    ///
    /// - Parameters:
    ///   - connectionTimeout: The timeout before the connection attempt
    ///   is aborted. The socket will attempt to reconnect if connection times out.
    ///   - maxMissedACK: Does not have any effect, included for backward
    ///   compatibility. The current implementation follows the official
    ///   Discord client for the missed heartbeat ACK tolerance.
	public init(connectionTimeout: Double = 5, maxMissedACK: Int = 3) {
        socket = RobustWebSocket()
        evtListenerID = socket.onEvent.addHandler { [weak self] (t, d) in
            self?.handleEvent(t, data: d)
        }
        authFailureListenerID = socket.onAuthFailure.addHandler { [weak self] in
            self?.onAuthFailure.notify()
        }
        connStateChangeListenerID = socket.onConnStateChange.addHandler { [weak self] (c, r) in
            withAnimation {
                self?.connected = c
                self?.reachable = r
            }
        }
    }

    deinit {
        if let evtListenerID = evtListenerID {
            _ = socket.onEvent.removeHandler(handler: evtListenerID)
        }
        if let authFailureListenerID = authFailureListenerID {
            _ = socket.onAuthFailure.removeHandler(handler: authFailureListenerID)
        }
        if let connStateChangeListenerID = connStateChangeListenerID {
            _ = socket.onConnStateChange.removeHandler(handler: connStateChangeListenerID)
        }
    }
}
