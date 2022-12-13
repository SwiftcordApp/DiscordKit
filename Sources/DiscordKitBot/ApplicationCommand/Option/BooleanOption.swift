//
//  BooleanOption.swift
//  
//
//  Created by Vincent Kwok on 13/12/22.
//

import Foundation
import DiscordKitCore

/// An option accepting `Bool` values for an application command
///
/// To be used with the ``OptionBuilder`` from the ``NewAppCommand`` initialiser
public struct BooleanOption: CommandOption {
    public init(_ name: String, description: String, `required`: Bool? = nil) {
        type = .boolean

        self.name = name
        self.description = description
        self.required = `required`
    }

    public let type: CommandOptionType

    public let name: String

    public let description: String

    public let required: Bool?
}
