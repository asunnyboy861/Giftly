import Foundation

struct GiftSuggestion: Identifiable, Codable {
    let id = UUID()
    let title: String
    let reason: String
    let priceRange: String
    let searchTerms: String

    enum CodingKeys: String, CodingKey {
        case title
        case reason
        case priceRange
        case searchTerms
    }
}

enum GiftAIError: Error, LocalizedError {
    case apiError(String)
    case parseError

    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return message
        case .parseError:
            return "Could not parse the AI response. Please try again."
        }
    }
}
