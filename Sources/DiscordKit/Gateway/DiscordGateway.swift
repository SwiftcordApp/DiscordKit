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
        switch (type) {
        case .ready:
            guard let d = data as? ReadyEvt else { return }
            
            // Populate cache with data sent in ready event
            self.cache.guilds = (d.guilds
                .filter({ g in !d.user_settings.guild_positions.contains(g.id) })
                .sorted(by: { lhs, rhs in lhs.joined_at! > rhs.joined_at! }))
            + d.user_settings.guild_positions.compactMap({ id in d.guilds.first { g in g.id == id } })
            self.cache.dms = d.private_channels
            self.cache.user = d.user
            self.cache.users = d.users
            
            log.info("Gateway ready")
        case .guildCreate:
            guard let d = data as? Guild else { return }
            self.cache.guilds?.insert(d, at: 0) // As per official Discord implementation
        case .guildDelete:
            guard let d = data as? GuildUnavailable else { return }
            self.cache.guilds?.removeAll { g in g.id == d.id }
        case .userUpdate:
            guard let updatedUser = data as? User else { return }
            self.cache.user = updatedUser
        case .presenceUpdate:
            break
            // guard let p = data as? PresenceUpdate else { return }
            //print("Presence update!")
            //print(p)
        default: break
        }
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
