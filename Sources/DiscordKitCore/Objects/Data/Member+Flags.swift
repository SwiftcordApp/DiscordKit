//
//  Member+Flags.swift
//  DiscordKit
//
//  Created by Vincent on 1/8/26.
//

public extension Member {
    struct Flags: OptionSet, Codable, Hashable, Sendable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let automodQuarantinedUsernameOrGuildNickname = Self(rawValue: 1 << 7)
        public static let automodQuarantinedBio = Self(rawValue: 1 << 8)
        public static let automodQuarantinedServerTag = Self(rawValue: 1 << 10)

        public static let automodQuarantinedProfile: Self = [
            .automodQuarantinedUsernameOrGuildNickname,
            .automodQuarantinedBio,
            .automodQuarantinedServerTag
        ]
    }

    var isAnyProfileFieldQuarantined: Bool {
        guard let flags else { return false }
        return !flags.intersection(.automodQuarantinedProfile).isEmpty
    }
}
