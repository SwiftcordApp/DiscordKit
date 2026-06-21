//
//  HashedAssetScopes+.swift
//
//
//  Created by Vincent on 21/6/26.
//

public extension User {
    var avatarAsset: ScopedHashedAsset<UserAvatar>? {
        avatar?.scoped(to: id)
    }

    var bannerAsset: ScopedHashedAsset<UserBanner>? {
        banner?.scoped(to: id)
    }
}

public extension CurrentUser {
    var avatarAsset: ScopedHashedAsset<UserAvatar>? {
        avatar?.scoped(to: id)
    }

    var bannerAsset: ScopedHashedAsset<UserBanner>? {
        banner?.scoped(to: id)
    }
}

public extension Member {
    func avatarAsset(
        userID fallbackUserID: Snowflake? = nil,
        guildID fallbackGuildID: Snowflake? = nil
    ) -> ScopedHashedAsset<GuildMemberAvatar>? {
        guard let avatar,
              let scope = guildMemberAssetScope(userID: fallbackUserID, guildID: fallbackGuildID)
        else { return nil }

        return avatar.scoped(to: scope.userID, in: scope.guildID)
    }

    func bannerAsset(
        userID fallbackUserID: Snowflake? = nil,
        guildID fallbackGuildID: Snowflake? = nil
    ) -> ScopedHashedAsset<GuildMemberBanner>? {
        guard let banner,
              let scope = guildMemberAssetScope(userID: fallbackUserID, guildID: fallbackGuildID)
        else { return nil }

        return banner.scoped(to: scope.userID, in: scope.guildID)
    }

    private func guildMemberAssetScope(
        userID fallbackUserID: Snowflake?,
        guildID fallbackGuildID: Snowflake?
    ) -> GuildMemberAssetScope? {
        guard let userID = user?.id ?? user_id ?? fallbackUserID,
              let guildID = guild_id ?? fallbackGuildID else {
            return nil
        }

        return GuildMemberAssetScope(userID: userID, guildID: guildID)
    }
}

public extension GuildMemberUpdate {
    var avatarAsset: ScopedHashedAsset<GuildMemberAvatar>? {
        avatar?.scoped(to: user.id, in: guild_id)
    }

    var bannerAsset: ScopedHashedAsset<GuildMemberBanner>? {
        banner?.scoped(to: user.id, in: guild_id)
    }
}

public extension Guild {
    var iconAsset: ScopedHashedAsset<GuildIcon>? {
        icon?.scoped(to: id)
    }

    var bannerAsset: ScopedHashedAsset<GuildBanner>? {
        banner?.scoped(to: id)
    }
}

public extension StickerPack {
    var bannerAsset: ScopedHashedAsset<StickerPackBanner>? {
        banner_asset_id?.scoped()
    }
}

public extension UserProfileBadge {
    var iconAsset: ScopedHashedAsset<UserProfileBadgeIcon> {
        icon.scoped()
    }
}
