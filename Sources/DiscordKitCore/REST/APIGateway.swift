// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Get Gateway
    // GET /gateway
    func getGateway<T: Decodable>() async throws -> T {
        return try await getReq(
            path: "gateway/"
        )
    }
    // MARK: Get Gateway Bot
    // GET /gateway/bot
    func getGatewayBot<T: Decodable>() async throws -> T {
        return try await getReq(
            path: "gateway/bot/"
        )
    }
}
