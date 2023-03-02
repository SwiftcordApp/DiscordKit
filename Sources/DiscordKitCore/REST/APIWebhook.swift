// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Create Webhook
    ///
    /// > POST: `/channels/{channel.id}/webhooks`
    func createWebhook<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/webhooks",
            body: body
        )
    }
    /// Get Channel Webhooks
    ///
    /// > GET: `/channels/{channel.id}/webhooks`
    func getChannelWebhooks<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/webhooks"
        )
    }
    /// Get Guild Webhooks
    ///
    /// > GET: `/guilds/{guild.id}/webhooks`
    func getGuildWebhooks<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/webhooks"
        )
    }
    /// Get Webhook
    ///
    /// > GET: `/webhooks/{webhook.id}`
    func getWebhook<T: Decodable>(
        _ webhookId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "webhooks/\(webhookId)"
        )
    }
    /// Get Webhook with Token
    ///
    /// > GET: `/webhooks/{webhook.id}/{webhook.token}`
    func getWebhookwithToken<T: Decodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String
    ) async throws -> T {
        return try await getReq(
            path: "webhooks/\(webhookId)/\(webhookToken)"
        )
    }
    /// Edit Webhook
    ///
    /// > PATCH: `/webhooks/{webhook.id}`
    func editWebhook<B: Encodable>(
        _ webhookId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "webhooks/\(webhookId)",
            body: body
        )
    }
    /// Edit Webhook with Token
    ///
    /// > PATCH: `/webhooks/{webhook.id}/{webhook.token}`
    func editWebhookwithToken<B: Encodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "webhooks/\(webhookId)/\(webhookToken)",
            body: body
        )
    }
    /// Delete Webhook
    ///
    /// > DELETE: `/webhooks/{webhook.id}`
    func deleteWebhook(
        _ webhookId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "webhooks/\(webhookId)"
        )
    }
    /// Delete Webhook with Token
    ///
    /// > DELETE: `/webhooks/{webhook.id}/{webhook.token}`
    func deleteWebhookwithToken(
        _ webhookId: Snowflake,
        _ webhookToken: String
    ) async throws {
        try await deleteReq(
            path: "webhooks/\(webhookId)/\(webhookToken)"
        )
    }
    /// Execute Webhook
    ///
    /// > POST: `/webhooks/{webhook.id}/{webhook.token}`
    func executeWebhook<T: Decodable, B: Encodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "webhooks/\(webhookId)/\(webhookToken)",
            body: body
        )
    }
    /// Execute Slack-Compatible Webhook
    ///
    /// > POST: `/webhooks/{webhook.id}/{webhook.token}/slack`
    func executeSlackCompatibleWebhook<T: Decodable, B: Encodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/slack",
            body: body
        )
    }
    /// Execute GitHub-Compatible Webhook
    ///
    /// > POST: `/webhooks/{webhook.id}/{webhook.token}/github`
    func executeGitHubCompatibleWebhook<T: Decodable, B: Encodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/github",
            body: body
        )
    }
    /// Get Webhook Message
    ///
    /// > GET: `/webhooks/{webhook.id}/{webhook.token}/messages/{message.id}`
    func getWebhookMessage<T: Decodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ messageId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        )
    }
    /// Edit Webhook Message
    ///
    /// > PATCH: `/webhooks/{webhook.id}/{webhook.token}/messages/{message.id}`
    func editWebhookMessage<B: Encodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ messageId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)",
            body: body
        )
    }
    /// Delete Webhook Message
    ///
    /// > DELETE: `/webhooks/{webhook.id}/{webhook.token}/messages/{message.id}`
    func deleteWebhookMessage(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ messageId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)"
        )
    }
}
