//
//  BotMessage.swift
//  
//
//  Created by Vincent Kwok on 22/11/22.
//

import Foundation

/// A Discord message, with convenience methods
///
/// This struct represents a message on Discord,
/// > Internally, ``Message``s are converted to and from this type
/// > for easier use
public struct BotMessage {
    public let content: String
}
