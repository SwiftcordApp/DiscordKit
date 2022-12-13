//
//  IntegerOption.swift
//  
//
//  Created by Vincent Kwok on 13/12/22.
//

import Foundation
import DiscordKitCore

/// An option accepting `Int` values for an application command
///
/// To be used with the ``OptionBuilder`` from the ``NewAppCommand`` initialiser
public struct IntegerOption: CommandOption {
    public init(_ name: String, description: String, `required`: Bool? = nil, choices: [AppCommandOptionChoice]? = nil, min: Int? = nil, max: Int? = nil, autocomplete: Bool? = nil) {
        type = .integer

        self.name = name
        self.description = description
        self.required = `required`
        self.choices = choices
        self.min_value = min
        self.max_value = max
        self.autocomplete = autocomplete
    }

    public let type: CommandOptionType

    public let name: String

    public let description: String

    public let required: Bool?

    /// Choices for the user to pick from
    ///
    /// > Important: There can be a max of 25 choices.
    public let choices: [AppCommandOptionChoice]?

    /// Minimium value permitted for this option
    public let min_value: Int?
    /// Maximum value permitted for this option
    public let max_value: Int?

    /// If autocomplete interactions are enabled for this option
    public let autocomplete: Bool?
}
