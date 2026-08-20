//
//  APIStream.swift
//  DiscordKit
//
//  Created by Zerui on 13/8/26.
//

import Foundation

public extension DiscordREST {
    /// Fetch the latest lightweight preview for an active Go Live stream.
    ///
    /// > GET: `/streams/{stream_key}/preview`
    func getStreamPreview(_ streamKey: DiscordStreamKey) async throws -> StreamPreview {
        try await getReq(path: "streams/\(streamKey.rawValue)/preview")
    }
}
