//
//  File.swift
//  
//
//  Created by Elizabeth (lizclipse) on 09/08/2023.
//

import Foundation
import DiscordKitCore

public struct UserOption: CommandOption {
    public init(_ name: String, description: String, `required`: Bool? = nil, choices: [AppCommandOptionChoice]? = nil, minLength: Int? = nil, maxLength: Int? = nil, autocomplete: Bool? = nil) {
        type = .user

        self.required = `required`
        self.choices = choices
        self.name = name
        self.description = description
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

    /// If autocomplete interactions are enabled for this option
    public let autocomplete: Bool?
}
