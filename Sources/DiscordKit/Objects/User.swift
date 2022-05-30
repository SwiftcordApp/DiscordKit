//
//  User.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public enum UserFlags: Int, CaseIterable {
    case staff = 0
    case partner = 1
    case hypesquadEvents = 2
    case bugHunterLv1 = 3
    case hypesquadBravery = 6
    case hypesquadBrilliance = 7
    case hypesquadBalance = 8
    case earlySupporter = 9
    case teamPseudoUser = 10
    case bugHunterLv2 = 14
    case verifiedBot = 16
    case verifiedDev = 17
    case certifiedMod = 18
    case botHTTPInteractions = 19
}

public struct User: Codable, GatewayData, Equatable {
    // To work around the default access level
    public init(id: Snowflake, username: String, discriminator: String, avatar: String?, bot: Bool?, bio: String?, system: Bool?, mfa_enabled: Bool?, banner: String?, accent_color: Int?, locale: Locale?, verified: Bool?, flags: Int?, premium_type: Int?, public_flags: Int?) {
        self.id = id
        self.username = username
        self.discriminator = discriminator
        self.avatar = avatar
        self.bot = bot
        self.bio = bio
        self.system = system
        self.mfa_enabled = mfa_enabled
        self.banner = banner
        self.accent_color = accent_color
        self.locale = locale
        self.verified = verified
        self.flags = flags
        self.premium_type = premium_type
        self.public_flags = public_flags
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: Snowflake
    
    /// Username of this user
    public let username: String
    
    /// Discriminator of this user
    ///
    /// A string in the format #0000
    public let discriminator: String
    
    /// User's avatar hash
    public let avatar: String?
    
    /// If this user is a bot
    public let bot: Bool?
    
    /// Bio of this user
    public let bio: String?
    
    /// If this user is a system user
    public let system: Bool?
    
    /// If the user has 2FA enabled on their account
    public let mfa_enabled: Bool?
    
    /// Banner image hash (nitro-only)
    public let banner: String?
    
    /// Banner color
    public let accent_color: Int?
    public let locale: Locale?
    
    /// If the user's email is verified
    public let verified: Bool?
    public let flags: Int?
    public let premium_type: Int?
    public let public_flags: Int?
}

public struct CurrentUser: Codable, GatewayData {
    /// Phone number associated with this account
    ///
    /// > Will only be present for the current user, and is nil
    /// > if the user did not add a number to the account
    public let phone: String?
    
    /// Email associated with this account
    ///
    /// > Will only be present for the current user
    public let email: String
    
    /// ID of the current user
    public let id: Snowflake
    
    /// Username of this user
    public let username: String
    
    /// Discriminator of this user
    ///
    /// A string in the format #0000
    public let discriminator: String
    
    public let public_flags: Int?
    public let purchased_flags: Int?
    
    public let premium: Bool
    public let nsfw_allowed: Bool
    public let mobile: Bool
    public let desktop: Bool
    public let mfa_enabled: Bool
    public let flags: Int
    
    public let bio: String?
    
    /// Banner color
    public let accent_color: Int?
    
    /// Banner image hash (nitro-only)
    public let banner: String?
    
    /// User's avatar hash
    public let avatar: String?
}

// User profile endpoint is undocumented
public struct UserProfile: Codable, GatewayData {
    public init(connected_accounts: [Connection], guild_member: Member?, premium_guild_since: ISOTimestamp?, premium_since: ISOTimestamp?, mutual_guilds: [MutualGuild]?, user: User) {
        self.connected_accounts = connected_accounts
        self.guild_member = guild_member
        self.premium_guild_since = premium_guild_since
        self.premium_since = premium_since
        self.mutual_guilds = mutual_guilds
        self.user = user
    }
    
    public let connected_accounts: [Connection]
    public let guild_member: Member?
    public let premium_guild_since: ISOTimestamp?
    public let premium_since: ISOTimestamp?
    public let mutual_guilds: [MutualGuild]?
    public let user: User // This user object contains "bio"
}

public extension User {
    var flagsArr: [UserFlags]? {
		flags?.decodeFlags(flags: UserFlags.staff)
    }
}
public extension CurrentUser {
    var flagsArr: [UserFlags] {
        flags.decodeFlags(flags: UserFlags.staff)
    }
}
