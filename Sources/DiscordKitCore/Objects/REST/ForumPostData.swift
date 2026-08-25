//
//  ForumPostData.swift
//  DiscordKit
//
//  Created by Vincent on 16/8/26.
//

import Foundation

public struct ForumPostDataRequest: Codable, Equatable {
    public let thread_ids: [Snowflake]

    public init(threadIDs: [Snowflake]) {
        self.thread_ids = threadIDs
    }
}

public struct ForumPostDataResponse: Codable {
    public let threads: [Snowflake: ForumPostData]
}

public struct ForumPostData: Codable {
    public let first_message: Message?
    public let most_recent_message: Message?
    public let owner: Member?
}
