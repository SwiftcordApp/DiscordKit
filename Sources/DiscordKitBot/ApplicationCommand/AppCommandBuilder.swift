//
//  AppCommandBuilder.swift
//  
//
//  Created by Vincent Kwok on 26/11/22.
//

import Foundation
import DiscordKitCore

/// A `resultBuilder` which allows constructing ``NewAppCommand``s with blocks
///
/// This provides syntactic sugar for constructing application commands.
@resultBuilder
public struct AppCommandBuilder {
    public static func buildBlock(_ components: NewAppCommand...) -> [NewAppCommand] {
        components
    }
}
