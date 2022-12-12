//
//  AppCommand.swift
//  
//
//  Created by Vincent Kwok on 27/11/22.
//

import Foundation

/// An option in an application command
public struct AppCommandOption: Codable {
    public enum OptionType: Int, Codable {
        case subCommand = 1
        case subCommandGroup = 2
        case string = 3
        case integer = 4
        case boolean = 5
        case user = 6
        case channel = 7
        case role = 8
        case mentionable = 9
        case number = 10
        case attachment = 11
    }

    /// An enum to store either a `Double` or `Int` value for setting the minimum or maximum value of an option
    public enum MinMaxValue: Codable {
        /// Min or max value for an option of ``AppCommandOption/OptionType/number`` type
        case number(Double)
        /// Min or max value for an option of ``AppCommandOption/OptionType/integer`` type
        case integer(Int)

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()

            if let val = try? container.decode(Double.self) {
                self = .number(val)
            } else if let val = try? container.decode(Int.self) {
                self = .integer(val)
            } else {
                throw DecodingError.typeMismatch(
                    Int.self,
                    .init(codingPath: [], debugDescription: "Expected either Int or Double, found neither")
                )
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()

            switch self {
            case .number(let value): try container.encode(value)
            case .integer(let value): try container.encode(value)
            }
        }
    }

    /// The type of this option
    public let type: OptionType

    /// Name of this command
    ///
    /// > Important: Must be 1-32 characters long, matching the following Regex: `^[-_\p{L}\p{N}\p{sc=Deva}\p{sc=Thai}]{1,32}$`
    public let name: String
    /// Description of this command
    ///
    /// > Important: Must be 1-100 characters long
    public let description: String
    /// If this command is required
    public let required: Bool?

    /// Choices for ``OptionType/string``, ``OptionType/integer``,
    /// and ``OptionType/number`` types for the user to pick from
    ///
    /// > Important: There can be a max of 25 choices.
    public let choices: [AppCommandOptionChoice]?
    /// If this command is a subcommand or subcommand group type, these nested options will be its parameters
    public let options: [AppCommandOption]?

    /// Channel types to restrict visibility of command to
    public let channel_types: ChannelType?

    public let min_value: Int?
    public let max_value: Int?

    /// For option type ``OptionType/string``, the minimum allowed length (minimum of 0, maximum of 6000)
    public let min_length: Int?
    /// For option type ``OptionType/string``, the maximum allowed length (minimum of 1, maximum of 6000)
    public let max_length: Int?

    /// If autocomplete interactions are enabled for this option
    ///
    /// Only applicable for ``OptionType/string``, ``OptionType/integer``, or ``OptionType/number`` option types
    public let autocomplete: Bool?
}

public struct AppCommandOptionChoice: Codable {
    public enum OptionValue: Codable {
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
    public let value: OptionValue
}
