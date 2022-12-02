//
//  CreateAppCmd.swift
//  
//
//  Created by Vincent Kwok on 27/11/22.
//

import Foundation

/// Payload sent to the create application command endpoint to create an application command
public struct CreateAppCmd {
    public let name: String
    public let description: String?
    public let options: [AppCommandOption]?
}
