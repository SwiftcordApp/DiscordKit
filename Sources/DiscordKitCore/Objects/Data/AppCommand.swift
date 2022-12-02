//
//  AppCommand.swift
//  
//
//  Created by Vincent Kwok on 27/11/22.
//

import Foundation

/// An option in an application command
public struct AppCommandOption: Codable {
    public let type: AppCommandOptionType
    public let name: String
    public let description: String
    public let required: Bool?
    public let choices: [AppCommandOptionChoice]?
    public let options: [AppCommandOption]?
    public let channel_types: ChannelType?
    
}

public enum AppCommandOptionType: Int, Codable {
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
    }

    public let name: String
    public let value: OptionValue
}
