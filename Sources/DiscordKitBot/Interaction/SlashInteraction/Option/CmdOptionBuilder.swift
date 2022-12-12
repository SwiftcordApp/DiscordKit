//
//  CmdOptionBuilder.swift
//  
//
//  Created by Vincent Kwok on 12/12/22.
//

import Foundation
import DiscordKitCore

@resultBuilder
public struct CmdOptionBuilder {
    public static func buildBlock(_ components: CmdOption...) -> [AppCommandOption] {
        components.map { $0.option }
    }
}
