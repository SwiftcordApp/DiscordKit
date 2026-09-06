//
//  SoundboardTests.swift
//  DiscordKitCommonTests
//
//  Created by Vincent on 7/9/26.
//

import XCTest
@testable import DiscordKitCore

final class SoundboardTests: XCTestCase {
    func testDefaultSoundDoesNotRequireGuildOrAvailability() throws {
        let sound = try JSONDecoder().decode(SoundboardSound.self, from: Data("""
        {"sound_id":"1","name":"Quack","volume":0.8,"emoji_name":"🦆"}
        """.utf8))
        XCTAssertTrue(sound.isAvailable)
        XCTAssertNil(sound.guild_id)
        XCTAssertEqual(sound.url.absoluteString, "https://cdn.discordapp.com/soundboard-sounds/1")
    }

    func testCatalogGatewayEventAndUnavailableSound() throws {
        let event = try JSONDecoder().decode(GatewayIncoming.self, from: Data("""
        {"op":0,"s":12,"t":"SOUNDBOARD_SOUNDS","d":{"guild_id":"100","soundboard_sounds":[
          {"sound_id":"200","name":"Bell","volume":1,"available":false}
        ]}}
        """.utf8))
        guard case .soundboardSounds(let catalog) = event.data else { return XCTFail("Wrong event") }
        XCTAssertEqual(catalog.guild_id, "100")
        XCTAssertFalse(try XCTUnwrap(catalog.soundboard_sounds.first).isAvailable)
    }

    func testVoiceEffectAcceptsEmojiOnlyAndSoundEvents() throws {
        for soundFields in ["", ",\"sound_id\":\"200\",\"sound_volume\":0.5"] {
            let event = try JSONDecoder().decode(GatewayIncoming.self, from: Data("""
            {"op":0,"s":13,"t":"VOICE_CHANNEL_EFFECT_SEND","d":{
              "channel_id":"100","user_id":"300"\(soundFields)
            }}
            """.utf8))
            guard case .voiceChannelEffectSend(let effect) = event.data else { return XCTFail("Wrong event") }
            XCTAssertEqual(effect.channel_id, "100")
            XCTAssertEqual(effect.sound_id, soundFields.isEmpty ? nil : "200")
        }
    }
}
