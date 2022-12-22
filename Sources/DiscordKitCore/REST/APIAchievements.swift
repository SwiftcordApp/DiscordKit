// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Get Achievements
    // GET /applications/${ApplicationId}/achievements
    func getAchievements<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/achievements/"
        )
    }
    // MARK: Get Achievement
    // GET /applications/${ApplicationId}/achievements/${AchievementId}
    func getAchievement<T: Decodable>(
        _ applicationId: Snowflake,
        _ achievementId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/achievements/\(achievementId)/"
        )
    }
    // MARK: Create Achievement
    // POST /applications/${ApplicationId}/achievements
    func createAchievement<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "applications/\(applicationId)/achievements/",
            body: body
        )
    }
    // MARK: Update Achievement
    // PATCH /applications/${ApplicationId}/achievements/${AchievementId}
    func updateAchievement<B: Encodable>(
        _ applicationId: Snowflake,
        _ achievementId: Snowflake,
        _ body: B
    ) async throws {
        try await patchReq(
            path: "applications/\(applicationId)/achievements/\(achievementId)/",
            body: body
        )
    }
    // MARK: Delete Achievement
    // DELETE /applications/${ApplicationId}/achievements/${AchievementId}
    func deleteAchievement(
        _ applicationId: Snowflake,
        _ achievementId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "applications/\(applicationId)/achievements/\(achievementId)/"
        )
    }
    // MARK: Update User Achievement
    // PUT /users/${UserId}/applications/${ApplicationId}/achievements/${AchievementId}
    func updateUserAchievement<T: Decodable, B: Encodable>(
        _ userId: Snowflake,
        _ applicationId: Snowflake,
        _ achievementId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "users/\(userId)/applications/\(applicationId)/achievements/\(achievementId)/",
            body: body
        )
    }
    // MARK: Get User Achievements
    // GET /users/@me/applications/${ApplicationId}/achievements
    func getUserAchievements<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "users/@me/applications/\(applicationId)/achievements/"
        )
    }
}
