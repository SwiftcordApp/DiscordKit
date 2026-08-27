//
//  ChannelOption.swift
//
//
//  Created by Elizabeth on 02/10/2025.
//

import Foundation
import DiscordKitCore

/// An option for an application command that accepts a server channel
public struct ChannelOption: CommandOption {
    public init(_ name: String, description: String, `required`: Bool? = nil, channel_types: [ChannelType]? = nil) {
        type = .channel

        self.required = `required`
        self.name = name
        self.description = description
        self.channel_types = channel_types
    }

    public var type: CommandOptionType

    public var required: Bool?

    public let name: String
    public let description: String

    public let channel_types: [ChannelType]?
}
