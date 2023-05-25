import Foundation

public extension User {
    /// Represents the flags on a user's account.
    struct Flags: OptionSet, CaseIterable, Codable, Hashable, Identifiable, CustomStringConvertible, CustomDebugStringConvertible {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// Discord Employee
        public static let staff = Flags(rawValue: 1 << 0)

        /// Partnered Server Owner
        public static let partner = Flags(rawValue: 1 << 1)

        /// HypeSquad Events Member
        public static let hypesquad = Flags(rawValue: 1 << 2)

        /// Bug Hunter Level 1
        public static let bugHunterLevel1 = Flags(rawValue: 1 << 3)

        /// House Bravery Member
        public static let hypesquadOnlineHouse1 = Flags(rawValue: 1 << 6)

        /// House Brilliance Member
        public static let hypesquadOnlineHouse2 = Flags(rawValue: 1 << 7)

        /// House Balance Member
        public static let hypesquadOnlineHouse3 = Flags(rawValue: 1 << 8)

        /// Early Nitro Supporter
        public static let premiumEarlySupporter = Flags(rawValue: 1 << 9)

        /// User is a [team](https://discord.com/developers/docs/topics/teams)
        public static let teamPseudoUser = Flags(rawValue: 1 << 10)

        /// Bug Hunter Level 2
        public static let bugHunterLevel2 = Flags(rawValue: 1 << 14)

        /// Verified Bot
        public static let verifiedBot = Flags(rawValue: 1 << 16)

        /// Early Verified Bot Developer
        public static let verifiedDeveloper = Flags(rawValue: 1 << 17)

        /// Discord Certified Moderator
        public static let certifiedModerator = Flags(rawValue: 1 << 18)

        public static let activeDeveloper = Flags(rawValue: 1 << 22)

        /// Bot uses only [HTTP interactions](https://discord.com/developers/docs/interactions/receiving-and-responding#receiving-an-interaction) and is shown in the online member list
        public static let botHTTPInteractions = Flags(rawValue: 1 << 19)

        public static let allCases: [Flags] = [
            .staff,
            .partner,
            .hypesquad,
            .bugHunterLevel1,
            .hypesquadOnlineHouse1,
            .hypesquadOnlineHouse2,
            .hypesquadOnlineHouse3,
            .premiumEarlySupporter,
            .teamPseudoUser,
            .bugHunterLevel2,
            .verifiedBot,
            .verifiedDeveloper,
            .certifiedModerator,
            .botHTTPInteractions,
            .activeDeveloper
        ]

        // MARK: Hashable

        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue)
        }

        // MARK: Identifiable

        public var id: Int {
            rawValue
        }

        // MARK: CustomStringConvertible

        public var description: String {
            var description: [String] = []

            if self.contains(.staff) {
                description.append("Discord Employee")
            } else if self.contains(.partner) {
                description.append("Partnered Server Owner")
            } else if self.contains(.hypesquad) {
                description.append("HypeSquad Events Member")
            } else if self.contains(.bugHunterLevel1) {
                description.append("Bug Hunter Level 1")
            } else if self.contains(.hypesquadOnlineHouse1) {
                description.append("House Bravery Member")
            } else if self.contains(.hypesquadOnlineHouse2) {
                description.append("House Brilliance Member")
            } else if self.contains(.hypesquadOnlineHouse3) {
                description.append("House Balance Member")
            } else if self.contains(.premiumEarlySupporter) {
                description.append("Early Nitro Supporter")
            } else if self.contains(.teamPseudoUser) {
                description.append("User is a team")
            } else if self.contains(.bugHunterLevel2) {
                description.append("Bug Hunter Level 2")
            } else if self.contains(.verifiedBot) {
                description.append("Verified Bot")
            } else if self.contains(.verifiedDeveloper) {
                description.append("Early Verified Bot Developer")
            } else if self.contains(.certifiedModerator) {
                description.append("Discord Certified Moderator")
            } else if self.contains(.botHTTPInteractions) {
                description.append("Bot uses only HTTP interactions and is shown in the online member list")
            }

            return description.joined(separator: ", ")
        }

        // MARK: CustomDebugStringConvertible

        public var debugDescription: String {
            var description: [String] = []

            if self.contains(.staff) {
                description.append("STAFF")
            } else if self.contains(.partner) {
                description.append("PARTNER")
            } else if self.contains(.hypesquad) {
                description.append("HYPESQUAD")
            } else if self.contains(.bugHunterLevel1) {
                description.append("BUG_HUNTER_LEVEL_1")
            } else if self.contains(.hypesquadOnlineHouse1) {
                description.append("HYPESQUAD_ONLINE_HOUSE_1")
            } else if self.contains(.hypesquadOnlineHouse2) {
                description.append("HYPESQUAD_ONLINE_HOUSE_2")
            } else if self.contains(.hypesquadOnlineHouse3) {
                description.append("HYPESQUAD_ONLINE_HOUSE_3")
            } else if self.contains(.premiumEarlySupporter) {
                description.append("PREMIUM_EARLY_SUPPORTER")
            } else if self.contains(.teamPseudoUser) {
                description.append("TEAM_PSEUDO_USER")
            } else if self.contains(.bugHunterLevel2) {
                description.append("BUG_HUNTER_LEVEL_2")
            } else if self.contains(.verifiedBot) {
                description.append("VERIFIED_BOT")
            } else if self.contains(.verifiedDeveloper) {
                description.append("VERIFIED_DEVELOPER")
            } else if self.contains(.certifiedModerator) {
                description.append("CERTIFIED_MODERATOR")
            } else if self.contains(.botHTTPInteractions) {
                description.append("BOT_HTTP_INTERACTIONS")
            }

            return description.joined(separator: ", ")
        }
    }
}
