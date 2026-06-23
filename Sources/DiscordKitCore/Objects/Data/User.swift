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
    public init(id: Snowflake, username: String, discriminator: String, global_name: String?, avatar: HashedAsset<UserAvatar>?, bot: Bool?, bio: String?, system: Bool?, mfa_enabled: Bool?, banner: HashedAsset<UserBanner>?, accent_color: Int?, locale: Locale?, verified: Bool?, flags: User.Flags?, premium_type: PremiumType?, public_flags: User.Flags?) {
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
    public let avatar: HashedAsset<UserAvatar>?

    /// If this user is a bot
    public let bot: Bool?

    /// Bio of this user
    public let bio: String?

    /// If this user is a system user
    public let system: Bool?

    /// If this user has 2FA enabled on their account
    public let mfa_enabled: Bool?

    /// Banner image hash (nitro-only)
    public let banner: HashedAsset<UserBanner>?

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
    public let banner: HashedAsset<UserBanner>?

    /// User's avatar hash
    public let avatar: HashedAsset<UserAvatar>?
}

/// A user's profile, containing more data about the user and a fuller ``User`` struct
///
/// > Warning: The user profile endpoint is undocumented, and this struct
/// > was created purely from reverse engineering and observations.
public struct UserProfile: Codable, GatewayData {
    private enum CodingKeys: String, CodingKey {
        case connected_accounts
        case guild_member
        case premium_guild_since
        case premium_since
        case premium_type
        case mutual_guilds
        case mutual_friends
        case mutual_friends_count
        case user_profile
        case guild_member_profile
        case badges
        case guild_badges
        case user
    }

    public init(
        connected_accounts: [Connection],
        guild_member: Member? = nil,
        premium_guild_since: Date? = nil,
        premium_since: Date? = nil,
        premium_type: User.PremiumType? = nil,
        mutual_guilds: [MutualGuild]? = nil,
        mutual_friends: [User]? = nil,
        mutual_friends_count: Int? = nil,
        user_profile: UserProfileDetails? = nil,
        guild_member_profile: GuildMemberProfile? = nil,
        badges: [UserProfileBadge] = [],
        guild_badges: [UserProfileBadge] = [],
        user: User
    ) {
        self.connected_accounts = connected_accounts
        self.guild_member = guild_member
        self.premium_guild_since = premium_guild_since
        self.premium_since = premium_since
        self.mutual_guilds = mutual_guilds
        self.mutual_friends = mutual_friends
        self.mutual_friends_count = mutual_friends_count
        self.user_profile = user_profile
        self.guild_member_profile = guild_member_profile
        self.badges = badges
        self.guild_badges = guild_badges
        self.premium_type = premium_type
        self.user = user
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        connected_accounts = try container.decodeIfPresent([Connection].self, forKey: .connected_accounts) ?? []
        guild_member = try container.decodeIfPresent(Member.self, forKey: .guild_member)
        premium_guild_since = try container.decodeIfPresent(Date.self, forKey: .premium_guild_since)
        premium_since = try container.decodeIfPresent(Date.self, forKey: .premium_since)
        premium_type = try container.decodeIfPresent(User.PremiumType.self, forKey: .premium_type)
        mutual_guilds = try container.decodeIfPresent([MutualGuild].self, forKey: .mutual_guilds)
        mutual_friends = try container.decodeIfPresent([User].self, forKey: .mutual_friends)
        mutual_friends_count = try container.decodeIfPresent(Int.self, forKey: .mutual_friends_count)
        user_profile = try container.decodeIfPresent(UserProfileDetails.self, forKey: .user_profile)
        guild_member_profile = try container.decodeIfPresent(GuildMemberProfile.self, forKey: .guild_member_profile)
        badges = try container.decodeIfPresent([UserProfileBadge].self, forKey: .badges) ?? []
        guild_badges = try container.decodeIfPresent([UserProfileBadge].self, forKey: .guild_badges) ?? []
        user = try container.decode(User.self, forKey: .user)
    }

    public let connected_accounts: [Connection]
    public let guild_member: Member?
    public let premium_guild_since: Date?
    public let premium_since: Date?
    public let premium_type: User.PremiumType?
    public let mutual_guilds: [MutualGuild]?
    public let mutual_friends: [User]?
    public let mutual_friends_count: Int?
    public let user_profile: UserProfileDetails?
    public let guild_member_profile: GuildMemberProfile?
    public let badges: [UserProfileBadge]
    public let guild_badges: [UserProfileBadge]

    /// A more complete ``User`` struct, containing the user's bio, among others.
    public let user: User
}

public struct UserProfileDetails: Codable, GatewayData {
    public let bio: String?
    public let accent_color: Int?
    public let pronouns: String?
    public let profile_effect: UserProfileEffect?
    public let collectibles: [UserProfileCollectible]?
    public let theme_colors: [Int?]?
}

public struct GuildMemberProfile: Codable, GatewayData {
    public let guild_id: Snowflake
    public let pronouns: String?
    public let profile_effect: UserProfileEffect?
    public let collectibles: [UserProfileCollectible]?
    public let theme_colors: [Int?]?
}

public struct UserProfileEffect: Codable, GatewayData {
    /// ``UserProfileEffectProduct`` collectible sku ID
    public let sku_id: Snowflake
//    public let expires_at:
}

public struct UserProfileCollectible: Codable, GatewayData {}

public struct UserProfileBadge: Codable, GatewayData, Identifiable {
    public let id: String
    public let description: String
    public let icon: HashedAsset<UserProfileBadgeIcon>
    public let link: String?
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
