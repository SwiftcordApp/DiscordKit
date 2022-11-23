//
//  File.swift
//  
//
//  Created by Vincent Kwok on 5/9/22.
//

import Foundation

/// Payload sent with ``GatewayEvent/readySupplemental``
public struct ReadySuppEvt: Decodable, GatewayData {
    public let merged_presences: MergedPresences
}

public struct MergedPresences: GatewayData {
    public let guilds: [[Presence]]
    public let friends: [Presence]
}
