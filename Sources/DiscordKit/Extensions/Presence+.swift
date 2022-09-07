//
//  File.swift
//  
//
//  Created by Vincent Kwok on 7/9/22.
//

import Foundation
import DiscordKitCommon

extension Presence {
    init(protoStatus: StatusSettings, id: Snowflake) {
        let presence = PresenceStatus(rawValue: protoStatus.status.value) ?? .online
        self.init(
            userID: id,
            status: presence,
            clientStatus: PresenceClientStatus(desktop: presence),
            activities: []
        )
    }
}
