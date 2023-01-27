//
//  Button.swift
//  
//
//  Created by Vincent Kwok on 27/1/23.
//

import Foundation
import DiscordKitCore

public struct Button: Component {
    public enum ButtonType: Int, Codable {
        /// An action button with a blurple background
        case primary = 1
        /// An action button with a grey background
        case secondary = 2
        /// An action button with a green background
        case success = 3
        /// An action button with a red background
        case danger = 4
        /// A grey link button
        case link = 5
    }

    public let type: MessageComponentTypes = .button
    fileprivate(set) var style: ButtonType = .primary
    public let label: String?
    public let emoji: Emoji?
    public let custom_id: String?
    public let url: URL?
    fileprivate(set) var disabled: Bool?

    public init(_ label: String? = nil, emoji: Emoji? = nil, id: String) {
        assert(label != nil || emoji != nil, "One of label or emoji must be provided")
        self.label = label
        self.custom_id = id
        self.emoji = emoji
        self.url = nil
    }

    public init(_ label: String? = nil, emoji: Emoji? = nil, url: URL) {
        assert(label != nil || emoji != nil, "One of label or emoji must be provided")
        self.label = label
        self.custom_id = nil
        self.emoji = emoji
        self.url = url
    }
}

public extension Button {
    func buttonStyle(_ style: ButtonType) -> Self {
        var opt = self
        opt.style = style
        return opt
    }

    func disabled(_ disabled: Bool = true) -> Self {
        var opt = self
        opt.disabled = disabled
        return opt
    }
}
