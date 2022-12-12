//
//  OptionBuilder.swift
//  
//
//  Created by Vincent Kwok on 12/12/22.
//

import Foundation
import DiscordKitCore

@resultBuilder
public struct OptionBuilder {
    public static func buildBlock(_ components: CommandOption...) -> [CommandOption] {
        components
    }
}
