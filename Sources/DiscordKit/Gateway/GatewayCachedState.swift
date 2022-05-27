//
//  CachedState.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 22/2/22.
//

import Foundation

/// A struct for storing cached data from the Gateway
///
/// Used in ``DiscordGateway/cache``.
public struct CachedState {
    /// Dictionary of guilds the user is in
    ///
    /// > The guild's ID is its key
    public var guilds: [Snowflake: Guild] = [:]
        
    /// DM channels the user is in
	public var dms: [Channel] = []
    
    /// Cached object of current user
	public var user: User?
    
    /// Cached users, initially populated from `READY` event and might
    /// grow over time
    public var users: [Snowflake: User] = [:]
    
    /// User settings
    ///
    /// View ``UserSettings`` for information about each entry.
    public var userSettings: UserSettings? = nil
}
