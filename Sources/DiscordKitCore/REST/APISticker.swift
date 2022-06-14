//
//  APISticker.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 24/2/22.
//

import Foundation
import DiscordKitCommon

public extension DiscordREST {
    // MARK: Get Sticker
    // GET /stickers/{sticker.id}
    func getSticker(id: Snowflake) async -> Sticker? {
        return await getReq(path: "stickers/\(id)")
    }
}
