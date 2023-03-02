// NOTE: This file is auto-generated

import Foundation

public extension DiscordREST {
    /// Get Entitlements
    ///
    /// > GET: `/applications/{application.id}/entitlements`
    func getEntitlements<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/entitlements"
        )
    }
    /// Get Entitlement
    ///
    /// > GET: `/applications/{application.id}/entitlements/{entitlement.id}`
    func getEntitlement<T: Decodable>(
        _ applicationId: Snowflake,
        _ entitlementId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/entitlements/\(entitlementId)"
        )
    }
    /// Get SKUs
    ///
    /// > GET: `/applications/{application.id}/skus`
    func getSKUs<T: Decodable>(
        _ applicationId: Snowflake
    ) async throws -> T {
        return try await getReq(
            path: "applications/\(applicationId)/skus"
        )
    }
    /// Consume SKU
    ///
    /// > POST: `/applications/{application.id}/entitlements/{entitlement.id}/consume`
    func consumeSKU<T: Decodable, B: Encodable>(
        _ applicationId: Snowflake,
        _ entitlementId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await postReq(
            path: "applications/\(applicationId)/entitlements/\(entitlementId)/consume",
            body: body
        )
    }
    /// Delete Test Entitlement
    ///
    /// > DELETE: `/applications/{application.id}/entitlements/{entitlement.id}`
    func deleteTestEntitlement(
        _ applicationId: Snowflake,
        _ entitlementId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "applications/\(applicationId)/entitlements/\(entitlementId)"
        )
    }
    /// Create Purchase Discount
    ///
    /// > PUT: `/store/skus/{sku.id}/discounts/{user.id}`
    func createPurchaseDiscount<T: Decodable, B: Encodable>(
        _ skuId: Snowflake,
        _ userId: Snowflake,
        _ body: B
    ) async throws -> T {
        return try await putReq(
            path: "store/skus/\(skuId)/discounts/\(userId)",
            body: body
        )
    }
    /// Delete Purchase Discount
    ///
    /// > DELETE: `/store/skus/{sku.id}/discounts/{user.id}`
    func deletePurchaseDiscount(
        _ skuId: Snowflake,
        _ userId: Snowflake
    ) async throws {
        try await deleteReq(
            path: "store/skus/\(skuId)/discounts/\(userId)"
        )
    }
}
