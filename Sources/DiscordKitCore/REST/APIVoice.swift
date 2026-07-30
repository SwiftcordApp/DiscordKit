// NOTE: This file is auto-generated

import Foundation

public struct CallPreflightResponse: Decodable, Equatable {
    public let ringable: Bool

    public init(ringable: Bool) {
        self.ringable = ringable
    }
}

public struct RingPrivateCallRequest: Encodable, Equatable {
    public let recipients: [Snowflake]?
    public let analytics_location: String?

    public init(recipients: [Snowflake]? = nil, analytics_location: String? = nil) {
        self.recipients = recipients
        self.analytics_location = analytics_location
    }
}

public extension DiscordREST {
    /// List Voice Regions
    ///
    /// > GET: `/voice/regions`
    func listVoiceRegions<T: Decodable>() async throws -> T {
        return try await getReq(
            path: "voice/regions"
        )
    }

    /// Check whether a one-to-one private call may ring its recipient.
    ///
    /// > GET: `/channels/{channel.id}/call`
    func getPrivateCall(_ channelId: Snowflake) async throws -> CallPreflightResponse {
        try await getReq(path: "channels/\(channelId)/call")
    }

    /// Ring recipients of an active private call.
    ///
    /// Omitting `recipients` rings all applicable channel recipients.
    ///
    /// > POST: `/channels/{channel.id}/call/ring`
    func ringPrivateCall(
        _ channelId: Snowflake,
        recipients: [Snowflake]? = nil,
        analyticsLocation: String? = nil
    ) async throws {
        try await postReq(
            path: "channels/\(channelId)/call/ring",
            body: RingPrivateCallRequest(
                recipients: recipients,
                analytics_location: analyticsLocation
            )
        )
    }
}
