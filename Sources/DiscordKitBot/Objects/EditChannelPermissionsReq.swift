import DiscordKitCore

struct EditChannelPermissionsReq: Codable {
    let allow: Permissions?
    let deny: Permissions?
    let type: PermOverwriteType
}