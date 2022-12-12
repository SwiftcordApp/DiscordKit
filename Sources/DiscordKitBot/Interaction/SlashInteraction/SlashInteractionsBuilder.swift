//
//  SlashInteractionsBuilder.swift
//  
//
//  Created by Vincent Kwok on 26/11/22.
//

import Foundation
import DiscordKitCore

@resultBuilder
public struct SlashInteractionsBuilder {
    public static func buildBlock(_ components: SlashInteraction...) -> [CreateAppCmd] {
        components.map { $0.createAppCommand }
    }
}
