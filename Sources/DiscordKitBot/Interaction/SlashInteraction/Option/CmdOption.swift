//
//  CmdOption.swift
//  
//
//  Created by Vincent Kwok on 12/12/22.
//

import Foundation
import DiscordKitCore

public protocol CmdOption {
    var option: AppCommandOption { get }
}
