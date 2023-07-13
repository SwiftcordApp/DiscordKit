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
        /// The data payload for application command interactions
        ///
        /// This contains information about the executed command and its options (if present)
        public struct AppCommandData: Codable {
            /// ID of the invoked application command
            public let id: Snowflake
            /// Name of command
            public let name: String
            /// Type of command
            public let type: Int
            /// Options of command (present if the command has options)
            public let options: [OptionData]?

            /// The data representing one option
            public struct OptionData: Codable {
                /// The value of an option
                public enum Value: Encodable {
                    case string(String)
                    case integer(Int)
                    case double(Double)
                    case boolean(Bool) // Discord docs are disappointing

                    public func encode(to encoder: Encoder) throws {
                        var container = encoder.singleValueContainer()
                        switch self {
                        case .string(let val): try container.encode(val)
                        case .integer(let val): try container.encode(val)
                        case .double(let val): try container.encode(val)
                        case .boolean(let val): try container.encode(val)
                        }
                    }

                    /// Get the wrapped `String` value
                    ///
                    /// - Returns: The string value of a certain option if it is present and is of type `String`, otherwise `nil`
                    public func value() -> String? {
                        guard case let .string(val) = self else { return nil }
                        return val
                    }
                    /// Get the wrapped `Int` value
                    ///
                    /// - Returns: The string value of a certain option if it is present and is of type `Int`, otherwise `nil`
                    public func value() -> Int? {
                        guard case let .integer(val) = self else { return nil }
                        return val
                    }
                    /// Get the wrapped `Double` value
                    ///
                    /// - Returns: The string value of a certain option if it is present and is of type `Double`, otherwise `nil`
                    public func value() -> Double? {
                        guard case let .double(val) = self else { return nil }
                        return val
                    }
                    /// Get the wrapped `Bool` value
                    ///
                    /// - Returns: The string value of a certain option if it is present and is of type `Bool`, otherwise `nil`
                    public func value() -> Bool? {
                        guard case let .boolean(val) = self else { return nil }
                        return val
                    }
                }

                /// Name of the option
                public let name: String
                /// Data type of the option
                public let type: CommandOptionType
                /// User-specified value of the option
                public let value: Value?
                /// Nested options, if this is a sub-option
                public let options: [OptionData]?
                /// If this option is focused (only sent for autocomplete options)
                public let focused: Bool?

                enum CodingKeys: CodingKey {
                    case name
                    case type
                    case value
                    case options
                    case focused
                }

                // Custom decodable conformance to "smartly" decode typed data based on provided type
                public init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)

                    name = try container.decode(String.self, forKey: .name)
                    type = try container.decode(CommandOptionType.self, forKey: .type)
                    options = try container.decodeIfPresent([Self].self, forKey: .options)
                    focused = try container.decodeIfPresent(Bool.self, forKey: .focused)
                    switch type {
                    case .integer: value = .integer(try container.decode(Int.self, forKey: .value))
                    case .number: value = .double(try container.decode(Double.self, forKey: .value))
                    case .boolean: value = .boolean(try container.decode(Bool.self, forKey: .value))
                    case .string: value = .string(try container.decode(String.self, forKey: .value))
                    default: value = nil
                    }
                }
            }
        }

        /// The data payload for message component interactions
        ///
        /// This will be sent for all interactions with message components except link buttons
        public struct MessageComponentData: Codable {
            public let custom_id: String
            public let component_type: MessageComponentTypes
        }

        case applicationCommand(AppCommandData)
        case messageComponent(MessageComponentData)
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
        // Data will always be present for every type except PING
        switch type {
        case .applicationCmd, .applicationCmdAutocomplete:
            data = .applicationCommand(try container.decode(Data.AppCommandData.self, forKey: .data))
        case .messageComponent:
            data = .messageComponent(try container.decode(Data.MessageComponentData.self, forKey: .data))
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
