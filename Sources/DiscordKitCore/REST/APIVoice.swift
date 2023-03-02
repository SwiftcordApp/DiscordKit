// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// List Voice Regions
    ///
    /// > GET: `/voice/regions`
    func listVoiceRegions<T: Decodable>() async throws -> T {
        return try await getReq(
            path: "voice/regions"
        )
    }
}
