//
//  NewAppCommand.swift
//  
//
//  Created by Vincent Kwok on 10/12/22.
//

import Foundation
import DiscordKitCore

/// A block to build a new application command with the ``AppCommandBuilder``
///
/// > This struct is not designed to be constructed outside of the ``AppCommandBuilder``.
/// > Use methods like ``Client/registerApplicationCommands(guild:_:)-3vqy0``
/// > which allow you to construct commands with an ``AppCommandBuilder``.
public struct NewAppCommand: Encodable {
    /// Name of this application command
    public let name: String
    /// Description of this application command
    public let description: String?
    /// Options of this application command
    public let options: [CommandOption]?
    /// Interaction handler that will be called upon interactions with this command
    let handler: Handler

    enum CodingKeys: CodingKey {
        case name
        case description
        case options
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)

        // Workaround to encode array of protocols
        if let options = options {
            var optContainer = container.nestedUnkeyedContainer(forKey: .options)
            for option in options {
                try optContainer.encode(option)
            }
        }
    }

    /// Create an instance of a ``NewAppCommand``, with options provided as an array without an ``OptionBuilder``
    public init(
        _ name: String, description: String? = nil,
        options: [CommandOption]? = nil,
        handler: @escaping Handler
    ) {
        self.name = name
        self.description = description
        self.options = options
        self.handler = handler
    }

    /// Create an instance of a ``NewAppCommand``, adding options with an ``OptionBuilder``
    public init(
        _ name: String, description: String? = nil,
        @OptionBuilder options: () -> [CommandOption],
        handler: @escaping Handler
    ) {
        self.init(name, description: description, options: options(), handler: handler)
    }

    /// Create an instance of a ``NewAppCommand`` without any options
    public init(
        _ name: String, description: String? = nil,
        handler: @escaping Handler
    ) {
        self.init(name, description: description, options: nil, handler: handler)
    }

    /// An application command handler that will be called on invocation of the command
    public typealias Handler = (_ interaction: CommandData) -> Void
}
