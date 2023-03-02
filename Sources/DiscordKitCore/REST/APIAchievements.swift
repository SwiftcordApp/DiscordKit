// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Get Achievements
    ///
    /// > GET: `/applications/{application.id}/achievements`
    func getAchievements<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/achievements"
        )
    }
    /// Get Achievement
    ///
    /// > GET: `/applications/{application.id}/achievements/{achievement.id}`
    func getAchievement<T: Decodable>(
        _ applicationId: Snowflake,
        _ achievementId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/achievements/\(achievementId)"
        )
    }
    /// Create Achievement
    ///
    /// > POST: `/applications/{application.id}/achievements`
    func createAchievement<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "applications/\(applicationId)/achievements",
            body: body
        )
    }
    /// Update Achievement
    ///
    /// > PATCH: `/applications/{application.id}/achievements/{achievement.id}`
    func updateAchievement<B: Encodable>(
        _ applicationId: Snowflake,
        _ achievementId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "applications/\(applicationId)/achievements/\(achievementId)",
            body: body
        )
    }
    /// Delete Achievement
    ///
    /// > DELETE: `/applications/{application.id}/achievements/{achievement.id}`
    func deleteAchievement(
        _ applicationId: Snowflake,
        _ achievementId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "applications/\(applicationId)/achievements/\(achievementId)"
        )
    }
    /// Update User Achievement
    ///
    /// > PUT: `/users/{user.id}/applications/{application.id}/achievements/{achievement.id}`
    func updateUserAchievement<T: Decodable, B: Encodable>(
        _ userId: Snowflake,
        _ applicationId: Snowflake,
        _ achievementId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "users/\(userId)/applications/\(applicationId)/achievements/\(achievementId)",
            body: body
        )
    }
    /// Get User Achievements
    ///
    /// > GET: `/users/@me/applications/{application.id}/achievements`
    func getUserAchievements<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "users/@me/applications/\(applicationId)/achievements"
        )
    }
}
