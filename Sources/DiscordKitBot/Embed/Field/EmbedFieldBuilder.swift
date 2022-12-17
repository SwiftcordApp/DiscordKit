//
//  EmbedFieldBuilder.swift
//  
//
//  Created by Vincent Kwok on 16/12/22.
//

import Foundation

@resultBuilder
public struct EmbedFieldBuilder {
    public static func buildBlock(_ components: BotEmbed.Field...) -> [BotEmbed.Field] {
        components
    }
}
