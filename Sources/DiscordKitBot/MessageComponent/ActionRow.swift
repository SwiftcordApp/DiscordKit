//
//  ActionRow.swift
//  
//
//  Created by Vincent Kwok on 27/1/23.
//

import Foundation
import DiscordKitCore

public struct ActionRow: Component {
    public let type: MessageComponentTypes = .actionRow
    public let components: [Component]

    public init(@ComponentBuilder _ components: () -> [Component]) {
        self.components = components()
        assert(self.components.count <= 5, "An action row can contain up to 5 buttons")
    }

    enum CodingKeys: CodingKey {
        case type
        case components
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(1, forKey: .type)
        var componentContainer = container.nestedUnkeyedContainer(forKey: .components)
        for component in components {
            try componentContainer.encode(component)
        }
    }
}
