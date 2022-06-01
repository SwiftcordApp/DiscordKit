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
    case premium = 50 // Not actually a possible flag, but included for use in arrays
}

public enum PremiumType: Int, Codable {
    /// No premium subscription
    case none = 0
    /// Nitro classic
    case nitroClassic = 1
    /// Nitro
    case nitro = 2
}

public struct User: Codable, GatewayData, Equatable {
    // To work around the default access level
    public init(id: Snowflake, username: String, discriminator: String, avatar: HashedAsset?, bot: Bool?, bio: String?, system: Bool?, mfa_enabled: Bool?, banner: HashedAsset?, accent_color: Int?, locale: Locale?, verified: Bool?, flags: Int?, premium_type: PremiumType?, public_flags: Int?) {
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
    
    /// ID of this user
    public let id: Snowflake
    
    /// Username of this user
    public let username: String
    
    /// Discriminator of this user
    ///
    /// A string in the format #0000
    public let discriminator: String
    
    /// User's avatar hash
    public let avatar: HashedAsset?
    
    /// If this user is a bot
    public let bot: Bool?
    
    /// Bio of this user
    public let bio: String?
    
    /// If this user is a system user
    public let system: Bool?
    
    /// If this user has 2FA enabled on their account
    public let mfa_enabled: Bool?
    
    /// Banner image hash (nitro-only)
    public let banner: HashedAsset?
    
    /// Banner color
    public let accent_color: Int?
    
    /// Locale of this user
    public let locale: Locale?
    
    /// If the user's email is verified
    public let verified: Bool?
    
    /// The flags of this user
    ///
    /// Use ``User/flagsArr`` for a decoded array of ``UserFlags``.
    public let flags: Int?
    
    /// The public flags of this user
    ///
    /// > This appears to always be the same as ``CurrentUser/flags``
    public let public_flags: Int?
    
    /// The type of nitro subscription this user has
    public let premium_type: PremiumType?
}

/// A subset of the ``User`` struct with less properties and less optionals
///
/// This struct is sent in ``ReadyEvt/user`` and cached in ``CachedState/user``.
/// It contains various properties about the current user, and can be converted to a ``User``
/// by using ``User/init(from:)``.
public struct CurrentUser: Codable, GatewayData, Equatable {
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
    
    /// The flags of this user
    ///
    /// Use ``CurrentUser/flagsArr`` for a decoded array of ``UserFlags``.
    public let flags: Int
    
    /// The public flags of this user
    ///
    /// > This appears to always be the same as ``CurrentUser/flags``
    public let public_flags: Int?
    
    /// The user's purchased flags
    ///
    /// (Guess: This is equivalent to ``User/premium_type``)
    public let purchased_flags: PremiumType?
    
    /// If this user is a premium (nitro) user
    public let premium: Bool
    
    /// If this user has consented to viewing 18+ (NSFW) channels
    public let nsfw_allowed: Bool?
    
    /// If this user has logged in from a mobile client before
    public let mobile: Bool
    
    /// If this user has logged in from a desktop desktop before
    public let desktop: Bool
    
    /// If the user has 2FA enabled on their account
    public let mfa_enabled: Bool
    
    /// Bio of this user
    public let bio: String?
    
    /// Banner color
    public let accent_color: Int?
    
    /// Banner image hash (nitro-only)
    public let banner: HashedAsset?
    
    /// User's avatar hash
    public let avatar: HashedAsset?
}

/// A user's profile, containing more data about the user and a fuller ``User`` struct
///
/// > Warning: The user profile endpoint is undocumented, and this struct
/// > was created purely from reverse engineering and observations.
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
    
    /// A more complete ``User`` struct, containing the user's bio, among others.
    public let user: User
}

public extension User {
    /// Get the decoded array of flags
    var flagsArr: [UserFlags]? {
        guard var decodedFlags = flags?.decodeFlags(flags: UserFlags.staff) else {
            return nil
        }
        if let premiumType = premium_type, premiumType != .none {
            decodedFlags.append(.premium)
        }
        return decodedFlags
    }
}
public extension CurrentUser {
    var flagsArr: [UserFlags] {
        var decodedFlags = flags.decodeFlags(flags: UserFlags.staff)
        if premium { decodedFlags.append(.premium) }
        return decodedFlags
    }
}

public extension User {
    /// Creates an instance of ``User`` from a provided ``CurrentUser``
    init(from user: CurrentUser) {
        self.init(
            id: user.id,
            username: user.username,
            discriminator: user.discriminator,
            avatar: user.avatar,
            bot: false,
            bio: user.bio,
            system: false,
            mfa_enabled: user.mfa_enabled,
            banner: user.banner,
            accent_color: user.accent_color,
            locale: nil,
            verified: nil,
            flags: user.flags,
            premium_type: user.premium ? user.purchased_flags : PremiumType.none,
            public_flags: user.public_flags
        )
    }
}
