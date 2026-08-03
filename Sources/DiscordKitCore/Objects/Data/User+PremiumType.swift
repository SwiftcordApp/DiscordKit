import Foundation

public extension User {
    enum PremiumType: RawRepresentable, Codable, Hashable, Identifiable, CustomStringConvertible {
        /// No premium subscription
        case none

        /// Nitro classic
        case nitroClassic

        /// Nitro
        case nitro

        /// Nitro Basic
        case nitroBasic

        /// A premium type introduced after this DiscordKit build.
        case unknown(Int)

        public init(rawValue: Int) {
            switch rawValue {
            case 0: self = .none
            case 1: self = .nitroClassic
            case 2: self = .nitro
            case 3: self = .nitroBasic
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: Int {
            switch self {
            case .none: 0
            case .nitroClassic: 1
            case .nitro: 2
            case .nitroBasic: 3
            case .unknown(let rawValue): rawValue
            }
        }

        public init(from decoder: Decoder) throws {
            self.init(rawValue: try decoder.singleValueContainer().decode(Int.self))
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(rawValue)
        }

        // MARK: Identifiable

        public var id: Int {
            rawValue
        }

        // MARK: CustomStringConvertible

        public var description: String {
            switch self {
            case .none:
                return "None"

            case .nitroClassic:
                return "Nitro Classic"

            case .nitro:
                return "Nitro"

            case .nitroBasic:
                return "Nitro Basic"

            case .unknown(let rawValue):
                return "Unknown (\(rawValue))"
            }
        }
    }
}
