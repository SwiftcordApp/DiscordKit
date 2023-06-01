//  User.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public struct User: Codable, GatewayData, Identifiable, Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

    // To work around the default access level
    public init(id: Snowflake, username: String, discriminator: String, global_name: String?, avatar: HashedAsset?, bot: Bool?, bio: String?, system: Bool?, mfa_enabled: Bool?, banner: HashedAsset?, accent_color: Int?, locale: Locale?, verified: Bool?, flags: User.Flags?, premium_type: PremiumType?, public_flags: User.Flags?) {
        self.id = id
        self.username = username
        self.discriminator = discriminator
        self.global_name = global_name
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

    /// User's Global Name
    public let global_name: String?

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
    public let flags: User.Flags?

    /// The public flags of this user
    ///
    /// > This appears to always be the same as ``CurrentUser/flags``
    public let public_flags: User.Flags?

    /// The type of nitro subscription this user has
    public let premium_type: User.PremiumType?
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

    /// Global Name of this user
    public let global_name: String?

    /// The flags of this user
    ///
    /// Use ``CurrentUser/flagsArr`` for a decoded array of ``UserFlags``.
    public let flags: User.Flags

    /// The public flags of this user
    ///
    /// > This appears to always be the same as ``CurrentUser/flags``
    public let public_flags: User.Flags?

    /// The user's purchased flags
    ///
    /// Temporarily changed to a string to prevent decoding errors.
    ///
    /// > Experiment: If anyone figures out the possible values and function of
    /// > this property, please make a PR with relevant changes :D
    public let purchased_flags: Int?

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
    public init(
        connected_accounts: [Connection],
        guild_member: Member? = nil,
        premium_guild_since: Date? = nil,
        premium_since: Date? = nil,
        premium_type: User.PremiumType? = nil,
        mutual_guilds: [MutualGuild]? = nil,
        user: User
    ) {
        self.connected_accounts = connected_accounts
        self.guild_member = guild_member
        self.premium_guild_since = premium_guild_since
        self.premium_since = premium_since
        self.mutual_guilds = mutual_guilds
        self.premium_type = premium_type
        self.user = user
    }

    public let connected_accounts: [Connection]
    public let guild_member: Member?
    public let premium_guild_since: Date?
    public let premium_since: Date?
    public let premium_type: User.PremiumType?
    public let mutual_guilds: [MutualGuild]?

    /// A more complete ``User`` struct, containing the user's bio, among others.
    public let user: User
}

public extension User {
    /// Creates an instance of ``User`` from a provided ``CurrentUser``
    init(from user: CurrentUser) {
        self.init(
            id: user.id,
            username: user.username,
            discriminator: user.discriminator,
            global_name: user.global_name,
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
            premium_type: user.premium ? .nitro : User.PremiumType.none,
            public_flags: user.public_flags
        )
    }
}
