//
//  EmbedBuilder.swift
//  
//
//  Created by Vincent Kwok on 16/12/22.
//

import Foundation
import DiscordKitCore

@resultBuilder
public struct EmbedBuilder {
    public static func buildBlock(_ components: BotEmbed...) -> [BotEmbed] {
        components
    }
}
