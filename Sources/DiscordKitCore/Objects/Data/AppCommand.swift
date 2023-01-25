//
//  AppCommand.swift
//  
//
//  Created by Vincent Kwok on 12/12/22.
//

import Foundation

/// An application command
///
/// > This is pretty incomplete at the moment since it was added as part
/// > of another feature
public struct AppCommand: Codable {
    public enum CommandType: Int, Codable {
        case slash = 1
        case user = 2
        case message = 3

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if container.decodeNil() {
                self = .slash
                return
            }
            guard let type = Self(rawValue: try container.decode(Int.self)) else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: [], debugDescription: "Int value could not be cast to a valid command type"
                ))
            }
            self = type
        }
    }

    public let id: Snowflake
    public let type: CommandType
    public let application_id: Snowflake
    public let guild_id: Snowflake?
    public let name: String
    public let description: String
}

/// The type of an option
public enum CommandOptionType: Int, Codable {
    /// A "sub-command" with no options
    case subCommand = 1
    /// A group for nesting other options
    case subCommandGroup = 2
    /// An option accepting a `String` value
    case string = 3
    /// An option accepting an `Int` value
    case integer = 4
    /// An option accepting a `Bool` value
    case boolean = 5
    /// An option accepting a user as its value
    case user = 6
    /// An option accepting a channel as its value
    case channel = 7
    /// An option accepting a role as its value
    case role = 8
    /// An option accepting a @mention as its value
    case mentionable = 9
    /// An option accepting  a `Double` value
    case number = 10
    /// An option accepting a file attachment as its value
    case attachment = 11
}
