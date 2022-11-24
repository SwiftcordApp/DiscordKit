//
//  APIChannel.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 21/2/22.
//

import Foundation

public extension DiscordREST {
    // MARK: Get Channel
    // GET /channels/{channel.id}
    func getChannel(id: Snowflake) async -> Channel? {
        return await getReq(path: "channels/\(id)")
    }

    // MARK: Get Channel Messages
    // GET /channels/{channel.id}/messages
    func getChannelMsgs(
        id: Snowflake,
        limit: Int = 50,
        around: Snowflake? = nil,
        before: Snowflake? = nil,
        after: Snowflake? = nil
    ) async -> [Message]? {
        var query = [URLQueryItem(name: "limit", value: String(limit))]
		if around != nil { query.append(URLQueryItem(name: "around", value: around?.description)) } else if before != nil {query.append(URLQueryItem(name: "before", value: before?.description))} else if after != nil { query.append(URLQueryItem(name: "after", value: after?.description)) }

        return await getReq(path: "channels/\(id)/messages", query: query)
    }

    // MARK: Get Channel Message (Actual endpoint only available to bots, so we're using a workaround)
    // Ailas of getChannelMsgs with predefined params
    func getChannelMsg(
        id: Snowflake,
        msgID: Snowflake
    ) async -> Message? {
        guard let message = await getChannelMsgs(id: id, limit: 1, around: msgID), !message.isEmpty
        else { return nil }
        return message[0]
    }

    // MARK: Create Channel Message
    // POST /channels/{channel.id}/messages
    func createChannelMsg(
        message: NewMessage,
        attachments: [URL],
        id: Snowflake
    ) async -> Message? {
        return await postReq(path: "channels/\(id)/messages", body: message, attachments: attachments)
    }

    // MARK: Delete Message
    // DELETE /channels/{channel.id}/messages/{message.id}
    func deleteMsg(
        id: Snowflake,
        msgID: Snowflake
    ) async -> Bool {
        return await deleteReq(path: "channels/\(id)/messages/\(msgID)")
    }

    // MARK: Acknowledge Message Read (Undocumented endpoint!)
    // POST /channels/{channel.id}/messages/{message.id}/ack
    func ackMessageRead(
        id: Snowflake,
        msgID: Snowflake
    ) async -> MessageReadAck? {
        return await postReq(path: "channels/\(id)/messages/\(msgID)/ack", body: MessageReadAck(token: nil))
    }

    // MARK: Typing Start (Undocumented endpoint!)
    func typingStart(id: Snowflake) async -> Bool {
        return await emptyPostReq(path: "channels/\(id)/typing")
    }
}
