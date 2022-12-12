//
//  StringOption.swift
//  
//
//  Created by Vincent Kwok on 12/12/22.
//

import Foundation
import DiscordKitCore

public struct StringOption: CmdOption {
    public init(name: String, description: String) {
        self.name = name
        self.description = description
    }

    public let name: String
    public let description: String

    public var option: AppCommandOption {
        .init(name, description: description)
    }
}
