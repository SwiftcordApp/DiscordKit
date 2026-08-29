//
//  APIMessageSearch.swift
//  DiscordKit
//
//  Created by Vincent on 19/7/26.
//

import Foundation

public extension DiscordREST {
    /// Search Guild Messages
    ///
    /// > GET: `/guilds/{guild.id}/messages/search`
    ///
    /// Single-shot: a `202 Accepted` indexing response is returned as
    /// ``MessageSearchOutcome/indexing(retryAfter:)`` and the caller owns the retry loop
    /// > The official client makes at most 6 requests, carrying an incrementing `attempts` query field on retries.
    func searchGuildMessages(
        _ guildID: Snowflake,
        query: MessageSearchQuery
    ) async throws -> MessageSearchOutcome {
        try await searchMessages(
            path: "guilds/\(guildID)/messages/search",
            query: query
        )
    }

    /// Search Channel Messages
    ///
    /// > GET: `/channels/{channel.id}/messages/search`
    ///
    /// Single-shot: a `202 Accepted` indexing response is returned as
    /// ``MessageSearchOutcome/indexing(retryAfter:)`` and the caller owns the retry loop.
    func searchChannelMessages(
        _ channelID: Snowflake,
        query: MessageSearchQuery
    ) async throws -> MessageSearchOutcome {
        try await searchMessages(
            path: "channels/\(channelID)/messages/search",
            query: query
        )
    }

    private func searchMessages(
        path: String,
        query: MessageSearchQuery
    ) async throws -> MessageSearchOutcome {
        let (data, response) = try await makeRequestWithResponse(
            path: path,
            query: query.queryItems()
        )
        guard response.statusCode != 202 else {
            // Match the web client's integer-prefix parsing;
            let retryAfter: TimeInterval
            if let header = response.value(forHTTPHeaderField: "retry-after"),
               let seconds = Scanner(string: header).scanInt(),
               seconds != 0 {
                retryAfter = TimeInterval(seconds)
            } else { // missing, unparseable, or zero values fall back to five seconds.
                retryAfter = 5
            }
            return .indexing(retryAfter: retryAfter)
        }
        do {
            return .results(try DiscordREST.decoder.decode(MessageSearchResults.self, from: data))
        } catch {
            throw RequestError.jsonDecodingError(error: error)
        }
    }
}
