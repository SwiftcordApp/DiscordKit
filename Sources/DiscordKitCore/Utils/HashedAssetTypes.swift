//
//  HashedAssetTypes.swift
//  
//
//  Created by Vincent on 21/6/26.
//

public struct GuildMemberAssetScope: Hashable, Sendable {
    public let userID: Snowflake
    public let guildID: Snowflake

    public init(userID: Snowflake, guildID: Snowflake) {
        self.userID = userID
        self.guildID = guildID
    }
}

@available(*, deprecated, renamed: "GuildMemberAssetScope")
public typealias GuildMemberAssetContext = GuildMemberAssetScope

public enum UserAvatar: HashedAssetKind {
    public typealias Scope = Snowflake
    public typealias Format = AnimatedAssetFormat

    public static func pathComponents(for hash: String, scope userID: Snowflake) -> [String] {
        ["avatars", userID, hash]
    }
}

public enum GuildMemberAvatar: HashedAssetKind {
    public typealias Scope = GuildMemberAssetScope
    public typealias Format = AnimatedAssetFormat

    public static func pathComponents(for hash: String, scope: GuildMemberAssetScope) -> [String] {
        ["guilds", scope.guildID, "users", scope.userID, "avatars", hash]
    }
}

public enum UserBanner: HashedAssetKind {
    public typealias Scope = Snowflake
    public typealias Format = AnimatedAssetFormat

    public static func pathComponents(for hash: String, scope userID: Snowflake) -> [String] {
        ["banners", userID, hash]
    }
}

public enum GuildBanner: HashedAssetKind {
    public typealias Scope = Snowflake
    public typealias Format = AnimatedAssetFormat

    public static func pathComponents(for hash: String, scope guildID: Snowflake) -> [String] {
        ["banners", guildID, hash]
    }
}

public enum GuildMemberBanner: HashedAssetKind {
    public typealias Scope = GuildMemberAssetScope
    public typealias Format = AnimatedAssetFormat

    public static func pathComponents(for hash: String, scope: GuildMemberAssetScope) -> [String] {
        ["guilds", scope.guildID, "users", scope.userID, "banners", hash]
    }
}

public enum GuildIcon: HashedAssetKind {
    public typealias Scope = Snowflake
    public typealias Format = AnimatedAssetFormat

    public static func pathComponents(for hash: String, scope guildID: Snowflake) -> [String] {
        ["icons", guildID, hash]
    }
}

public enum StickerPackBanner: HashedAssetKind {
    public typealias Format = StaticAssetFormat

    public static func pathComponents(for hash: String, scope: Void) -> [String] {
        ["app-assets", "710982414301790216", "store", hash]
    }
}

public enum UserProfileBadgeIcon: HashedAssetKind {
    public typealias Format = PNGAssetFormat

    public static func pathComponents(for hash: String, scope: Void) -> [String] {
        ["badge-icons", hash]
    }
}
