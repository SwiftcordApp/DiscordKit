//
//  CmdOption.swift
//  
//
//  Created by Vincent Kwok on 12/12/22.
//

import Foundation
import DiscordKitCore

/// An option in an application command
public protocol CommandOption: Codable {
    /// The type of this option
    var type: CommandOptionType { get }

    /// Name of this command
    ///
    /// > Important: Must be 1-32 characters long, matching the following Regex: `^[-_\p{L}\p{N}\p{sc=Deva}\p{sc=Thai}]{1,32}$`
    var name: String { get }

    /// Description of this command
    ///
    /// > Important: Must be 1-100 characters long
    var description: String { get }
    /// If this command is required
    var required: Bool? { get }

    // If this command is a subcommand or subcommand group type, these nested options will be its parameters
    //var options: [CommandOption]? { get }

    /// Channel types to restrict visibility of command to
    // var channel_types: ChannelType? { get }

    // var min_value: Int? { get }
    // var max_value: Int? { get }
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

public enum CommandOptionType: Int, Codable {
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
enum MinMaxValue: Codable {
    /// Min or max value for an option of ``CommandOptionType/number`` type
    case number(Double)
    /// Min or max value for an option of ``CommandOptionType/integer`` type
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
