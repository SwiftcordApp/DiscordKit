//
//  APIUserSettingsProto.swift
//  DiscordKit
//
//  Created by Vincent on 5/8/26.
//

import Foundation

public extension DiscordREST {
    /// Fetch the user's frecency and favorites settings protobuf.
    func getFrecencyUserSettingsProto() async throws -> UserSettingsProtoResponse {
        let (data, response) = try await makeRequestWithResponse(
            path: "users/@me/settings-proto/2",
            allowsNonSuccessfulResponse: true
        )
        return try decodeUserSettingsProtoResponse(data: data, response: response)
    }

    /// Patch the user's frecency and favorites settings and return Discord's authoritative value.
    func patchFrecencyUserSettingsProto(
        _ proto: Data,
        requiredDataVersion: UInt32? = nil
    ) async throws -> UserSettingsProtoResponse {
        let body = UserSettingsProtoUpdateRequest(
            settings: proto.base64EncodedString(),
            requiredDataVersion: requiredDataVersion
        )
        let (data, response) = try await makeRequestWithResponse(
            path: "users/@me/settings-proto/2",
            body: try DiscordREST.encoder.encode(body),
            method: .patch,
            allowsNonSuccessfulResponse: true
        )
        return try decodeUserSettingsProtoResponse(data: data, response: response)
    }

    private func decodeUserSettingsProtoResponse(
        data: Data,
        response: HTTPURLResponse
    ) throws -> UserSettingsProtoResponse {
        switch response.statusCode {
        case 200..<300:
            do {
                return try DiscordREST.decoder.decode(UserSettingsProtoResponse.self, from: data)
            } catch {
                throw RequestError.jsonDecodingError(error: error)
            }
        case 429:
            let retryAfter = response.value(forHTTPHeaderField: "retry-after")
                .flatMap(Int.init)
                .map(TimeInterval.init) ?? 60
            throw UserSettingsProtoRequestError.rateLimited(retryAfter: retryAfter)
        case 400:
            let errorResponse = try? DiscordREST.decoder.decode(
                UserSettingsProtoErrorResponse.self,
                from: data
            )
            if errorResponse?.code == 50_105 {
                throw UserSettingsProtoRequestError.invalidData
            }
            fallthrough
        default:
            throw RequestError.unexpectedResponseCode(response.statusCode)
        }
    }
}
