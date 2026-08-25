//
//  DiscussionChannelTests.swift
//  DiscordKitTests
//
//  Created by Vincent on 16/8/26.
//

import XCTest
@testable import DiscordKitCore

final class DiscussionChannelTests: XCTestCase {
    func testForumAndMediaChannelMetadataDecodes() throws {
        let forum = try JSONDecoder().decode(Channel.self, from: Data("""
        {
          "id":"forum",
          "type":15,
          "flags":16,
          "available_tags":[
            {"id":"tag","name":"Help","moderated":false,"emoji_id":null,"emoji_name":"❓"}
          ],
          "default_sort_order":1
        }
        """.utf8))
        let media = try JSONDecoder().decode(Channel.self, from: Data("""
        {"id":"media","type":16}
        """.utf8))

        XCTAssertTrue(forum.type.isDiscussion)
        XCTAssertTrue(media.type.isDiscussion)
        XCTAssertTrue(forum.flags?.contains(.requireTag) == true)
        XCTAssertEqual(forum.available_tags?.first?.name, "Help")
        XCTAssertEqual(forum.default_sort_order, .creationDate)
    }

    func testThreadPostMetadataAndThumbnailFlagDecodes() throws {
        let thread = try DiscordREST.decoder.decode(Channel.self, from: Data("""
        {
          "id":"thread",
          "type":11,
          "parent_id":"forum",
          "flags":2,
          "applied_tags":["tag"],
          "thread_metadata":{
            "archived":false,
            "auto_archive_duration":1440,
            "archive_timestamp":"2026-08-16T00:00:00Z",
            "locked":false
          }
        }
        """.utf8))
        let attachment = try JSONDecoder().decode(Attachment.self, from: Data("""
        {
          "id":"attachment",
          "filename":"photo.png",
          "content_type":"image/png",
          "size":12,
          "url":"https://cdn.example/photo.png",
          "proxy_url":"https://proxy.example/photo.png",
          "height":100,
          "width":200,
          "flags":2
        }
        """.utf8))

        XCTAssertTrue(thread.flags?.contains(.pinned) == true)
        XCTAssertEqual(thread.applied_tags, ["tag"])
        XCTAssertFalse(thread.thread_metadata?.archived ?? true)
        XCTAssertTrue(attachment.flags?.contains(.isThumbnail) == true)
    }

    func testForumPostDataRequestUsesOnlyThreadIDs() throws {
        let data = try JSONEncoder().encode(ForumPostDataRequest(threadIDs: ["one", "two"]))
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(object.keys.sorted(), ["thread_ids"])
        XCTAssertEqual(object["thread_ids"] as? [String], ["one", "two"])
    }

    func testForumPostDataAllowsUnavailableStarter() throws {
        let response = try JSONDecoder().decode(ForumPostDataResponse.self, from: Data("""
        {
          "threads": {
            "thread": {
              "first_message": null,
              "most_recent_message": null,
              "owner": null
            }
          }
        }
        """.utf8))

        XCTAssertNotNil(response.threads["thread"])
        XCTAssertNil(response.threads["thread"]?.first_message)
    }

    func testCreateForumPostRequestUsesNestedStarterMessage() throws {
        let request = CreateForumPostRequest(
            name: "A useful title",
            autoArchiveDuration: 1440,
            appliedTags: ["help"],
            message: CreateForumPostMessage(
                content: "Starter body",
                attachments: [
                    NewAttachment(
                        id: "0",
                        filename: "example.png",
                        uploaded_filename: "uploaded/example.png"
                    )
                ]
            )
        )

        let data = try JSONEncoder().encode(request)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let message = try XCTUnwrap(object["message"] as? [String: Any])

        XCTAssertEqual(object["name"] as? String, "A useful title")
        XCTAssertEqual(object["auto_archive_duration"] as? Int, 1440)
        XCTAssertEqual(object["applied_tags"] as? [String], ["help"])
        XCTAssertEqual(message["content"] as? String, "Starter body")
        XCTAssertEqual(message["sticker_ids"] as? [String], [])
        XCTAssertEqual((message["attachments"] as? [[String: Any]])?.first?["id"] as? String, "0")
        XCTAssertNil(message["flags"])
    }
}
