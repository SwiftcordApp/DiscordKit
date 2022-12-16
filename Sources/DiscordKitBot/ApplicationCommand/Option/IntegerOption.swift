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
    public init(_ name: String, description: String, choices: [AppCommandOptionChoice]? = nil, autocomplete: Bool? = nil) {
        type = .integer

        self.name = name
        self.description = description
        self.choices = choices
        self.autocomplete = autocomplete
    }

    public let type: CommandOptionType

    public let name: String

    public let description: String

    public var required: Bool?

    /// Choices for the user to pick from
    ///
    /// > Important: There can be a max of 25 choices.
    public let choices: [AppCommandOptionChoice]?

    /// Minimium value permitted for this option
    fileprivate(set) var min_value: Int?
    /// Maximum value permitted for this option
    fileprivate(set) var max_value: Int?

    /// If autocomplete interactions are enabled for this option
    public let autocomplete: Bool?
}

extension IntegerOption {
    /// Require the value of this option to be greater than or equal to this value
    public func min(_ min: Int) -> Self {
        var opt = self
        opt.min_value = min
        return opt
    }

    /// Require the value of this option to be smaller than or equal to this value
    public func max(_ max: Int) -> Self {
        var opt = self
        opt.max_value = max
        return opt
    }
}
