//
//  SubCommandGroup.swift
//
//
//  Created by Elizabeth on 11/02/2025.
//

import DiscordKitCore
import Foundation

public struct SubCommandGroup: CommandOption {
    /// Create a sub-command, optionally with an array of options
    public init(_ name: String, description: String, options: [SubCommand]? = nil) {
        type = .subCommandGroup

        self.name = name
        self.description = description
        self.options = options
    }

    /// Create a sub-command with options built by an ``OptionBuilder``
    public init(
        _ name: String, description: String, @SubCommandOptionBuilder options: () -> [SubCommand]
    ) {
        self.init(name, description: description, options: options())
    }

    public let type: CommandOptionType

    public let name: String

    public let description: String

    public var required: Bool?

    /// If this command is a subcommand or subcommand group type, these nested options will be its parameters
    public let options: [SubCommand]?

    enum CodingKeys: CodingKey {
        case type
        case name
        case description
        case required
        case options
    }

    public func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<SubCommand.CodingKeys> = encoder.container(
            keyedBy: SubCommand.CodingKeys.self)

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

@resultBuilder
public struct SubCommandOptionBuilder {
    public static func buildBlock(_ components: SubCommand...) -> [SubCommand] {
        components
    }
}
