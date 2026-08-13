//
//  UserSettingsProto.swift
//  DiscordKit
//
//  Created by Vincent on 5/8/26.
//

import Foundation

public struct UserSettingsProtoResponse: Decodable, Sendable {
    public let settings: String

    public init(settings: String) {
        self.settings = settings
    }

    public var decodedSettings: Data? {
        Data(base64URL: settings)
    }
}

public enum UserSettingsProtoRequestError: LocalizedError, Sendable {
    case rateLimited(retryAfter: TimeInterval)
    case invalidData

    public var errorDescription: String? {
        switch self {
        case .rateLimited:
            "User settings are temporarily rate limited."
        case .invalidData:
            "Discord rejected the user settings data."
        }
    }
}

struct UserSettingsProtoUpdateRequest: Encodable {
    let settings: String
    let requiredDataVersion: UInt32?

    private enum CodingKeys: String, CodingKey {
        case settings
        case requiredDataVersion = "required_data_version"
    }
}

struct UserSettingsProtoErrorResponse: Decodable {
    let code: Int?
}
