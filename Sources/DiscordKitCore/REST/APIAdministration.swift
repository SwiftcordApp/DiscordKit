//
//  APIAdministration.swift
//  DiscordKitCore
//
//  Created by Vincent on 7/9/26.
//

import Foundation

public extension DiscordREST {
    func banGuildMember(guildID: Snowflake, userID: Snowflake, deleteMessageSeconds: Int, reason: String?) async throws {
        let body = try Self.encoder.encode(["delete_message_seconds": deleteMessageSeconds])
        _ = try await makeRequest(
            path: "guilds/\(guildID)/bans/\(userID)", body: body, auditLogReason: reason, method: .put
        )
    }

    /// Guild sticker uploads use individual form fields and a part named `file`.
    func uploadGuildSticker(
        guildID: Snowflake, name: String, description: String, tags: String,
        file: Data, filename: String, mimeType: String
    ) async throws -> Sticker {
        let boundary = "----WebKitFormBoundary\(UUID().uuidString)"
        let body = Self.guildStickerMultipartBody(
            boundary: boundary, name: name, description: description, tags: tags,
            file: file, filename: filename, mimeType: mimeType
        )
        let response = try await makeRequest(
            path: "guilds/\(guildID)/stickers", body: body,
            contentType: "multipart/form-data; boundary=\(boundary)", method: .post
        )
        return try Self.decoder.decode(Sticker.self, from: response)
    }

    static func guildStickerMultipartBody(
        boundary: String, name: String, description: String, tags: String,
        file: Data, filename: String, mimeType: String
    ) -> Data {
        var body = Data()
        for (key, value) in [("name", name), ("description", description), ("tags", tags)] {
            body.append(Data("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)\r\n".utf8))
        }
        let safeFilename = filename.replacingOccurrences(of: "\"", with: "_")
            .replacingOccurrences(of: "\r", with: "_").replacingOccurrences(of: "\n", with: "_")
        body.append(Data("--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"; filename=\"\(safeFilename)\"\r\nContent-Type: \(mimeType)\r\n\r\n".utf8))
        body.append(file)
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        return body
    }

    func leaveGuild(id: Snowflake, lurking: Bool = false) async throws {
        let body = try Self.encoder.encode(["lurking": lurking])
        _ = try await makeRequest(
            path: "users/@me/guilds/\(id)", body: body, method: .delete
        )
    }
}
