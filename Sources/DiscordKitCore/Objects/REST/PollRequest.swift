//
//  PollRequest.swift
//  DiscordKit
//
//  Created by Vincent on 30/8/26.
//

import Foundation

/// Replaces the current user's complete answer selection for a poll.
public struct ReplacePollAnswersRequest: Encodable {
    public init(answerIDs: [Int]) {
        answer_ids = answerIDs.map(String.init)
    }

    public let answer_ids: [String]
}
