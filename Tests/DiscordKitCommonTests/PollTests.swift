//
//  PollTests.swift
//  DiscordKit
//
//  Created by Vincent on 30/8/26.
//

import DiscordKitCore
import XCTest

final class PollTests: XCTestCase {
    func testMessagePollDecodesResponseFieldsAndPreservesOmittedCounts() throws {
        let message = try decodeMessage(pollResults: """
        {
          "is_finalized": false,
          "answer_counts": [{"id": 2, "count": 4, "me_voted": true}]
        }
        """)

        let poll = try XCTUnwrap(message.poll)
        XCTAssertEqual(poll.question.text, "Best option?")
        XCTAssertEqual(poll.answers.map(\.answer_id), [1, 2])
        XCTAssertEqual(poll.answers[1].poll_media.emoji?.name, "✅")
        XCTAssertEqual(poll.expiry, Date(timeIntervalSince1970: 1_788_220_800))
        XCTAssertTrue(poll.allow_multiselect)
        XCTAssertEqual(poll.layout_type, 1)
        XCTAssertEqual(poll.results?.answer_counts.first?.count, 4)
        XCTAssertTrue(poll.results?.answer_counts.first?.me_voted == true)
        XCTAssertNil(poll.results?.answer_counts.first(where: { $0.id == 1 }))
    }

    func testMissingPollResultsRemainUnknown() throws {
        XCTAssertNil(try decodeMessage(pollResults: nil).poll?.results)
    }

    func testPollAnswerRequestEncodesStringIDsAndEmptyRemoval() throws {
        let selection = try encodedObject(ReplacePollAnswersRequest(answerIDs: [1, 3]))
        XCTAssertEqual(selection["answer_ids"] as? [String], ["1", "3"])

        let removal = try encodedObject(ReplacePollAnswersRequest(answerIDs: []))
        XCTAssertEqual(removal["answer_ids"] as? [String], [])
    }

    func testPollVoteGatewayEventsDecode() throws {
        let add = try decodeGateway(type: "MESSAGE_POLL_VOTE_ADD")
        guard case .messagePollVoteAdd(let vote) = add.data else {
            return XCTFail("Expected poll vote add")
        }
        XCTAssertEqual(vote.user_id, "user")
        XCTAssertEqual(vote.answer_id, 2)

        let remove = try decodeGateway(type: "MESSAGE_POLL_VOTE_REMOVE")
        guard case .messagePollVoteRemove(let vote) = remove.data else {
            return XCTFail("Expected poll vote remove")
        }
        XCTAssertEqual(vote.message_id, "message")
        XCTAssertEqual(vote.guild_id, "guild")
    }

    func testPollResultMessageAndEmbedTypesDecode() throws {
        let message = try DiscordREST.decoder.decode(Message.self, from: Data("""
        {
          "id":"result",
          "channel_id":"channel",
          "author":{"id":"author","username":"Author","discriminator":"0"},
          "content":"",
          "timestamp":"2026-08-30T00:00:00Z",
          "tts":false,
          "mention_everyone":false,
          "mentions":[],
          "mention_roles":[],
          "attachments":[],
          "embeds":[{"type":"poll_result","fields":[]}],
          "pinned":false,
          "type":46
        }
        """.utf8))

        XCTAssertEqual(message.type, .pollResult)
        XCTAssertEqual(message.embeds.first?.type, .pollResult)
    }

    private func decodeMessage(pollResults: String?) throws -> Message {
        let resultsField = pollResults.map { ",\"results\":\($0)" } ?? ""
        return try DiscordREST.decoder.decode(Message.self, from: Data("""
        {
          "id":"message",
          "channel_id":"channel",
          "author":{"id":"author","username":"Author","discriminator":"0"},
          "content":"",
          "timestamp":"2026-08-30T00:00:00Z",
          "tts":false,
          "mention_everyone":false,
          "mentions":[],
          "mention_roles":[],
          "attachments":[],
          "embeds":[],
          "pinned":false,
          "type":0,
          "poll":{
            "question":{"text":"Best option?"},
            "answers":[
              {"answer_id":1,"poll_media":{"text":"Alpha"}},
              {"answer_id":2,"poll_media":{"text":"Beta","emoji":{"name":"✅"}}}
            ],
            "expiry":"2026-09-01T00:00:00Z",
            "allow_multiselect":true,
            "layout_type":1
            \(resultsField)
          }
        }
        """.utf8))
    }

    private func decodeGateway(type: String) throws -> GatewayIncoming {
        try DiscordREST.decoder.decode(GatewayIncoming.self, from: Data("""
        {
          "op":0,
          "s":1,
          "t":"\(type)",
          "d":{
            "user_id":"user",
            "channel_id":"channel",
            "message_id":"message",
            "guild_id":"guild",
            "answer_id":2
          }
        }
        """.utf8))
    }

    private func encodedObject<T: Encodable>(_ value: T) throws -> [String : Any] {
        let data = try DiscordREST.encoder.encode(value)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String : Any])
    }
}
