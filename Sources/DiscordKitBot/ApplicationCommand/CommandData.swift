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
        optionValues: [OptionData],
        rest: DiscordREST, token: String, interactionID: Snowflake
    ) {
        self.rest = rest
        self.token = token
        self.interactionID = interactionID

        self.optionValues = Self.unwrapOptionDatas(optionValues)
    }

    /// A private reference to the active rest handler for handling actions
    ///
    /// This is a `weak` reference to prevent retain cycles if the backing ``Client``
    /// instance gets deallocated.
    private weak var rest: DiscordREST?

    /// Values of options in this command
    private let optionValues: [String: OptionData]

    // MARK: Parameters for executing callbacks
    /// The token to use when carrying out actions with this interaction
    let token: String
    /// The ID of this interaction
    public let interactionID: Snowflake

    fileprivate static func unwrapOptionDatas(_ options: [OptionData]) -> [String: OptionData] {
        var optValues: [String: OptionData] = [:]
        for optionValue in options {
            optValues[optionValue.name] = optionValue
        }
        return optValues
    }
}

// MARK: - Getter functions for option values
public extension CommandData {
    /// Get the unboxed `String` value of an option
    func optionValue(of name: String) -> String? {
        optionValues[name]?.value?.value()
    }
    /// Get the unboxed `Int` value of an option
    func optionValue(of name: String) -> Int? {
        optionValues[name]?.value?.value()
    }
    /// Get the unboxed `Double` value of an option
    func optionValue(of name: String) -> Double? {
        optionValues[name]?.value?.value()
    }
    /// Get the unboxed `Bool` value of an option
    func optionValue(of name: String) -> Bool? {
        optionValues[name]?.value?.value()
    }

    /// Check if a sub-option is selected, and get its nested options
    ///
    /// This will probably be reworked in the future to provide a more friendly way of
    /// handling sub-options, sub-option groups and nested options.
    func subOption(name: String) -> [String: OptionData.Value]? {
        guard let option = optionValues[name], option.type == .subCommand else { return nil }
        // Throw away options without values as they aren't useful in this situation
        return Self.unwrapOptionDatas(option.options ?? []).compactMapValues { opt in
            opt.value
        }
    }

    /// The wrapped value of an option
    typealias OptionData = Interaction.Data.AppCommandData.OptionData
}

// MARK: - Callback APIs
public extension CommandData {
    /// Reply to this interaction with a plain text response
    func reply(_ content: String) async throws {
        try await rest?.sendInteractionResponse(
            .init(
                type: .interactionReply,
                data: .message(.init(content: content))
            ),
            interactionID: interactionID, token: token
        )
    }
}
