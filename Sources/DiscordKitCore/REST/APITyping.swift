//
//  APITyping.swift
//  DiscordKit
//
//  Created by Vincent on 7/9/26.
//

import Foundation

public struct TypingCooldowns: Decodable {
    public let message_send_cooldown_ms: Double?
    public let thread_create_cooldown_ms: Double?

    public init(message_send_cooldown_ms: Double? = nil, thread_create_cooldown_ms: Double? = nil) {
        self.message_send_cooldown_ms = message_send_cooldown_ms
        self.thread_create_cooldown_ms = thread_create_cooldown_ms
    }
}

public extension DiscordREST {
    /// Typing responses are either 204 (no body) or 200 with authoritative slowmode cooldowns.
    func typingStartWithCooldowns(id: Snowflake) async throws -> TypingCooldowns {
        let data = try await makeRequest(path: "channels/\(id)/typing", body: nil, method: .post)
        return data.isEmpty ? TypingCooldowns() : try Self.decoder.decode(TypingCooldowns.self, from: data)
    }
}
