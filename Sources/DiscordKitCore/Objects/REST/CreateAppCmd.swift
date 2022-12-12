//
//  CreateAppCmd.swift
//  
//
//  Created by Vincent Kwok on 27/11/22.
//

import Foundation

/// Payload sent to the create application command endpoint to create an application command
///
/// > Application commands are known as "slash commands" in the Discord client.
public struct CreateAppCmd {
    public init(name: String, description: String = "", options: [AppCommandOption]? = nil) {
        self.name = name
        self.description = description
        self.options = options
    }

    public let name: String
    public let description: String
    public let options: [AppCommandOption]?
}
