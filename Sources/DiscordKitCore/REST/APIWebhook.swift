// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Create Webhook
    // POST /channels/${ChannelId}/webhooks
    func createWebhook<T: Decodable, B: Encodable>(
        _ channelId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "channels/\(channelId)/webhooks/",
            body: body
        )
    }
    // MARK: Get Channel Webhooks
    // GET /channels/${ChannelId}/webhooks
    func getChannelWebhooks<T: Decodable>(
        _ channelId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "channels/\(channelId)/webhooks/"
        )
    }
    // MARK: Get Guild Webhooks
    // GET /guilds/${GuildId}/webhooks
    func getGuildWebhooks<T: Decodable>(
        _ guildId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "guilds/\(guildId)/webhooks/"
        )
    }
    // MARK: Get Webhook
    // GET /webhooks/${WebhookId}
    func getWebhook<T: Decodable>(
        _ webhookId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "webhooks/\(webhookId)/"
        )
    }
    // MARK: Get Webhook with Token
    // GET /webhooks/${WebhookId}/${WebhookToken}
    func getWebhookwithToken<T: Decodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String
    ) async throws -> T {
        return try await getReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/"
        )
    }
    // MARK: Edit Webhook
    // PATCH /webhooks/${WebhookId}
    func editWebhook<B: Encodable>(
        _ webhookId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "webhooks/\(webhookId)/",
            body: body
        )
    }
    // MARK: Edit Webhook with Token
    // PATCH /webhooks/${WebhookId}/${WebhookToken}
    func editWebhookwithToken<B: Encodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/",
            body: body
        )
    }
    // MARK: Delete Webhook
    // DELETE /webhooks/${WebhookId}
    func deleteWebhook(
        _ webhookId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "webhooks/\(webhookId)/"
        )
    }
    // MARK: Delete Webhook with Token
    // DELETE /webhooks/${WebhookId}/${WebhookToken}
    func deleteWebhookwithToken(
        _ webhookId: Snowflake,
        _ webhookToken: String
    ) async throws {
        try await deleteReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/"
        )
    }
    // MARK: Execute Webhook
    // POST /webhooks/${WebhookId}/${WebhookToken}
    func executeWebhook<T: Decodable, B: Encodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/",
            body: body
        )
    }
    // MARK: Execute Slack-Compatible Webhook
    // POST /webhooks/${WebhookId}/${WebhookToken}/slack
    func executeSlackCompatibleWebhook<T: Decodable, B: Encodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/slack/",
            body: body
        )
    }
    // MARK: Execute GitHub-Compatible Webhook
    // POST /webhooks/${WebhookId}/${WebhookToken}/github
    func executeGitHubCompatibleWebhook<T: Decodable, B: Encodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/github/",
            body: body
        )
    }
    // MARK: Get Webhook Message
    // GET /webhooks/${WebhookId}/${WebhookToken}/messages/${MessageId}
    func getWebhookMessage<T: Decodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ messageId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)/"
        )
    }
    // MARK: Edit Webhook Message
    // PATCH /webhooks/${WebhookId}/${WebhookToken}/messages/${MessageId}
    func editWebhookMessage<B: Encodable>(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ messageId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)/",
            body: body
        )
    }
    // MARK: Delete Webhook Message
    // DELETE /webhooks/${WebhookId}/${WebhookToken}/messages/${MessageId}
    func deleteWebhookMessage(
        _ webhookId: Snowflake,
        _ webhookToken: String,
        _ messageId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "webhooks/\(webhookId)/\(webhookToken)/messages/\(messageId)/"
        )
    }
}
