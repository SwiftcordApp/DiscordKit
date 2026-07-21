//
//  Message+.swift
//
//
//  Created by Vincent Kwok on 8/12/23.
//

import Foundation

public extension Message {
    func mentions(_ userID: Snowflake?) -> Bool {
        guard let userID else { return false }
        return mentions.first(identifiedBy: userID) != nil
    }
}
