//
//  Presence+.swift
//  
//
//  Created by Vincent Kwok on 7/9/22.
//

import Foundation
import DiscordKitCore

extension Presence {
    init(protoStatus: StatusSettings, id: Snowflake) {
        let presence = PresenceStatus(rawValue: protoStatus.status.value) ?? .online
        var activities: [Activity] = []
        if protoStatus.hasCustomStatus {
            activities.append(Activity(
                name: "Custom Status",
                type: .custom,
                created_at: 0,
                state: protoStatus.customStatus.text
            ))
        }
        self.init(
            userID: id,
            status: presence,
            clientStatus: PresenceClientStatus(desktop: presence),
            activities: activities
        )
    }
}
