//
//  Logger+.swift
//  
//
//  Created by Vincent Kwok on 25/11/22.
//

import Foundation
import Logging

public extension Logger {
    /// Create a Logger instance at a specific log level
    init(label: String, level: Level?) {
        self.init(label: label)
        if let level = level {
            logLevel = level
        } else {
#if DEBUG
            logLevel = .trace
#endif
        }
    }
}
