//
//  AppCommand.swift
//  
//
//  Created by Vincent Kwok on 10/12/22.
//

import Foundation
import DiscordKitCore

public struct NewAppCommand: Encodable {
    let name: String
    let description: String?
    let options: [CommandOption]
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
        var optContainer = container.nestedUnkeyedContainer(forKey: .options)
        for option in options {
            try optContainer.encode(option)
        }
    }

    public init(
        _ name: String, description: String? = nil,
        @OptionBuilder options: () -> [CommandOption],
        handler: @escaping Handler
    ) {
        self.name = name
        self.description = description
        self.options = options()
        self.handler = handler
    }

    /// An application command handler that will be called on invocation of the command
    public typealias Handler = (_ interaction: CommandData) -> Void
}
