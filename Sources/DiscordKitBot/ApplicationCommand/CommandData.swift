//
//  CommandData.swift
//  
//
//  Created by Vincent Kwok on 12/12/22.
//

import Foundation
import DiscordKitCore

/// Provides methods to get parameters of and respond to application command interactions
public class CommandData {
    internal init(
        optionValues: [OptionData],
        rest: DiscordREST, applicationID: String, interactionID: Snowflake, token: String
    ) {
        self.rest = rest
        self.token = token
        self.interactionID = interactionID
        self.applicationID = applicationID

        self.optionValues = Self.unwrapOptionDatas(optionValues)
    }

    /// A private reference to the active rest handler for handling actions
    ///
    /// This is a `weak` reference to prevent retain cycles if the backing ``Client``
    /// instance gets deallocated.
    private weak var rest: DiscordREST?

    /// The ID of this bot application
    private let applicationID: String

    /// Values of options in this command
    private let optionValues: [String: OptionData]

    /// If this reply has already been deferred
    fileprivate var replyDeferred = false

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
    /// Wrapper function to send an interaction response with the current interaction's ID and token
    private func sendResponse(
        _ response: InteractionResponse.ResponseData?, type: InteractionResponse.ResponseType
    ) async throws {
        try await rest?.sendInteractionResponse(.init(type: type, data: response), interactionID: interactionID, token: token)
    }

    /// Reply to this interaction with a plain text response
    ///
    /// If a prior call to ``deferReply()`` was made, this function automatically
    /// calls ``followUp(_:)`` instead.
    func reply(_ content: String) async throws {
        if replyDeferred {
            _ = try await followUp(content)
            return
        }
        try await sendResponse(.message(.init(content: content)), type: .interactionReply)
    }

    func reply(@EmbedBuilder _ embeds: () -> [BotEmbed]) async throws {
        try await sendResponse(.message(.init(embeds: embeds())), type: .interactionReply)
    }

    /// Send a follow up response to this interaction
    ///
    /// By default, this creates a second reply to this interaction, appearing as a
    /// reply in clients. However, if a call to ``deferReply()`` was made, this
    /// edits the loading message with the content provided.
    func followUp(_ content: String) async throws -> Message {
        try await rest!.sendInteractionFollowUp(.init(content: content), applicationID: applicationID, token: token)
    }

    /// Defer the reply to this interaction - the user sees a loading state
    func deferReply() async throws {
        try await sendResponse(nil, type: .deferredInteractionReply)
        replyDeferred = true
    }
}
