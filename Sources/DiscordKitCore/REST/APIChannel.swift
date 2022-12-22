// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Get Channel
    // GET /channels/{channel.id}
    func getChannel(id: Snowflake) async throws -> Channel {
        return try await getReq(path: "channels/\(id)")
    }

    // MARK: Get Channel Messages
    // GET /channels/{channel.id}/messages
    func getChannelMsgs(
        id: Snowflake,
        limit: Int = 50,
        around: Snowflake? = nil,
        before: Snowflake? = nil,
        after: Snowflake? = nil
    ) async throws -> [Message] {
        var query = [URLQueryItem(name: "limit", value: String(limit))]
		if around != nil { query.append(URLQueryItem(name: "around", value: around?.description)) } else if before != nil {query.append(URLQueryItem(name: "before", value: before?.description))} else if after != nil { query.append(URLQueryItem(name: "after", value: after?.description)) }

        return try await getReq(path: "channels/\(id)/messages", query: query)
    }

    // MARK: Get Channel Message
    // Ailas of getChannelMsgs with predefined params
    func getChannelMsg(
        id: Snowflake,
        msgID: Snowflake
    ) async throws -> Message {
        if DiscordKitConfig.default.isBot {
            return try await getReq(path: "channels/\(id)/messages/\(msgID)")
        } else {
            // Actual endpoint only available to bots, so we're using a workaround
            let messages = try await getChannelMsgs(id: id, limit: 1, around: msgID)
            guard !messages.isEmpty else {
                throw RequestError.genericError(reason: "Messages endpoint did not return any messages")
            }
            return messages[0]
        }
    }

    // MARK: Create Channel Message
    // POST /channels/{channel.id}/messages
    func createChannelMsg(
        message: NewMessage,
        attachments: [URL] = [],
        id: Snowflake
    ) async throws -> Message {
        return try await postReq(path: "channels/\(id)/messages", body: message, attachments: attachments)
    }

    // MARK: Delete Message
    // DELETE /channels/{channel.id}/messages/{message.id}
    func deleteMsg(
        id: Snowflake,
        msgID: Snowflake
    ) async throws {
        return try await deleteReq(path: "channels/\(id)/messages/\(msgID)")
    }

    // MARK: Acknowledge Message Read (Undocumented endpoint!)
    // POST /channels/{channel.id}/messages/{message.id}/ack
    func ackMessageRead(
        id: Snowflake,
        msgID: Snowflake
    ) async throws -> MessageReadAck {
        return try await postReq(path: "channels/\(id)/messages/\(msgID)/ack", body: MessageReadAck(token: nil), attachments: [])
    }

    // MARK: Typing Start (Undocumented endpoint!)
    func typingStart(id: Snowflake) async throws {
        return try await emptyPostReq(path: "channels/\(id)/typing")
    }
    // MARK: Edit Channel
    // PATCH /channels/${ChannelId}
    func editChannel<B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "channels/\(channelId)/",
            body: body
        )
    }
    // MARK: Crosspost Message
    // POST /channels/${ChannelId}/messages/${MessageId}/crosspost
    func crosspostMessage<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/messages/\(messageId)/crosspost/",
            body: body
        )
    }
    // MARK: Create Reaction
    // PUT /channels/${ChannelId}/messages/${MessageId}/reactions/${Emoji}/@me
    func createReaction<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ emoji: String,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/@me/",
            body: body
        )
    }
    // MARK: Delete Own Reaction
    // DELETE /channels/${ChannelId}/messages/${MessageId}/reactions/${Emoji}/@me
    func deleteOwnReaction(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ emoji: String
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/@me/"
        )
    }
    // MARK: Delete User Reaction
    // DELETE /channels/${ChannelId}/messages/${MessageId}/reactions/${Emoji}/${UserId}
    func deleteUserReaction(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ emoji: String,
        _ userId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/\(userId)/"
        )
    }
    // MARK: Get Reactions
    // GET /channels/${ChannelId}/messages/${MessageId}/reactions/${Emoji}
    func getReactions<T: Decodable>(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ emoji: String
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/"
        )
    }
    // MARK: Delete All Reactions
    // DELETE /channels/${ChannelId}/messages/${MessageId}/reactions
    func deleteAllReactions(
        _ channelId: Snowflake,
        _ messageId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/messages/\(messageId)/reactions/"
        )
    }
    // MARK: Delete All Reactions for Emoji
    // DELETE /channels/${ChannelId}/messages/${MessageId}/reactions/${Emoji}
    func deleteAllReactionsforEmoji(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ emoji: String
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/"
        )
    }
    // MARK: Edit Message
    // PATCH /channels/${ChannelId}/messages/${MessageId}
    func editMessage<B: Encodable>(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "channels/\(channelId)/messages/\(messageId)/",
            body: body
        )
    }
    // MARK: Bulk Delete Messages
    // POST /channels/${ChannelId}/messages/bulk-delete
    func bulkDeleteMessages<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/messages/bulk-delete/",
            body: body
        )
    }
    // MARK: Edit Channel Permissions
    // PUT /channels/${ChannelId}/permissions/${OverwriteId}
    func editChannelPermissions<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ overwriteId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "channels/\(channelId)/permissions/\(overwriteId)/",
            body: body
        )
    }
    // MARK: Get Channel Invites
    // GET /channels/${ChannelId}/invites
    func getChannelInvites<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/invites/"
        )
    }
    // MARK: Create Channel Invite
    // POST /channels/${ChannelId}/invites
    func createChannelInvite<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/invites/",
            body: body
        )
    }
    // MARK: Delete Channel Permission
    // DELETE /channels/${ChannelId}/permissions/${OverwriteId}
    func deleteChannelPermission(
        _ channelId: Snowflake,
        _ overwriteId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/permissions/\(overwriteId)/"
        )
    }
    // MARK: Follow Announcement Channel
    // POST /channels/${ChannelId}/followers
    func followAnnouncementChannel<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/followers/",
            body: body
        )
    }
    // MARK: Trigger Typing Indicator
    // POST /channels/${ChannelId}/typing
    func triggerTypingIndicator<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/typing/",
            body: body
        )
    }
    // MARK: Get Pinned Messages
    // GET /channels/${ChannelId}/pins
    func getPinnedMessages<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/pins/"
        )
    }
    // MARK: Pin Message
    // PUT /channels/${ChannelId}/pins/${MessageId}
    func pinMessage<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "channels/\(channelId)/pins/\(messageId)/",
            body: body
        )
    }
    // MARK: Unpin Message
    // DELETE /channels/${ChannelId}/pins/${MessageId}
    func unpinMessage(
        _ channelId: Snowflake,
        _ messageId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/pins/\(messageId)/"
        )
    }
    // MARK: Group DM Add Recipient
    // PUT /channels/${ChannelId}/recipients/${UserId}
    func groupDMAddRecipient<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "channels/\(channelId)/recipients/\(userId)/",
            body: body
        )
    }
    // MARK: Group DM Remove Recipient
    // DELETE /channels/${ChannelId}/recipients/${UserId}
    func groupDMRemoveRecipient(
        _ channelId: Snowflake,
        _ userId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/recipients/\(userId)/"
        )
    }
    // MARK: Start Thread from Message
    // POST /channels/${ChannelId}/messages/${MessageId}/threads
    func startThreadfromMessage<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/messages/\(messageId)/threads/",
            body: body
        )
    }
    // MARK: Start Thread without Message
    // POST /channels/${ChannelId}/threads
    func startThreadwithoutMessage<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/threads/",
            body: body
        )
    }
    // MARK: Start Thread in Forum Channel
    // POST /channels/${ChannelId}/threads
    func startThreadinForumChannel<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/threads/",
            body: body
        )
    }
    // MARK: Join Thread
    // PUT /channels/${ChannelId}/thread-members/@me
    func joinThread<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "channels/\(channelId)/thread-members/@me/",
            body: body
        )
    }
    // MARK: Add Thread Member
    // PUT /channels/${ChannelId}/thread-members/${UserId}
    func addThreadMember<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "channels/\(channelId)/thread-members/\(userId)/",
            body: body
        )
    }
    // MARK: Leave Thread
    // DELETE /channels/${ChannelId}/thread-members/@me
    func leaveThread(
        _ channelId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/thread-members/@me/"
        )
    }
    // MARK: Remove Thread Member
    // DELETE /channels/${ChannelId}/thread-members/${UserId}
    func removeThreadMember(
        _ channelId: Snowflake,
        _ userId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/thread-members/\(userId)/"
        )
    }
    // MARK: Get Thread Member
    // GET /channels/${ChannelId}/thread-members/${UserId}
    func getThreadMember<T: Decodable>(
        _ channelId: Snowflake,
        _ userId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/thread-members/\(userId)/"
        )
    }
    // MARK: List Thread Members
    // GET /channels/${ChannelId}/thread-members
    func listThreadMembers<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/thread-members/"
        )
    }
    // MARK: List Public Archived Threads
    // GET /channels/${ChannelId}/threads/archived/public
    func listPublicArchivedThreads<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/threads/archived/public/"
        )
    }
    // MARK: List Private Archived Threads
    // GET /channels/${ChannelId}/threads/archived/private
    func listPrivateArchivedThreads<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/threads/archived/private/"
        )
    }
    // MARK: List Joined Private Archived Threads
    // GET /channels/${ChannelId}/users/@me/threads/archived/private
    func listJoinedPrivateArchivedThreads<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/users/@me/threads/archived/private/"
        )
    }
}
