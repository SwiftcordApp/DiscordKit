//
//  Poll.swift
//  DiscordKit
//
//  Created by Vincent on 30/8/26.
//

import Foundation

/// Text and emoji content used by a poll question or answer.
public struct PollMedia: Codable, Equatable, Hashable {
    public init(text: String? = nil, emoji: Emoji? = nil) {
        self.text = text
        self.emoji = emoji
    }

    public let text: String?
    public let emoji: Emoji?
}

/// One answer in a poll returned by Discord.
public struct PollAnswer: Codable, Equatable, Hashable, Identifiable {
    public init(answer_id: Int, poll_media: PollMedia) {
        self.answer_id = answer_id
        self.poll_media = poll_media
    }

    public let answer_id: Int
    public let poll_media: PollMedia

    public var id: Int { answer_id }
}

/// Current tally and current-user state for one poll answer.
public struct PollAnswerCount: Codable, Equatable, Hashable {
    public init(id: Int, count: Int, me_voted: Bool) {
        self.id = id
        self.count = count
        self.me_voted = me_voted
    }

    public let id: Int
    public let count: Int
    public let me_voted: Bool
}

/// The known poll results. Counts may be approximate until finalized.
public struct PollResults: Codable, Equatable, Hashable {
    public init(is_finalized: Bool, answer_counts: [PollAnswerCount]) {
        self.is_finalized = is_finalized
        self.answer_counts = answer_counts
    }

    public let is_finalized: Bool
    public let answer_counts: [PollAnswerCount]
}

/// A poll attached to a message.
public struct Poll: Codable, Equatable, Hashable {
    public init(
        question: PollMedia,
        answers: [PollAnswer],
        expiry: Date?,
        allow_multiselect: Bool,
        layout_type: Int,
        results: PollResults? = nil
    ) {
        self.question = question
        self.answers = answers
        self.expiry = expiry
        self.allow_multiselect = allow_multiselect
        self.layout_type = layout_type
        self.results = results
    }

    public let question: PollMedia
    public let answers: [PollAnswer]
    public let expiry: Date?
    public let allow_multiselect: Bool
    public let layout_type: Int
    public let results: PollResults?
}
