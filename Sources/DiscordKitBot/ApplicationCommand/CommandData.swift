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

        var optValues: [String: Interaction.Data.AppCommandData.OptionData.Value] = [:]
        for optionValue in optionValues {
            optValues[optionValue.name] = optionValue.value
        }
        self.optionValues = optValues
    }

    /// A private reference to the active rest handler for handling actions
    private let rest: DiscordREST

    /// Values of options in this command
    private let optionValues: [String: Interaction.Data.AppCommandData.OptionData.Value?]

    /// The token to use when carrying out actions with this interaction
    let token: String
    /// The ID of this interaction
    public let interactionID: Snowflake

    // MARK: Getter functions for option values
    public func originalOptionValue(of name: String) -> Interaction.Data.AppCommandData.OptionData.Value? {
        optionValues[name] ?? nil // Required to unwrap a double optional into a single optional
    }

    public func optionValue(of name: String) -> String? {
        guard let originalValue = originalOptionValue(of: name), case let .string(val) = originalValue else { return nil }
        return val
    }
    public func optionValue(of name: String) -> Int? {
        guard let originalValue = originalOptionValue(of: name), case let .int(val) = originalValue else { return nil }
        return val
    }
    public func optionValue(of name: String) -> Double? {
        guard let originalValue = originalOptionValue(of: name), case let .double(val) = originalValue else { return nil }
        return val
    }

    public func reply(_ content: String) async throws {
        try await rest.sendInteractionResponse(
            .init(
                type: .interactionReply,
                data: .message(.init(content: content))
            ),
            interactionID: interactionID, token: token
        )
    }
}
