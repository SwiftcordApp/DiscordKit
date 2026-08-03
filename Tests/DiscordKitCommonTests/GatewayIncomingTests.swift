//
//  GatewayIncomingTests.swift
//

import XCTest
@testable import DiscordKitCore

final class GatewayIncomingTests: XCTestCase {
    func testUnknownOpcodeDecodesEnvelope() throws {
        let incoming = try decodeGatewayIncoming("""
        {"op":123,"s":42,"t":null,"d":{"ignored":true}}
        """)

        XCTAssertEqual(incoming.opcode, .unknown)
        XCTAssertEqual(incoming.seq, 42)
        assertUnknown(incoming.data)
    }

    func testUnknownDispatchEventDecodesEnvelope() throws {
        let incoming = try decodeGatewayIncoming("""
        {"op":0,"s":43,"t":"NEW_GATEWAY_EVENT","d":{"ignored":true}}
        """)

        XCTAssertEqual(incoming.opcode, .dispatchEvent)
        XCTAssertEqual(incoming.seq, 43)
        XCTAssertNil(incoming.type)
        assertUnknown(incoming.data)
    }

    func testKnownDispatchDecodeFailurePreservesEnvelope() throws {
        let incoming = try decodeGatewayIncoming("""
        {"op":0,"s":44,"t":"MESSAGE_CREATE","d":{}}
        """)

        XCTAssertEqual(incoming.opcode, .dispatchEvent)
        XCTAssertEqual(incoming.seq, 44)
        XCTAssertEqual(incoming.type, .messageCreate)
        assertUnknown(incoming.data)
    }

