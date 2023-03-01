// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
        /// Get Channel Messages
    ///
    /// > GET: `/channels/{channel.id}/messages`
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

    /// Get Channel Message
    ///
    /// > Ailas of getChannelMsgs with predefined params
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

    /// Create Channel Message
    ///
    /// > POST: `/channels/{channel.id}/messages`
    func createChannelMsg(
        message: NewMessage,
        attachments: [URL] = [],
        id: Snowflake
    ) async throws -> Message {
        return try await postReq(path: "channels/\(id)/messages", body: message, attachments: attachments)
    }

    /// Delete Message
    ///
    /// > DELETE: `/channels/{channel.id}/messages/{message.id}`
    func deleteMsg(
        id: Snowflake,
        msgID: Snowflake
    ) async throws {
        return try await deleteReq(path: "channels/\(id)/messages/\(msgID)")
    }

    /// Acknowledge Message Read (Undocumented endpoint!)
    ///
    /// > POST: `/channels/{channel.id}/messages/{message.id}/ack`
    func ackMessageRead(
        id: Snowflake,
        msgID: Snowflake
    ) async throws -> MessageReadAck {
        return try await postReq(path: "channels/\(id)/messages/\(msgID)/ack", body: MessageReadAck(token: nil), attachments: [])
    }

    /// Typing Start (Undocumented endpoint!)
    ///
    /// > POST: `/channels/{channel.id}/typing`
    func typingStart(id: Snowflake) async throws {
        return try await postReq(path: "channels/\(id)/typing")
    }

    /// Edit Channel
    ///
    /// > PATCH: `/channels/{channel.id}`
    func editChannel<B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "channels/\(channelId)",
            body: body
        )
    }
    /// Create Message
    ///
    /// > POST: `/channels/{channel.id}/messages`
    func createMessage<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/messages",
            body: body
        )
    }
    /// Crosspost Message
    ///
    /// > POST: `/channels/{channel.id}/messages/{message.id}/crosspost`
    func crosspostMessage<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/messages/\(messageId)/crosspost",
            body: body
        )
    }
    /// Create Reaction
    ///
    /// > PUT: `/channels/{channel.id}/messages/{message.id}/reactions/{emoji}/@me`
    func createReaction(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ emoji: String
    ) async throws {
        return try await putReq(
            path: "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/@me"
        )
    }
    /// Delete Own Reaction
    ///
    /// > DELETE: `/channels/{channel.id}/messages/{message.id}/reactions/{emoji}/@me`
    func deleteOwnReaction(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ emoji: String
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/@me"
        )
    }
    /// Delete User Reaction
    ///
    /// > DELETE: `/channels/{channel.id}/messages/{message.id}/reactions/{emoji}/{user.id}`
    func deleteUserReaction(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ emoji: String,
        _ userId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)/\(userId)"
        )
    }
    /// Get Reactions
    ///
    /// > GET: `/channels/{channel.id}/messages/{message.id}/reactions/{emoji}`
    func getReactions<T: Decodable>(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ emoji: String
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)"
        )
    }
    /// Delete All Reactions
    ///
    /// > DELETE: `/channels/{channel.id}/messages/{message.id}/reactions`
    func deleteAllReactions(
        _ channelId: Snowflake,
        _ messageId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/messages/\(messageId)/reactions"
        )
    }
    /// Delete All Reactions for Emoji
    ///
    /// > DELETE: `/channels/{channel.id}/messages/{message.id}/reactions/{emoji}`
    func deleteAllReactionsforEmoji(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ emoji: String
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/messages/\(messageId)/reactions/\(emoji)"
        )
    }
    /// Edit Message
    ///
    /// > PATCH: `/channels/{channel.id}/messages/{message.id}`
    func editMessage<B: Encodable>(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "channels/\(channelId)/messages/\(messageId)",
            body: body
        )
    }
    /// Bulk Delete Messages
    ///
    /// > POST: `/channels/{channel.id}/messages/bulk-delete`
    func bulkDeleteMessages<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/messages/bulk-delete",
            body: body
        )
    }
    /// Edit Channel Permissions
    ///
    /// > PUT: `/channels/{channel.id}/permissions/{overwrite.id}`
    func editChannelPermissions<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ overwriteId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "channels/\(channelId)/permissions/\(overwriteId)",
            body: body
        )
    }
    /// Get Channel Invites
    ///
    /// > GET: `/channels/{channel.id}/invites`
    func getChannelInvites<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/invites"
        )
    }
    /// Create Channel Invite
    ///
    /// > POST: `/channels/{channel.id}/invites`
    func createChannelInvite<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/invites",
            body: body
        )
    }
    /// Delete Channel Permission
    ///
    /// > DELETE: `/channels/{channel.id}/permissions/{overwrite.id}`
    func deleteChannelPermission(
        _ channelId: Snowflake,
        _ overwriteId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/permissions/\(overwriteId)"
        )
    }
    /// Follow Announcement Channel
    ///
    /// > POST: `/channels/{channel.id}/followers`
    func followAnnouncementChannel<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/followers",
            body: body
        )
    }
    /// Trigger Typing Indicator
    ///
    /// > POST: `/channels/{channel.id}/typing`
    func triggerTypingIndicator<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/typing",
            body: body
        )
    }
    /// Get Pinned Messages
    ///
    /// > GET: `/channels/{channel.id}/pins`
    func getPinnedMessages<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/pins"
        )
    }
    /// Pin Message
    ///
    /// > PUT: `/channels/{channel.id}/pins/{message.id}`
    func pinMessage(
        _ channelId: Snowflake,
        _ messageId: Snowflake
    ) async throws {
        return try await putReq(
            path: "channels/\(channelId)/pins/\(messageId)"
        )
    }
    /// Unpin Message
    ///
    /// > DELETE: `/channels/{channel.id}/pins/{message.id}`
    func unpinMessage(
        _ channelId: Snowflake,
        _ messageId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/pins/\(messageId)"
        )
    }
    /// Group DM Add Recipient
    ///
    /// > PUT: `/channels/{channel.id}/recipients/{user.id}`
    func groupDMAddRecipient<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "channels/\(channelId)/recipients/\(userId)",
            body: body
        )
    }
    /// Group DM Remove Recipient
    ///
    /// > DELETE: `/channels/{channel.id}/recipients/{user.id}`
    func groupDMRemoveRecipient(
        _ channelId: Snowflake,
        _ userId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/recipients/\(userId)"
        )
    }
    /// Start Thread from Message
    ///
    /// > POST: `/channels/{channel.id}/messages/{message.id}/threads`
    func startThreadfromMessage<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ messageId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/messages/\(messageId)/threads",
            body: body
        )
    }
    /// Start Thread without Message
    ///
    /// > POST: `/channels/{channel.id}/threads`
    func startThreadwithoutMessage<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/threads",
            body: body
        )
    }
    /// Start Thread in Forum Channel
    ///
    /// > POST: `/channels/{channel.id}/threads`
    func startThreadinForumChannel<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/threads",
            body: body
        )
    }
    /// Join Thread
    ///
    /// > PUT: `/channels/{channel.id}/thread-members/@me`
    func joinThread(
        _ channelId: Snowflake
    ) async throws {
        return try await putReq(
            path: "channels/\(channelId)/thread-members/@me"
        )
    }
    /// Add Thread Member
    ///
    /// > PUT: `/channels/{channel.id}/thread-members/{user.id}`
    func addThreadMember(
        _ channelId: Snowflake,
        _ userId: Snowflake
    ) async throws {
        return try await putReq(
            path: "channels/\(channelId)/thread-members/\(userId)"
        )
    }
    /// Leave Thread
    ///
    /// > DELETE: `/channels/{channel.id}/thread-members/@me`
    func leaveThread(
        _ channelId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/thread-members/@me"
        )
    }
    /// Remove Thread Member
    ///
    /// > DELETE: `/channels/{channel.id}/thread-members/{user.id}`
    func removeThreadMember(
        _ channelId: Snowflake,
        _ userId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "channels/\(channelId)/thread-members/\(userId)"
        )
    }
    /// Get Thread Member
    ///
    /// > GET: `/channels/{channel.id}/thread-members/{user.id}`
    func getThreadMember<T: Decodable>(
        _ channelId: Snowflake,
        _ userId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/thread-members/\(userId)"
        )
    }
    /// List Thread Members
    ///
    /// > GET: `/channels/{channel.id}/thread-members`
    func listThreadMembers<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/thread-members"
        )
    }
    /// List Public Archived Threads
    ///
    /// > GET: `/channels/{channel.id}/threads/archived/public`
    func listPublicArchivedThreads<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/threads/archived/public"
        )
    }
    /// List Private Archived Threads
    ///
    /// > GET: `/channels/{channel.id}/threads/archived/private`
    func listPrivateArchivedThreads<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/threads/archived/private"
        )
    }
    /// List Joined Private Archived Threads
    ///
    /// > GET: `/channels/{channel.id}/users/@me/threads/archived/private`
    func listJoinedPrivateArchivedThreads<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/users/@me/threads/archived/private"
        )
    }
}
