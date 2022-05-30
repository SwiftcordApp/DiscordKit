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
public class DiscordGateway: ObservableObject {
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
    public var cache: CachedState = CachedState()
    
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
    
    private func handleEvt(type: GatewayEvent, data: GatewayData?) {
        var eventWasHandled = true
        
        switch (type) {
        case .ready:
            guard let d = data as? ReadyEvt else { break }
            
            // Populate cache with data sent in ready event
            for guild in d.guilds { cache.guilds.updateValue(guild, forKey: guild.id) }
            /*self.cache.guilds = (d.guilds
                .filter({ g in !d.user_settings.guild_positions.contains(g.id) })
                .sorted(by: { lhs, rhs in lhs.joined_at! > rhs.joined_at! }))
            + d.user_settings.guild_positions.compactMap({ id in d.guilds.first { g in g.id == id } })*/
            cache.dms = d.private_channels
            cache.user = d.user
            for user in d.users { cache.users.updateValue(user, forKey: user.id) }
            cache.userSettings = d.user_settings
            
            log.info("Gateway ready")
        // Guild events
        case .guildCreate:
            guard let d = data as? Guild else { break }
            cache.guilds.updateValue(d, forKey: d.id)
        case .guildDelete:
            guard let d = data as? GuildUnavailable else { break }
            cache.guilds.removeValue(forKey: d.id)
        case .guildUpdate:
            guard var d = data as? Guild else { break }
            guard let oldGuild = cache.guilds[d.id]
            else { return }
            
            // Fuse the old guild with the updated guild
            d.joined_at = oldGuild.joined_at
            d.large = oldGuild.large
            d.unavailable = oldGuild.unavailable
            d.member_count = oldGuild.member_count
            d.voice_states = oldGuild.voice_states
            d.members = oldGuild.members
            d.channels = oldGuild.channels
            d.threads = oldGuild.threads
            d.presences = oldGuild.presences
            d.stage_instances = oldGuild.stage_instances
            d.guild_scheduled_events = oldGuild.guild_scheduled_events
            cache.guilds[d.id] = d
        // User updates
        case .userUpdate:
            guard let updatedUser = data as? CurrentUser else { break }
            cache.user = updatedUser
        case .userSettingsUpdate:
            guard let newSettings = data as? UserSettings else { break }
            cache.userSettings = mergeUserSettings(cache.userSettings, new: newSettings)
        // Channel events
        case .channelCreate:
            guard let newCh = data as? Channel else { break }
            if let guildID = newCh.guild_id {
                cache.guilds[guildID]?.channels?.append(newCh)
            }
        case .channelDelete:
            guard let delCh = data as? Channel else { break }
            if let guildID = delCh.guild_id {
                cache.guilds[guildID]?.channels?.removeAll { delCh.id == $0.id }
            }
        case .channelUpdate:
            guard let updatedCh = data as? Channel else { break }
            if let guildID = updatedCh.guild_id,
               let chIdx = cache.guilds[guildID]?
                .channels?
                .firstIndex(where: { updatedCh.id == $0.id }) {
                cache.guilds[updatedCh.guild_id!]?.channels?[chIdx] = updatedCh
            }
        case .messageCreate:
            guard let msg = data as? Message else { break }
            if let guild = msg.guild_id,
               let idx = cache.guilds[guild]?
                .channels?
                .firstIndex(where: { $0.id == msg.channel_id }) {
                    cache.guilds[guild]?.channels?[idx].last_message_id = msg.id
            } else if let idx = cache.dms.firstIndex(where: { $0.id == msg.channel_id }) {
                cache.dms[idx].last_message_id = msg.id
            }
        case .presenceUpdate:
            guard let p = data as? PresenceUpdate else { return }
            print("Presence update!")
            print(p)
        default: eventWasHandled = false
        }
        if eventWasHandled { cache.objectWillChange.send() }
        onEvent.notify(event: (type, data))
        log.info("Dispatched event <\(type.rawValue, privacy: .public)>")
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
            self?.handleEvt(type: t, data: d)
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
            let _ = socket.onEvent.removeHandler(handler: evtListenerID)
        }
        if let authFailureListenerID = authFailureListenerID {
            let _ = socket.onAuthFailure.removeHandler(handler: authFailureListenerID)
        }
        if let connStateChangeListenerID = connStateChangeListenerID {
            let _ = socket.onConnStateChange.removeHandler(handler: connStateChangeListenerID)
        }
    }
}
