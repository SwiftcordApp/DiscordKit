//
//  StringOption.swift
//  
//
//  Created by Vincent Kwok on 12/12/22.
//

import Foundation
import DiscordKitCore

/// An option for an application command that accepts a string value
public struct StringOption: CommandOption {
    public init(_ name: String, description: String, `required`: Bool? = nil, choices: [AppCommandOptionChoice]? = nil, minLength: Int? = nil, maxLength: Int? = nil, autocomplete: Bool? = nil) {
        type = .string

        self.required = `required`
        self.choices = choices
        self.name = name
        self.description = description
        self.min_length = minLength
        self.max_length = maxLength
        self.autocomplete = autocomplete
    }

    public var type: CommandOptionType

    public var required: Bool?

    /// Choices for the user to pick from
    ///
    /// > Important: There can be a max of 25 choices.
    public let choices: [AppCommandOptionChoice]?

    public let name: String
    public let description: String

    /// The minimum allowed length of the value
    ///
    /// This parameter has a minimum of 0 and maximum of 6000
    public let min_length: Int?
    /// The maximum allowed length
    ///
    /// This parameter has a minimum of 1 and maximum of 6000
    public let max_length: Int?

    /// If autocomplete interactions are enabled for this option
    public let autocomplete: Bool?
}
