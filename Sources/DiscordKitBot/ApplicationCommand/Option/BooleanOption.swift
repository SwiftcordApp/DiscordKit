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
    public init(_ name: String, description: String) {
        type = .boolean

        self.name = name
        self.description = description
    }

    public let type: CommandOptionType

    public let name: String

    public let description: String

    public var required: Bool?
}
