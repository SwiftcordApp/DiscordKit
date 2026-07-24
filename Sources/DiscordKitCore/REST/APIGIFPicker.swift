//
//  APIGIFPicker.swift
//  DiscordKit
//
//  Created by Vincent on 24/7/26.
//

import Foundation

public extension DiscordREST {
    /// Fetch the GIF picker's front-page categories and preview media.
    ///
    /// `GET /gifs/trending`
    func getGIFTrendingCategories(
        provider: GIFProvider,
        locale: Locale = .englishUS,
        mediaFormat: GIFMediaFormat
    ) async throws -> GIFTrendingResponse {
        try await getReq(
            path: "gifs/trending",
            query: GIFPickerQuery(
                provider: provider,
                locale: locale,
                mediaFormat: mediaFormat
            ).queryItems()
        )
    }

    /// Fetch the GIF picker's current trending results.
    ///
    /// `GET /gifs/trending-gifs`
    func getTrendingGIFs(
        provider: GIFProvider,
        locale: Locale = .englishUS,
        mediaFormat: GIFMediaFormat,
        limit: Int? = nil
    ) async throws -> [GIFPickerResult] {
        try await getReq(
            path: "gifs/trending-gifs",
            query: GIFPickerQuery(
                provider: provider,
                locale: locale,
                mediaFormat: mediaFormat,
                limit: limit
            ).queryItems()
        )
    }

    /// Search for GIFs through Discord's configured provider proxy.
    ///
    /// `GET /gifs/search`
    func searchGIFs(
        _ query: String,
        provider: GIFProvider,
        locale: Locale = .englishUS,
        mediaFormat: GIFMediaFormat,
        limit: Int? = nil
    ) async throws -> [GIFPickerResult] {
        try await getReq(
            path: "gifs/search",
            query: GIFPickerQuery(
                provider: provider,
                locale: locale,
                mediaFormat: mediaFormat,
                query: query,
                limit: limit
            ).queryItems()
        )
    }

    /// Fetch related searches for a populated GIF result set.
    ///
    /// `GET /gifs/suggest`
    func getGIFSearchSuggestions(
        for query: String,
        provider: GIFProvider,
        locale: Locale = .englishUS,
        limit: Int = 5
    ) async throws -> [String] {
        try await getReq(
            path: "gifs/suggest",
            query: GIFPickerQuery(
                provider: provider,
                locale: locale,
                query: query,
                limit: limit
            ).queryItems()
        )
    }

    /// Report an ID-bearing GIF selection to Discord's provider proxy.
    ///
    /// `POST /gifs/select`
    func reportGIFSelection(
        id: String,
        query: String,
        provider: GIFProvider
    ) async throws {
        try await postReq(
            path: "gifs/select",
            body: GIFSelectionRequest(id: id, query: query, provider: provider)
        )
    }
}
