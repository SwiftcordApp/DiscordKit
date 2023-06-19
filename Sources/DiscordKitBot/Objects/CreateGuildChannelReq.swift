import DiscordKitCore

struct CreateGuildChannelRed: Codable {
    let name: String
    let type: ChannelType?
    let topic: String?
    let bitrate: Int?
    let user_limit: Int?
    let rate_limit_per_user: Int?
    let position: Int?
    let permission_overwrites: [PermOverwrite]?
    let parent_id: Snowflake?
    let nsfw: Bool?
    let rtc_region: String?
    let video_quality_mode: VideoQualityMode?
    let default_auto_archive_duration: Int?
    // let default_reaction_emoji: 
    // let available_tags:
    // let default_sort_order:
}
