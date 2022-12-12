//
//  Interaction.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

// TODO: Impliment other interaction structs

public enum InteractionType: Int, Codable {
    case ping = 1
    case applicationCmd = 2
    case messageComponent = 3
    case applicationCmdAutocomplete = 4
    case modalSubmit = 5
}

/// An interaction struct, sent in response to an interaction
public struct Interaction: Decodable {
    /// ID of the interaction
    public let id: Snowflake
    /// ID of the application this interaction is for
    public let applicationID: Snowflake

    /// Type of interaction
    public let type: InteractionType

    public let data: Data?

    public let guildID: Snowflake?
    public let channelID: Snowflake?
    public let member: Member?
    public let user: User?

    /// Continuation token for responding to the interaction
    public let token: String

    /// Interaction version - always 1
    public let version: Int

    /// For components, the message they were attached to
    public let message: Message?

    public let appPermissions: String?

    public let locale: String?

    public let guildLocale: String?

    /// The data payload of an interaction
    public enum Data {
        public struct AppCommandData: Codable {
            public let id: Snowflake
            public let name: String
            public let type: Int
            public let options: [OptionData]?

            public struct OptionData: Codable {
                public enum Value: Codable {
                    case string(String)
                    case int(Int)
                    case double(Double)

                    public func encode(to encoder: Encoder) throws {
                        var container = encoder.singleValueContainer()
                        switch self {
                        case .string(let val): try container.encode(val)
                        case .int(let val): try container.encode(val)
                        case .double(let val): try container.encode(val)
                        }
                    }

                    public init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()

                        if let val = try? container.decode(String.self) {
                            self = .string(val)
                        } else if let val = try? container.decode(Int.self) {
                            self = .int(val)
                        } else if let val = try? container.decode(Double.self) {
                            self = .double(val)
                        } else {
                            throw DecodingError.typeMismatch(
                                Double.self,
                                .init(codingPath: [], debugDescription: "Expected either String, Int or Double, found neither")
                            )
                        }
                    }
                }

                public let name: String
                public let type: CommandOptionType
                public let value: Value?
                public let options: [OptionData]?
                public let focused: Bool?
            }
        }

        case applicationCommand(AppCommandData)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case applicationID = "application_id"
        case type
        case data
        case guildID = "guild_id"
        case channelID = "channel_id"
        case member
        case user
        case token
        case version
        case message
        case appPermissions = "app_permissions"
        case locale
        case guildLocale = "guild_locale"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Interaction.CodingKeys.self)

        id = try container.decode(Snowflake.self, forKey: .id)
        applicationID = try container.decode(Snowflake.self, forKey: .applicationID)
        type = try container.decode(InteractionType.self, forKey: .type)
        guildID = try container.decodeIfPresent(Snowflake.self, forKey: .guildID)
        channelID = try container.decodeIfPresent(Snowflake.self, forKey: .channelID)
        member = try container.decodeIfPresent(Member.self, forKey: .member)
        user = try container.decodeIfPresent(User.self, forKey: .user)
        token = try container.decode(String.self, forKey: .token)
        version = try container.decode(Int.self, forKey: .version)
        message = try container.decodeIfPresent(Message.self, forKey: .message)
        appPermissions = try container.decodeIfPresent(String.self, forKey: .appPermissions)
        locale = try container.decodeIfPresent(String.self, forKey: .locale)
        guildLocale = try container.decodeIfPresent(String.self, forKey: .guildLocale)

        // Conditionally decode data based on type
        switch type {
        case .applicationCmd, .applicationCmdAutocomplete:
            if let data = try container.decodeIfPresent(Data.AppCommandData.self, forKey: .data) {
                self.data = .applicationCommand(data)
            } else {
                data = nil
            }
        default: data = nil
        }
    }
}

public struct MessageInteraction: Codable {
    public let id: Snowflake
    public let type: InteractionType
    public let name: String
    public let user: User
    public let member: Member?
}

// MARK: - Interaction Response
public struct InteractionResponse: Encodable {
    public init(type: InteractionResponse.ResponseType, data: InteractionResponse.ResponseData) {
        self.type = type
        self.data = data
    }

    public enum ResponseType: Int, Codable {
        case pong = 1
        case interactionReply = 4
        case deferredInteractionReply = 5
        case deferredUpdateMessage = 6
        case updateMessage = 7
        case appCommandAutocompleteResult = 8
        case modal = 9
    }

    public enum ResponseData: Encodable {
        public struct Message: Codable {
            public init(content: String? = nil, tts: String? = nil, embeds: [Embed]? = nil, allowed_mentions: AllowedMentions? = nil, flags: Int? = nil, components: [MessageComponent]? = nil, attachments: [NewAttachment]? = nil) {
                self.content = content
                self.tts = tts
                self.embeds = embeds
                self.allowed_mentions = allowed_mentions
                self.flags = flags
                self.components = components
                self.attachments = attachments
            }

            public let content: String?
            public let tts: String?
            public let embeds: [Embed]?
            public let allowed_mentions: AllowedMentions?
            public let flags: Int?
            public let components: [MessageComponent]?
            public let attachments: [NewAttachment]?
        }

        case message(Message)
        // case autocompleteResult
        // case modal

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
            case .message(let message): try container.encode(message)
            }
        }
    }

    public let type: ResponseType
    public let data: ResponseData
}
