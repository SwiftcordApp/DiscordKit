//
//  LogOut.swift
//  
//
//  Created by Vincent Kwok on 15/6/22.
//

import Foundation

struct LogOut: Codable {
    let provider: String?
    let voip_provider: String?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Encoding containers directly so nil optionals get encoded as "null" and not just removed
        try container.encode(provider, forKey: .provider)
        try container.encode(voip_provider, forKey: .voip_provider)
    }
}
