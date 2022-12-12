//
//  AppCommand.swift
//  
//
//  Created by Vincent Kwok on 12/12/22.
//

import Foundation

public enum CommandOptionType: Int, Codable {
    case subCommand = 1
    case subCommandGroup = 2
    case string = 3
    case integer = 4
    case boolean = 5
    case user = 6
    case channel = 7
    case role = 8
    case mentionable = 9
    case number = 10
    case attachment = 11
}
