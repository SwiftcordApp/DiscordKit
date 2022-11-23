import Foundation

public extension User {
    enum PremiumType: Int, Codable, Hashable, Identifiable, CustomStringConvertible {
        /// No premium subscription
        case none = 0

        /// Nitro classic
        case nitroClassic = 1

        /// Nitro
        case nitro = 2

        // MARK: Identifiable

        public var id: RawValue {
            return rawValue
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
            }
        }
    }
}
