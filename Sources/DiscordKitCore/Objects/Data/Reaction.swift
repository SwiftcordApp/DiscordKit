//
//  Reaction.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 19/2/22.
//

import Foundation

public struct Reaction: Codable {
    public struct CountDetails: Codable {
        public init(normal: Int? = nil, burst: Int? = nil, vote: Int? = nil) {
            self.normal = normal
            self.burst = burst
            self.vote = vote
        }

        public let normal: Int?
        public let burst: Int?
        public let vote: Int?
    }

    public init(
        count: Int,
        me: Bool,
        emoji: Emoji,
        count_details: CountDetails? = nil,
        me_vote: Bool? = nil
    ) {
        self.count = count
        self.me = me
        self.emoji = emoji
        self.count_details = count_details
        self.me_vote = me_vote
    }

    public let count: Int
    public let me: Bool // swiftlint:disable:this identifier_name
    public let emoji: Emoji
    public let count_details: CountDetails?
    public let me_vote: Bool?
}

public extension Reaction {
    /// Vote count when this reaction is Discord's client-side poll representation.
    var pollVoteCount: Int? {
        count_details?.vote
    }

    /// Whether this reaction represents a poll answer rather than an emoji reaction.
    var isPollVote: Bool {
        pollVoteCount != nil || me_vote != nil
    }

    /// Poll answer identifier carried by a vote pseudo-reaction.
    var pollAnswerID: Int? {
        guard isPollVote, let id = emoji.id else { return nil }
        return Int(id)
    }

    /// Creates the lightweight pseudo-reaction used for live poll tally updates.
    static func pollVote(answerID: Int, count: Int, meVoted: Bool) -> Self {
        Self(
            count: 0,
            me: false,
            emoji: Emoji(id: String(answerID), name: "", animated: false),
            count_details: CountDetails(vote: max(0, count)),
            me_vote: meVoted
        )
    }
}
