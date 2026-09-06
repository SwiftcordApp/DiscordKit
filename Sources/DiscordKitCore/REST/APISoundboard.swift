//
//  APISoundboard.swift
//  DiscordKitCore
//
//  Created by Vincent on 7/9/26.
//

import Foundation

public extension DiscordREST {
    func getDefaultSoundboardSounds() async throws -> [SoundboardSound] {
        try await getReq(path: "soundboard-default-sounds")
    }

    func sendSoundboardSound(_ sound: SoundboardSound, channelID: Snowflake) async throws {
        struct Body: Encodable {
            let sound_id: Snowflake
            let source_guild_id: Snowflake?
            let emoji_id: Snowflake?
            let emoji_name: String?
        }
        try await postReq(
            path: "channels/\(channelID)/send-soundboard-sound",
            body: Body(
                sound_id: sound.sound_id,
                source_guild_id: sound.guild_id == "0" ? nil : sound.guild_id,
                emoji_id: sound.emoji_id,
                emoji_name: sound.emoji_name
            )
        )
    }
}
