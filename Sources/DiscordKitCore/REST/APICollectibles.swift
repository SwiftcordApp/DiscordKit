//
//  APICollectibles.swift
//  DiscordKit
//
//  Created by Vincent on 22/6/26.
//

import Foundation

public extension DiscordREST {
    /// Get Collectibles Product
    ///
    /// `GET /collectibles-products/{sku.id}`
    /// > Warning: This is an undocumented endpoint.
    func getCollectiblesProduct(
        skuID: Snowflake,
        locale: Locale = .englishUS
    ) async throws -> UserProfileEffectProduct {
        try await getReq(
            path: "collectibles-products/\(skuID)",
            query: [
                URLQueryItem(name: "locale", value: locale.rawValue)
            ]
        )
    }
}
