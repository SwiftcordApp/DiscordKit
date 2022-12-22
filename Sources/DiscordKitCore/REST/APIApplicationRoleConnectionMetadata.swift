// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Get Application Role Connection Metadata Records
    // GET /applications/${ApplicationId}/role-connections/metadata
    func getApplicationRoleConnectionMetadataRecords<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/role-connections/metadata/"
        )
    }
    // MARK: Update Application Role Connection Metadata Records
    // PUT /applications/${ApplicationId}/role-connections/metadata
    func updateApplicationRoleConnectionMetadataRecords<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "applications/\(applicationId)/role-connections/metadata/",
            body: body
        )
    }
}
