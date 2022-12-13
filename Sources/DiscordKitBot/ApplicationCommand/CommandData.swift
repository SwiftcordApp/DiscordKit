//
//  CommandData.swift
//  
//
//  Created by Vincent Kwok on 12/12/22.
//

import Foundation
import DiscordKitCore

/// Provides methods to get parameters of and respond to application command interactions
public struct CommandData {
    internal init(
        optionValues: [Interaction.Data.AppCommandData.OptionData],
        rest: DiscordREST, token: String, interactionID: Snowflake
    ) {
        self.rest = rest
        self.token = token
        self.interactionID = interactionID

        var optValues: [String: Interaction.Data.AppCommandData.OptionData] = [:]
        for optionValue in optionValues {
            optValues[optionValue.name] = optionValue
        }
        self.optionValues = optValues
    }

    /// A private reference to the active rest handler for handling actions
    private let rest: DiscordREST

    /// Values of options in this command
    private let optionValues: [String: Interaction.Data.AppCommandData.OptionData]

    // MARK: Parameters for executing callbacks
    /// The token to use when carrying out actions with this interaction
    let token: String
    /// The ID of this interaction
    public let interactionID: Snowflake
}

// MARK: - Getter functions for option values
public extension CommandData {
    /// Get the wrapped value of a certain option
    ///
    /// This returns an enum which can either store a `Double`, `Int` or `String` value,
    /// which is hard to work with. See below for wrapper methods, providing the primitive
    /// wrapped type directly, which usually are a better choice.
    ///
    /// ## See Also
    /// Directly get the primitive value of an option with one of the wrapper methods below.
    /// - ``optionValue(of:)-bi3j`` - `Double`
    /// - ``optionValue(of:)-7ssru`` - `Int`
    /// - ``optionValue(of:)-6js4d`` - `String`
    func wrappedOptionValue(of name: String) -> Interaction.Data.AppCommandData.OptionData.Value? {
        optionValues[name]?.value
    }

    /// Get the `String` value of a certain option
    ///
    /// ## See Also
    /// - ``wrappedOptionValue(of:)`` Get the value of the option, wrapped in an Enum
    ///
    /// - Returns: The string value of a certain option if it is present and is of type `String`, otherwise `nil`
    func optionValue(of name: String) -> String? {
        guard let originalValue = wrappedOptionValue(of: name), case let .string(val) = originalValue else { return nil }
        return val
    }
    /// Get the `Int` value of a certain option
    ///
    /// ## See Also
    /// - ``wrappedOptionValue(of:)`` Get the value of the option, wrapped in an Enum
    ///
    /// - Returns: The string value of a certain option if it is present and is of type `Int`, otherwise `nil`
    func optionValue(of name: String) -> Int? {
        guard let originalValue = wrappedOptionValue(of: name), case let .integer(val) = originalValue else { return nil }
        return val
    }
    /// Get the `Double` value of a certain option
    ///
    /// ## See Also
    /// - ``wrappedOptionValue(of:)`` Get the value of the option, wrapped in an Enum
    ///
    /// - Returns: The string value of a certain option if it is present and is of type `Double`, otherwise `nil`
    func optionValue(of name: String) -> Double? {
        guard let originalValue = wrappedOptionValue(of: name), case let .double(val) = originalValue else { return nil }
        return val
    }
    /// Get the `Bool` value of a certain option
    ///
    /// ## See Also
    /// - ``wrappedOptionValue(of:)`` Get the value of the option, wrapped in an Enum
    ///
    /// - Returns: The string value of a certain option if it is present and is of type `Bool`, otherwise `nil`
    func optionValue(of name: String) -> Bool? {
        guard let originalValue = wrappedOptionValue(of: name), case let .boolean(val) = originalValue else { return nil }
        return val
    }

    /// Check if a sub-option is selected
    ///
    /// This will probably be reworked in the future to provide a more friendly way of
    /// handling sub-options, sub-option groups and nested options.
    func isSubOption(name: String) -> Bool? {
        guard let option = optionValues[name] else { return nil }
        return option.type == .subCommand
    }
}

// MARK: - Callback APIs
public extension CommandData {
    /// Reply to this interaction with a plain text response
    func reply(_ content: String) async throws {
        try await rest.sendInteractionResponse(
            .init(
                type: .interactionReply,
                data: .message(.init(content: content))
            ),
            interactionID: interactionID, token: token
        )
    }
}
