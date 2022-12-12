//
//  AppCommandBuilder.swift
//  
//
//  Created by Vincent Kwok on 26/11/22.
//

import Foundation
import DiscordKitCore

@resultBuilder
public struct AppCommandBuilder {
    public static func buildBlock(_ components: NewAppCommand...) -> [NewAppCommand] {
        components
    }
}
