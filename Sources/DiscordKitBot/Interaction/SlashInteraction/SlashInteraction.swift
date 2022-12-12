//
//  SlashInteraction.swift
//  
//
//  Created by Vincent Kwok on 10/12/22.
//

import Foundation
import DiscordKitCore

public struct SlashInteraction {
    let createAppCommand: CreateAppCmd

    public init(_ name: String, description: String? = nil, @CmdOptionBuilder options: () -> [AppCommandOption]) {
        createAppCommand = .init(name, description: description, options: options())
    }
}
