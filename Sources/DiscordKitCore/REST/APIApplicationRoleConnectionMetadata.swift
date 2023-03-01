// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Get Application Role Connection Metadata Records
    ///
    /// > GET: `/applications/{application.id}/role-connections/metadata`
    func getApplicationRoleConnectionMetadataRecords<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/role-connections/metadata"
        )
    }
    /// Update Application Role Connection Metadata Records
    ///
    /// > PUT: `/applications/{application.id}/role-connections/metadata`
    func updateApplicationRoleConnectionMetadataRecords<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "applications/\(applicationId)/role-connections/metadata",
            body: body
        )
    }
}
