// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    // MARK: Get Entitlements
    // GET /applications/${ApplicationId}/entitlements
    func getEntitlements<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/entitlements/"
        )
    }
    // MARK: Get Entitlement
    // GET /applications/${ApplicationId}/entitlements/${EntitlementId}
    func getEntitlement<T: Decodable>(
        _ applicationId: Snowflake,
        _ entitlementId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/entitlements/\(entitlementId)/"
        )
    }
    // MARK: Get SKUs
    // GET /applications/${ApplicationId}/skus
    func getSKUs<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/skus/"
        )
    }
    // MARK: Consume SKU
    // POST /applications/${ApplicationId}/entitlements/${EntitlementId}/consume
    func consumeSKU<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ entitlementId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "applications/\(applicationId)/entitlements/\(entitlementId)/consume/",
            body: body
        )
    }
    // MARK: Delete Test Entitlement
    // DELETE /applications/${ApplicationId}/entitlements/${EntitlementId}
    func deleteTestEntitlement(
        _ applicationId: Snowflake,
        _ entitlementId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "applications/\(applicationId)/entitlements/\(entitlementId)/"
        )
    }
    // MARK: Create Purchase Discount
    // PUT /store/skus/${SkuId}/discounts/${UserId}
    func createPurchaseDiscount<T: Decodable, B: Encodable>(
        _ skuId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "store/skus/\(skuId)/discounts/\(userId)/",
            body: body
        )
    }
    // MARK: Delete Purchase Discount
    // DELETE /store/skus/${SkuId}/discounts/${UserId}
    func deletePurchaseDiscount(
        _ skuId: Snowflake,
        _ userId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "store/skus/\(skuId)/discounts/\(userId)/"
        )
    }
}