    func testGuildEmojisUpdateDispatchDecodes() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":50,
          "t":"GUILD_EMOJIS_UPDATE",
          "d":{
            "guild_id":"guild",
            "emojis":[
              {
                "id":"static-emoji",
                "name":"party_blob",
                "roles":["role-1"],
                "require_colons":true,
                "managed":false,
                "animated":false,
                "available":true
              },
              {
                "id":"animated-emoji",
                "name":"wave_anim",
                "roles":[],
                "require_colons":true,
                "managed":false,
                "animated":true,
                "available":true
              }
            ]
          }
        }
        """)

        XCTAssertEqual(incoming.type, .guildEmojisUpdate)
        guard case .guildEmojisUpdate(let update) = incoming.data else {
            XCTFail("Expected guild emoji update, got \(incoming.data)")
            return
        }

        XCTAssertEqual(update.guild_id, "guild")
        XCTAssertEqual(update.emojis.count, 2)
        XCTAssertEqual(update.emojis[0].id, "static-emoji")
        XCTAssertEqual(update.emojis[0].name, "party_blob")
        XCTAssertEqual(update.emojis[0].roles, ["role-1"])
        XCTAssertFalse(update.emojis[0].animated ?? true)
        XCTAssertEqual(update.emojis[1].id, "animated-emoji")
        XCTAssertTrue(update.emojis[1].animated ?? false)
    }

    func testMessageReactionAddDispatchDecodes() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":51,
          "t":"MESSAGE_REACTION_ADD",
          "d":{
            "user_id":"user",
            "channel_id":"channel",
            "message_id":"message",
            "guild_id":"guild",
            "emoji":{"id":"emoji","name":"party"},
            "message_author_id":"author",
            "burst":true,
            "burst_colors":["#ffffff"],
            "type":1
          }
        }
        """)

        XCTAssertEqual(incoming.type, .messageReactAdd)
        guard case .messageReactionAdd(let reaction) = incoming.data else {
            XCTFail("Expected message reaction add, got \(incoming.data)")
            return
        }

        XCTAssertEqual(reaction.user_id, "user")
        XCTAssertEqual(reaction.channel_id, "channel")
        XCTAssertEqual(reaction.message_id, "message")
        XCTAssertEqual(reaction.guild_id, "guild")
        XCTAssertEqual(reaction.emoji.id, "emoji")
        XCTAssertEqual(reaction.emoji.name, "party")
        XCTAssertEqual(reaction.message_author_id, "author")
        XCTAssertTrue(reaction.burst)
        XCTAssertEqual(reaction.burst_colors, ["#ffffff"])
        XCTAssertEqual(reaction.type, 1)
    }

    func testMessageReactionRemoveDispatchDecodes() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":52,
          "t":"MESSAGE_REACTION_REMOVE",
          "d":{
            "user_id":"user",
            "channel_id":"channel",
            "message_id":"message",
            "guild_id":"guild",
            "emoji":{"id":null,"name":"\\\\uD83D\\\\uDE00"},
            "burst":false,
            "type":0
          }
        }
        """)

        XCTAssertEqual(incoming.type, .messageReactRemove)
        guard case .messageReactionRemove(let reaction) = incoming.data else {
            XCTFail("Expected message reaction remove, got \(incoming.data)")
            return
        }

        XCTAssertEqual(reaction.user_id, "user")
        XCTAssertEqual(reaction.channel_id, "channel")
        XCTAssertEqual(reaction.message_id, "message")
        XCTAssertEqual(reaction.guild_id, "guild")
        XCTAssertNil(reaction.emoji.id)
        XCTAssertEqual(reaction.emoji.name, "\\uD83D\\uDE00")
        XCTAssertFalse(reaction.burst)
        XCTAssertEqual(reaction.type, 0)
    }

    func testMessageReactionRemoveAllDispatchDecodes() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":53,
          "t":"MESSAGE_REACTION_REMOVE_ALL",
          "d":{
            "channel_id":"channel",
            "message_id":"message",
            "guild_id":"guild"
          }
        }
        """)

        XCTAssertEqual(incoming.type, .messageReactRemoveAll)
        guard case .messageReactionRemoveAll(let reaction) = incoming.data else {
            XCTFail("Expected message reaction remove all, got \(incoming.data)")
            return
        }

        XCTAssertEqual(reaction.channel_id, "channel")
        XCTAssertEqual(reaction.message_id, "message")
        XCTAssertEqual(reaction.guild_id, "guild")
    }

    func testMessageReactionRemoveEmojiDispatchDecodes() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":54,
          "t":"MESSAGE_REACTION_REMOVE_EMOJI",
          "d":{
            "channel_id":"channel",
            "message_id":"message",
            "guild_id":"guild",
            "emoji":{"id":"emoji","name":"party"}
          }
        }
        """)

        XCTAssertEqual(incoming.type, .messageReactRemoveEmoji)
        guard case .messageReactionRemoveEmoji(let reaction) = incoming.data else {
            XCTFail("Expected message reaction remove emoji, got \(incoming.data)")
            return
        }

        XCTAssertEqual(reaction.channel_id, "channel")
        XCTAssertEqual(reaction.message_id, "message")
        XCTAssertEqual(reaction.guild_id, "guild")
        XCTAssertEqual(reaction.emoji.id, "emoji")
        XCTAssertEqual(reaction.emoji.name, "party")
    }

    func testMessageUpdateDispatchDecodesEndedCall() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":51,
          "t":"MESSAGE_UPDATE",
          "d":{
            "id":"message",
            "channel_id":"channel",
            "call":{
              "participants":["first","second"],
              "ended_timestamp":"2026-07-08T03:17:21.769000+00:00"
            }
          }
        }
        """)

        guard case .messageUpdate(let message) = incoming.data else {
            XCTFail("Expected message update, got \(incoming.data)")
            return
        }

        XCTAssertEqual(message.call?.participants, ["first", "second"])
        XCTAssertNotNil(message.call?.ended_timestamp)
    }

    func testQOSHeartbeatEncodesExplicitNulls() throws {
        let payload = GatewayOutgoing(
            opcode: .qosHeartbeat,
            data: GatewayQOSHeartbeat(seq: nil, qos: nil)
        )
        let object = try encodePayloadObject(payload)
        let data = try XCTUnwrap(object["d"] as? [String: Any])

        XCTAssertEqual(object["op"] as? Int, 40)
        XCTAssertTrue(data["seq"] is NSNull)
        XCTAssertTrue(data["qos"] is NSNull)
    }

    func testGuildSubscriptionEncodesBaselinePatchWithoutChannels() throws {
        let payload = GatewayOutgoing(
            opcode: .updateGuildSubscriptions,
            data: UpdateGuildSubscriptions(subscriptions: [
                "guild": .init(activities: true, threads: true, typing: true)
            ])
        )
        let object = try encodePayloadObject(payload)
        let data = try XCTUnwrap(object["d"] as? [String: Any])
        let subscriptions = try XCTUnwrap(data["subscriptions"] as? [String: Any])
        let guild = try XCTUnwrap(subscriptions["guild"] as? [String: Any])

        XCTAssertEqual(object["op"] as? Int, 37)
        XCTAssertEqual(guild["typing"] as? Bool, true)
        XCTAssertEqual(guild["activities"] as? Bool, true)
        XCTAssertEqual(guild["threads"] as? Bool, true)
        XCTAssertNil(guild["channels"])
        XCTAssertNil(guild["members"])
        XCTAssertNil(guild["member_updates"])
        XCTAssertNil(guild["thread_member_lists"])
    }

    func testGuildSubscriptionEncodesFullRetainedState() throws {
        let payload = GatewayOutgoing(
            opcode: .updateGuildSubscriptions,
            data: UpdateGuildSubscriptions(subscriptions: [
                "guild": .init(
                    activities: true,
                    threads: true,
                    typing: true,
                    members: [],
                    member_updates: false,
                    channels: ["channel": [.init(start: 0, end: 99)]],
                    thread_member_lists: []
                )
            ])
        )
        let object = try encodePayloadObject(payload)
        let data = try XCTUnwrap(object["d"] as? [String: Any])
        let subscriptions = try XCTUnwrap(data["subscriptions"] as? [String: Any])
        let guild = try XCTUnwrap(subscriptions["guild"] as? [String: Any])
        let channels = try XCTUnwrap(guild["channels"] as? [String: Any])
        let ranges = try XCTUnwrap(channels["channel"] as? [[Int]])

        XCTAssertEqual(guild["members"] as? [String], [])
        XCTAssertEqual(guild["member_updates"] as? Bool, false)
        XCTAssertEqual(guild["thread_member_lists"] as? [String], [])
        XCTAssertEqual(ranges, [[0, 99]])
    }

    func testVoiceStateUpdateDispatchDecodes() throws {
        let incoming = try decodeGatewayIncoming("""
        {"op":0,"s":45,"t":"VOICE_STATE_UPDATE","d":\(voiceStateJSON)}
        """)

        XCTAssertEqual(incoming.opcode, .dispatchEvent)
        XCTAssertEqual(incoming.type, .voiceStateUpdate)
        guard case .voiceStateUpdate(let voiceState) = incoming.data else {
            XCTFail("Expected voice state update, got \(incoming.data)")
            return
        }

        XCTAssertEqual(voiceState.guild_id, "guild")
        XCTAssertEqual(voiceState.channel_id, "channel")
        XCTAssertEqual(voiceState.user_id, "user")
        XCTAssertEqual(voiceState.session_id, "voice-session")
    }

    func testVoiceStateUpdateBatchDispatchDecodesArrayPayload() throws {
        let incoming = try decodeGatewayIncoming("""
        {"op":0,"s":46,"t":"VOICE_STATE_UPDATE_BATCH","d":[\(voiceStateJSON)]}
        """)

        XCTAssertEqual(incoming.type, .voiceStateUpdateBatch)
        guard case .voiceStateUpdateBatch(let batch) = incoming.data else {
            XCTFail("Expected voice state update batch, got \(incoming.data)")
            return
        }

        XCTAssertNil(batch.guild_id)
        XCTAssertEqual(batch.voice_states.count, 1)
        XCTAssertEqual(batch.voice_states.first?.user_id, "user")
    }

    func testVoiceServerUpdateDispatchDecodes() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":47,
          "t":"VOICE_SERVER_UPDATE",
          "d":{
            "token":"voice-token",
            "guild_id":"guild",
            "channel_id":"channel",
            "endpoint":"voice.example.com"
          }
        }
        """)

        XCTAssertEqual(incoming.type, .voiceServerUpdate)
        guard case .voiceServerUpdate(let update) = incoming.data else {
            XCTFail("Expected voice server update, got \(incoming.data)")
            return
        }

        XCTAssertEqual(update.token, "voice-token")
        XCTAssertEqual(update.guild_id, "guild")
        XCTAssertEqual(update.channel_id, "channel")
        XCTAssertEqual(update.endpoint, "voice.example.com")
    }

    func testCallCreateDispatchDecodesEmbeddedVoiceStates() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":48,
          "t":"CALL_CREATE",
          "d":{
            "channel_id":"channel",
            "message_id":"message",
            "region":"us-central",
            "ringing":["user"],
            "unavailable":false,
            "voice_states":[\(voiceStateJSON)]
          }
        }
        """)

        XCTAssertEqual(incoming.type, .callCreate)
        guard case .callCreate(let call) = incoming.data else {
            XCTFail("Expected call create, got \(incoming.data)")
            return
        }

        XCTAssertEqual(call.channel_id, "channel")
        XCTAssertEqual(call.message_id, "message")
        XCTAssertEqual(call.voice_states?.first?.session_id, "voice-session")
    }

    func testReadySupplementalDispatchDecodesInitialVoiceStates() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":49,
          "t":"READY_SUPPLEMENTAL",
          "d":{
            "guilds":[{
              "id":"guild",
              "voice_states":[{
                "channel_id":"channel",
                "user_id":"user",
                "session_id":"voice-session",
                "deaf":false,
                "mute":false,
                "self_deaf":false,
                "self_mute":false,
                "connected_at":1791234567890
              }],
              "members":[],
              "presences":[],
              "activity_instances":[]
            }],
            "merged_members":[[]],
            "merged_presences":{
              "guilds":[],
              "friends":[]
            },
            "lazy_private_channels":[]
          }
        }
        """)

        XCTAssertEqual(incoming.type, .readySupplemental)
        guard case .readySupplemental(let supplemental) = incoming.data else {
            XCTFail("Expected ready supplemental, got \(incoming.data)")
            return
        }

        let guild = try XCTUnwrap(supplemental.guilds?.first)
        let voiceState = try XCTUnwrap(guild.voice_states?.first)
        XCTAssertEqual(guild.id, "guild")
        XCTAssertNil(voiceState.guild_id)
        XCTAssertEqual(voiceState.channel_id, "channel")
        XCTAssertEqual(voiceState.user_id, "user")
        XCTAssertEqual(voiceState.session_id, "voice-session")
        XCTAssertFalse(voiceState.self_video)
        XCTAssertFalse(voiceState.suppress)
        XCTAssertNotNil(voiceState.connected_at)
    }

    func testReadyDispatchDecodesUserGuildSettings() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":49,
          "t":"READY",
          "d":{
            "v":9,
            "user":{
              "id":"me",
              "username":"current",
              "discriminator":"0",
              "email":"current@example.com",
              "phone":null,
              "flags":0,
              "public_flags":0,
              "purchased_flags":null,
              "premium_type":0,
              "nsfw_allowed":true,
              "mobile":false,
              "desktop":true,
              "mfa_enabled":false
            },
            "users":[],
            "guilds":[],
            "session_id":"session",
            "user_settings_proto":"",
            "private_channels":[],
            "merged_members":[],
            "read_state":{"entries":[]},
            "notification_settings":{"flags":48},
            "user_guild_settings":{
              "version":12,
              "partial":false,
              "entries":[{
                "guild_id":"guild",
                "muted":true,
                "mute_config":{"end_time":"2026-07-24T10:00:00.000Z"},
                "suppress_everyone":true,
                "suppress_roles":true,
                "message_notifications":1,
                "flags":2048,
                "channel_overrides":[{
                  "channel_id":"channel",
                  "muted":true,
                  "mute_config":null,
                  "message_notifications":2,
                  "flags":1024
                }],
                "version":4
              }]
            },
            "auth_token":null,
            "resume_gateway_url":"wss://gateway.discord.gg"
          }
        }
        """)

        guard case .userReady(let ready) = incoming.data else {
            XCTFail("Expected user READY, got \(incoming.data)")
            return
        }
        XCTAssertEqual(ready.user_guild_settings.version, 12)
        XCTAssertFalse(ready.user_guild_settings.partial)
        XCTAssertTrue(ready.notification_settings.usesNewNotifications)
        XCTAssertTrue(ready.notification_settings.mentionsOnAllMessages)
        let entry = try XCTUnwrap(ready.user_guild_settings.entries.first)
        XCTAssertEqual(entry.guild_id, "guild")
        XCTAssertTrue(entry.muted)
        XCTAssertNotNil(entry.mute_config?.end_time)
        XCTAssertTrue(entry.suppress_everyone)
        XCTAssertTrue(entry.suppress_roles)
        XCTAssertEqual(entry.message_notifications, .mentions)
        XCTAssertEqual(entry.flags, 2048)
        let override = try XCTUnwrap(entry.channel_overrides.first)
        XCTAssertEqual(override.channel_id, "channel")
        XCTAssertTrue(override.muted)
        XCTAssertEqual(override.message_notifications, MessageNotifLevel.none)
        XCTAssertEqual(override.flags, 1024)
    }

    func testReadyDispatchDefaultsOptionalAccountAndSupplementalFields() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":50,
          "t":"READY",
          "d":{
            "v":9,
            "user":{
              "id":"me",
              "username":"current",
              "discriminator":"0",
              "premium_type":4
            },
            "users":[],
            "guilds":[],
            "session_id":"session",
            "read_state":{"entries":[]},
            "user_guild_settings":{"entries":[]},
            "notification_settings":{}
          }
        }
        """)

        guard case .userReady(let ready) = incoming.data else {
            XCTFail("Expected user READY, got \(incoming.data)")
            return
        }

        XCTAssertNil(ready.user.email)
        XCTAssertEqual(ready.user.flags.rawValue, 0)
        XCTAssertEqual(ready.user.premium_type, .unknown(4))
        XCTAssertFalse(ready.user.mobile)
        XCTAssertFalse(ready.user.desktop)
        XCTAssertFalse(ready.user.mfa_enabled)
        XCTAssertTrue(ready.user_settings_proto.isEmpty)
        XCTAssertTrue(ready.private_channels.isEmpty)
        XCTAssertTrue(ready.merged_members.isEmpty)
        XCTAssertEqual(ready.resume_gateway_url, URL(string: DiscordKitConfig.default.gateway))
    }

    func testReadyDispatchLossilyDecodesMergedMembersWithoutShiftingGroups() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":51,
          "t":"READY",
          "d":{
            "v":9,
            "user":{"id":"me","username":"current","discriminator":"0"},
            "users":[],
            "guilds":[],
            "session_id":"session",
            "merged_members":[
              [{"user_id":"me","roles":[]}],
              [{"user_id":"invalid","roles":"not-an-array"},null],
              null
            ],
            "read_state":{"entries":[]},
            "user_guild_settings":{"entries":[]},
            "notification_settings":{}
          }
        }
        """)

        guard case .userReady(let ready) = incoming.data else {
            XCTFail("Expected user READY, got \(incoming.data)")
            return
        }

        XCTAssertEqual(ready.merged_members.count, 3)
        let member = try XCTUnwrap(ready.merged_members[0].first)
        XCTAssertEqual(member.user_id, "me")
        XCTAssertEqual(member.joined_at, .distantPast)
        XCTAssertFalse(member.deaf)
        XCTAssertFalse(member.mute)
        XCTAssertTrue(ready.merged_members[1].isEmpty)
        XCTAssertTrue(ready.merged_members[2].isEmpty)
    }

    func testUserGuildSettingsToleratesUnknownValuesAndMalformedSupplementalRows() throws {
        let settings = try DiscordREST.decoder.decode(
            UserGuildSettings.self,
            from: Data("""
            {
              "entries":[
                {
                  "guild_id":"guild",
                  "message_notifications":99,
                  "mute_config":{"end_time":"not-a-date"},
                  "channel_overrides":[
                    {
                      "channel_id":"channel",
                      "message_notifications":98,
                      "mute_config":{"end_time":"also-not-a-date"}
                    },
                    {"channel_id":true}
                  ]
                },
                {"guild_id":true}
              ]
            }
            """.utf8)
        )

        XCTAssertEqual(settings.entries.count, 1)
        let entry = try XCTUnwrap(settings.entries.first)
        XCTAssertEqual(entry.message_notifications, .unknown(99))
        XCTAssertNil(entry.mute_config?.end_time)
        XCTAssertEqual(entry.channel_overrides.count, 1)
        let override = try XCTUnwrap(entry.channel_overrides.first)
        XCTAssertEqual(override.message_notifications, .unknown(98))
        XCTAssertNil(override.mute_config?.end_time)
    }

    func testUserGuildSettingsUpdateDispatchDecodes() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":50,
          "t":"USER_GUILD_SETTINGS_UPDATE",
          "d":{
            "guild_id":null,
            "muted":false,
            "mute_config":null,
            "channel_overrides":[{
              "channel_id":"dm",
              "muted":true,
              "mute_config":{"end_time":"2026-07-24T10:00:00Z"}
            }],
            "version":7
          }
        }
        """)

        XCTAssertEqual(incoming.type, .userGuildSettingsUpdate)
        guard case .userGuildSettingsUpdate(let update) = incoming.data else {
            XCTFail("Expected user guild settings update, got \(incoming.data)")
            return
        }
        XCTAssertNil(update.guild_id)
        XCTAssertEqual(update.version, 7)
        XCTAssertEqual(update.channel_overrides.first?.channel_id, "dm")
        XCTAssertNotNil(update.channel_overrides.first?.mute_config?.end_time)
    }

    func testReadySupplementalDispatchDefaultsMissingMergedPresences() throws {
        let incoming = try decodeGatewayIncoming("""
        {"op":0,"s":50,"t":"READY_SUPPLEMENTAL","d":{}}
        """)

        XCTAssertEqual(incoming.type, .readySupplemental)
        guard case .readySupplemental(let supplemental) = incoming.data else {
            XCTFail("Expected ready supplemental, got \(incoming.data)")
            return
        }

        XCTAssertTrue(supplemental.merged_presences.guilds.isEmpty)
        XCTAssertTrue(supplemental.merged_presences.friends.isEmpty)
    }

    func testPresencesReplaceDefaultsMissingActivities() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":52,
          "t":"PRESENCES_REPLACE",
          "d":[{"user":{"id":"user"},"status":"dnd"}]
        }
        """)

        XCTAssertEqual(incoming.type, .presencesReplace)
        guard case .presencesReplace(let presences) = incoming.data else {
            XCTFail("Expected presences replace, got \(incoming.data)")
            return
        }

        let presence = try XCTUnwrap(presences.first)
        XCTAssertEqual(presence.status, .dnd)
        XCTAssertTrue(presence.activities.isEmpty)
    }

    func testPresenceUpdatePreservesClientActivityExtensions() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":53,
          "t":"PRESENCE_UPDATE",
          "d":{
            "user":{"id":"user"},
            "guild_id":"guild",
            "status":"online",
            "processed_at_timestamp":1791234567890,
            "activities":[
              {"name":"Hang Status","type":6},
              {"name":false,"type":1},
              {"name":"Future Activity","type":99}
            ]
          }
        }
        """)

        guard case .presenceUpdate(let update) = incoming.data else {
            XCTFail("Expected presence update, got \(incoming.data)")
            return
        }

        XCTAssertEqual(update.status, .online)
        XCTAssertEqual(update.processed_at_timestamp, 1_791_234_567_890)
        XCTAssertEqual(update.activities.count, 2)
        XCTAssertEqual(update.activities[0].type, .hangStatus)
        XCTAssertNil(update.activities[0].created_at)
        XCTAssertEqual(update.activities[1].type, .unknown(99))

        let normalized = NormalizedPresence(update: update)
        XCTAssertEqual(normalized.userID, "user")
        XCTAssertEqual(normalized.scope, .guild("guild"))
        XCTAssertEqual(normalized.status, .online)
        XCTAssertEqual(normalized.clientStatus, update.client_status)
        XCTAssertEqual(normalized.activities.count, 2)
        XCTAssertEqual(normalized.processedAtTimestamp, 1_791_234_567_890)

        let encoded = try encodeObject(update)
        let activities = try XCTUnwrap(encoded["activities"] as? [[String: Any]])
        XCTAssertEqual(activities[1]["type"] as? Int, 99)
    }

    func testReadySupplementalDefaultsMissingAndSkipsMalformedActivities() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":54,
          "t":"READY_SUPPLEMENTAL",
          "d":{
            "guilds":[{"id":"guild"}],
            "merged_presences":{
              "guilds":[[{
                "user_id":"guild-user",
                "status":"idle",
                "processed_at_timestamp":1791234567890,
                "activities":[
                  {"name":"Game","type":0},
                  {"name":42,"type":1}
                ]
              }]],
              "friends":[{
                "user_id":"friend-user",
                "status":"online"
              }]
            }
          }
        }
        """)

        guard case .readySupplemental(let supplemental) = incoming.data else {
            XCTFail("Expected ready supplemental, got \(incoming.data)")
            return
        }

        let presence = try XCTUnwrap(supplemental.merged_presences.guilds.first?.first)
        let friendPresence = try XCTUnwrap(supplemental.merged_presences.friends.first)
        XCTAssertEqual(presence.status, .idle)
        XCTAssertEqual(presence.processed_at_timestamp, 1_791_234_567_890)
        XCTAssertEqual(presence.activities.count, 1)
        XCTAssertEqual(presence.activities[0].type, .game)
        XCTAssertNil(presence.activities[0].created_at)
        XCTAssertTrue(friendPresence.activities.isEmpty)

        let normalized = NormalizedPresence(supplemental: presence, scope: .guild("guild"))
        XCTAssertEqual(normalized.userID, "guild-user")
        XCTAssertEqual(normalized.scope, .guild("guild"))
        XCTAssertEqual(normalized.status, .idle)
        XCTAssertEqual(normalized.activities.count, 1)
        XCTAssertEqual(normalized.processedAtTimestamp, 1_791_234_567_890)
    }

    func testGuildMembersChunkUsesOrdinaryPresenceShape() throws {
        let incoming = try decodeGatewayIncoming("""
        {
          "op":0,
          "s":55,
          "t":"GUILD_MEMBERS_CHUNK",
          "d":{
            "guild_id":"guild",
            "members":[],
            "chunk_index":0,
            "chunk_count":1,
            "presences":[{
              "user":{"id":"chunk-user"},
              "status":"dnd",
              "client_status":{"desktop":"online"},
              "activities":[]
            }]
          }
        }
        """)

        guard case .guildMembersChunk(let chunk) = incoming.data else {
            XCTFail("Expected guild members chunk, got \(incoming.data)")
            return
        }

        let presence = try XCTUnwrap(chunk.presences?.first)
        let normalized = NormalizedPresence(update: presence, scope: .guild(chunk.guild_id))
        XCTAssertEqual(normalized.userID, "chunk-user")
        XCTAssertEqual(normalized.scope, .guild("guild"))
        XCTAssertEqual(normalized.status, .dnd)
        XCTAssertEqual(normalized.clientStatus?.desktop, .online)
    }

    func testVoiceStateUpdateEncodesVoiceJoinFields() throws {
        let payload = GatewayOutgoing(
            opcode: .voiceStateUpdate,
            data: GatewayVoiceStateUpdate(
                guild_id: nil,
                channel_id: "channel",
                self_mute: false,
                self_deaf: false,
                self_video: true,
                flags: 0,
                tracks: [GatewayVoiceTrack(type: "video", rid: "100", quality: 100)]
            )
        )
        let object = try encodePayloadObject(payload)
        let data = try XCTUnwrap(object["d"] as? [String: Any])
        let tracks = try XCTUnwrap(data["tracks"] as? [[String: Any]])
        let track = try XCTUnwrap(tracks.first)

        XCTAssertEqual(object["op"] as? Int, 4)
        XCTAssertTrue(data["guild_id"] is NSNull)
        XCTAssertEqual(data["channel_id"] as? String, "channel")
        XCTAssertEqual(data["self_video"] as? Bool, true)
        XCTAssertEqual(data["flags"] as? Int, 0)
        XCTAssertEqual(track["type"] as? String, "video")
        XCTAssertEqual(track["rid"] as? String, "100")
        XCTAssertEqual(track["quality"] as? Int, 100)
    }

    func testCallConnectEncodes() throws {
        let payload = GatewayOutgoing(
            opcode: .callConnect,
            data: GatewayCallConnect(channel_id: "channel")
        )
        let object = try encodePayloadObject(payload)
        let data = try XCTUnwrap(object["d"] as? [String: Any])

        XCTAssertEqual(object["op"] as? Int, 13)
        XCTAssertEqual(data["channel_id"] as? String, "channel")
    }

    func testUserIdentifyPayloadMatchesOfficialShape() throws {
        let originalConfig = DiscordKitConfig.default
        DiscordKitConfig.default = DiscordKitConfig()
        defer { DiscordKitConfig.default = originalConfig }

        let socket = RobustWebSocket(token: "token")
        let payload = GatewayOutgoing(opcode: .identify, data: socket.getIdentify())
        let object = try encodePayloadObject(payload)
        let data = try XCTUnwrap(object["d"] as? [String: Any])
        let properties = try XCTUnwrap(data["properties"] as? [String: Any])
        let clientState = try XCTUnwrap(data["client_state"] as? [String: Any])
        let guildVersions = try XCTUnwrap(clientState["guild_versions"] as? [String: Any])

        XCTAssertEqual(object["op"] as? Int, 2)
        XCTAssertEqual(data["token"] as? String, "token")
        XCTAssertEqual(data["compress"] as? Bool, false)
        XCTAssertEqual(data["capabilities"] as? Int, 1_734_653)
        XCTAssertNil(data["intents"])
        XCTAssertTrue(guildVersions.isEmpty)
        XCTAssertEqual(properties["client_app_state"] as? String, "focused")
        XCTAssertEqual(properties["is_fast_connect"] as? Bool, false)
        XCTAssertEqual(properties["gateway_connect_reasons"] as? String, "")
        XCTAssertTrue(properties["client_event_source"] is NSNull)
        XCTAssertEqual(Set(properties.keys), expectedIdentifyPropertyKeys)
        XCTAssertNil(properties["client_version"])
        XCTAssertNil(properties["os_arch"])
        XCTAssertNil(properties["app_arch"])
        XCTAssertNil(properties["native_build_number"])
    }

    func testSuperPropertiesMatchOfficialWebShape() throws {
        let properties = GatewayConnProperties(
            browser: "Chrome",
            release_channel: "stable",
            os_version: "10.15.7",
            system_locale: "en-US",
            client_build_number: 556_969,
            browser_user_agent: "Mozilla/5.0 Chrome/149.0.0.0 Safari/537.36",
            browser_version: "149.0.0.0",
            referrer: "https://example.com/path",
            utm_source: "newsletter",
            utm_medium: "email",
            utm_campaign: "campaign",
            utm_content: "button",
            utm_term: "discord",
            search_engine: "google",
            mp_keyword: "chat",
            referrer_current: "https://current.example/path",
            utm_source_current: "current-newsletter",
            utm_medium_current: "current-email",
            utm_campaign_current: "current-campaign",
            utm_content_current: "current-button",
            utm_term_current: "current-discord",
            search_engine_current: "duckduckgo",
            mp_keyword_current: "current-chat",
            client_launch_id: "00000000-0000-4000-8000-000000000000",
            launch_signature: "11111111-1111-4111-8111-111111111111",
            client_heartbeat_session_id: "22222222-2222-4222-8222-222222222222"
        )
        let object = try encodeObject(properties)

        XCTAssertEqual(Set(object.keys), expectedSuperPropertyKeysIncludingOptionals)
        XCTAssertEqual(object["browser"] as? String, "Chrome")
        XCTAssertEqual(object["device"] as? String, "")
        XCTAssertEqual(object["release_channel"] as? String, "stable")
        XCTAssertEqual(object["client_build_number"] as? Int, 556_969)
        XCTAssertEqual(object["referring_domain"] as? String, "example.com")
        XCTAssertEqual(object["referring_domain_current"] as? String, "current.example")
        XCTAssertEqual(object["launch_signature"] as? String, "11111111-1111-4111-8111-111111111111")
        XCTAssertEqual(object["client_app_state"] as? String, "unfocused")
        XCTAssertEqual(object["client_heartbeat_session_id"] as? String, "22222222-2222-4222-8222-222222222222")
        XCTAssertTrue(object["client_event_source"] is NSNull)
        XCTAssertNil(object["client_version"])
        XCTAssertNil(object["os_arch"])
        XCTAssertNil(object["app_arch"])
        XCTAssertNil(object["native_build_number"])
    }

    func testDefaultSuperPropertiesUseCapturedWebClientValues() throws {
        let properties = try encodeObject(DiscordKitConfig().properties)
        let launchID = try XCTUnwrap(properties["client_launch_id"] as? String)
        let launchSignature = try XCTUnwrap(properties["launch_signature"] as? String)

        XCTAssertEqual(properties["browser"] as? String, "Chrome")
        XCTAssertEqual(properties["device"] as? String, "")
        XCTAssertEqual(properties["system_locale"] as? String, "en-US")
        XCTAssertEqual(properties["has_client_mods"] as? Bool, false)
        XCTAssertEqual(properties["browser_user_agent"] as? String, "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36")
        XCTAssertEqual(properties["browser_version"] as? String, "149.0.0.0")
        XCTAssertEqual(properties["os_version"] as? String, "10.15.7")
        XCTAssertEqual(properties["referrer"] as? String, "")
        XCTAssertEqual(properties["referring_domain"] as? String, "")
        XCTAssertEqual(properties["referrer_current"] as? String, "")
        XCTAssertEqual(properties["referring_domain_current"] as? String, "")
        XCTAssertEqual(properties["release_channel"] as? String, "stable")
        XCTAssertEqual(properties["client_build_number"] as? Int, 556_969)
        XCTAssertTrue(properties["client_event_source"] is NSNull)
        XCTAssertEqual(launchID, launchID.lowercased())
        XCTAssertEqual(launchSignature, launchSignature.lowercased())
        XCTAssertEqual(properties["client_app_state"] as? String, "unfocused")
        XCTAssertFalse(properties.keys.contains("utm_source"))
        XCTAssertFalse(properties.keys.contains("search_engine"))
        XCTAssertFalse(properties.keys.contains("client_heartbeat_session_id"))
    }

    func testDiscordKitConfigUsesLaunchIdentityOverrides() throws {
        let launchID = "00000000-0000-4000-8000-000000000000"
        let signature = "0f0e0d0c-030a-4108-8706-050402020100"
        let properties = try encodeObject(
            DiscordKitConfig(clientLaunchID: launchID, launchSignature: signature).properties
        )

        XCTAssertEqual(properties["client_launch_id"] as? String, launchID)
        XCTAssertEqual(properties["launch_signature"] as? String, signature)
    }

    func testLaunchIDsAreReusedAcrossPropertyInstances() throws {
        let first = try encodeObject(GatewayConnProperties())
        let second = try encodeObject(GatewayConnProperties())
        let firstLaunchID = try XCTUnwrap(first["client_launch_id"] as? String)
        let secondLaunchID = try XCTUnwrap(second["client_launch_id"] as? String)
        let firstLaunchSignature = try XCTUnwrap(first["launch_signature"] as? String)
        let secondLaunchSignature = try XCTUnwrap(second["launch_signature"] as? String)

        XCTAssertEqual(firstLaunchID, secondLaunchID)
        XCTAssertEqual(firstLaunchSignature, secondLaunchSignature)
    }

    func testFastConnectIdentifyPropertiesOmitMainGatewayFields() throws {
        let properties = GatewayConnProperties(
            client_launch_id: "00000000-0000-4000-8000-000000000000"
        ).addingGatewayIdentifyFields(
            clientAppState: nil,
            isFastConnect: true,
            gatewayConnectReasons: nil,
            installationID: "installation"
        )
        let object = try encodeObject(properties)

        XCTAssertEqual(object["is_fast_connect"] as? Bool, true)
        XCTAssertEqual(object["installation_id"] as? String, "installation")
        XCTAssertEqual(object["client_app_state"] as? String, "unfocused")
        XCTAssertNil(object["gateway_connect_reasons"])
        XCTAssertEqual(Set(object.keys), expectedSuperPropertyKeys.union(["is_fast_connect", "installation_id"]))
    }

    private func decodeGatewayIncoming(_ json: String) throws -> GatewayIncoming {
        try DiscordREST.decoder.decode(GatewayIncoming.self, from: Data(json.utf8))
    }

    private func encodePayloadObject<T: Encodable>(_ value: T) throws -> [String: Any] {
        try encodeObject(value)
    }

    private func encodeObject<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try DiscordREST.encoder.encode(value)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private var voiceStateJSON: String {
        """
        {
          "guild_id":"guild",
          "channel_id":"channel",
          "user_id":"user",
          "session_id":"voice-session",
          "deaf":false,
          "mute":false,
          "self_deaf":false,
          "self_mute":false,
          "self_stream":false,
          "self_video":false,
          "suppress":false,
          "request_to_speak_timestamp":null
        }
        """
    }

    private func assertUnknown(
        _ data: GatewayIncoming.Data,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .unknown = data else {
            XCTFail("Expected unknown gateway data, got \(data)", file: file, line: line)
            return
        }
    }

    private var expectedIdentifyPropertyKeys: Set<String> {
        expectedSuperPropertyKeys.union([
            "client_app_state",
            "is_fast_connect",
            "gateway_connect_reasons"
        ])
    }

    private var expectedSuperPropertyKeys: Set<String> {
        [
            "os",
            "browser",
            "device",
            "system_locale",
            "has_client_mods",
            "browser_user_agent",
            "browser_version",
            "os_version",
            "referrer",
            "referring_domain",
            "referrer_current",
            "referring_domain_current",
            "release_channel",
            "client_build_number",
            "client_event_source",
            "client_launch_id",
            "launch_signature",
            "client_app_state"
        ]
    }

    private var expectedSuperPropertyKeysIncludingOptionals: Set<String> {
        expectedSuperPropertyKeys.union([
            "utm_source",
            "utm_medium",
            "utm_campaign",
            "utm_content",
            "utm_term",
            "search_engine",
            "mp_keyword",
            "utm_source_current",
            "utm_medium_current",
            "utm_campaign_current",
            "utm_content_current",
            "utm_term_current",
            "search_engine_current",
            "mp_keyword_current",
            "client_heartbeat_session_id"
        ])
    }
}
