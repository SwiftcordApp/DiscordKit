//
//  SubCommand.swift
//  
//
//  Created by Vincent Kwok on 13/12/22.
//

import Foundation
import DiscordKitCore

public struct SubCommand: CommandOption {
    /// Create a sub-command, optionally with an array of options
    public init(_ name: String, description: String, options: [CommandOption]? = nil) {
        type = .subCommand

        self.name = name
        self.description = description
        self.options = options
    }

    /// Create a sub-command with options built by an ``OptionBuilder``
    public init(_ name: String, description: String, @OptionBuilder options: () -> [CommandOption]) {
        self.init(name, description: description, options: options())
    }

    public let type: CommandOptionType

    public let name: String

    public let description: String

    public var required: Bool?

    /// If this command is a subcommand or subcommand group type, these nested options will be its parameters
    public let options: [CommandOption]?

    enum CodingKeys: CodingKey {
        case type
        case name
        case description
        case required
        case options
    }

    public func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<SubCommand.CodingKeys> = encoder.container(keyedBy: SubCommand.CodingKeys.self)

        try container.encode(self.type, forKey: SubCommand.CodingKeys.type)
        try container.encode(self.name, forKey: SubCommand.CodingKeys.name)
        try container.encode(self.description, forKey: SubCommand.CodingKeys.description)
        try container.encodeIfPresent(self.required, forKey: SubCommand.CodingKeys.required)
        if let options = options {
            var optContainer = container.nestedUnkeyedContainer(forKey: .options)
            for option in options {
                try optContainer.encode(option)
            }
        }
    }
}
