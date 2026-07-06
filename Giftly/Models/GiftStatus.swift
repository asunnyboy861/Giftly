import Foundation

enum GiftStatus: String, Codable, CaseIterable, Identifiable {
    case idea = "Idea"
    case planned = "Planned"
    case purchased = "Purchased"
    case given = "Given"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .idea: return "lightbulb"
        case .planned: return "list.clipboard"
        case .purchased: return "bag"
        case .given: return "gift.fill"
        }
    }

    var next: GiftStatus? {
        switch self {
        case .idea: return .planned
        case .planned: return .purchased
        case .purchased: return .given
        case .given: return nil
        }
    }
}
