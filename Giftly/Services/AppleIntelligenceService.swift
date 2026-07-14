import Foundation
import FoundationModels

@MainActor
@available(iOS 26, *)
final class AppleIntelligenceService {
    static let shared = AppleIntelligenceService()
    private init() {}

    var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }

    var availabilityReason: String? {
        guard !isAvailable else { return nil }
        switch SystemLanguageModel.default.availability {
        case .unavailable(let reason):
            switch reason {
            case .modelNotReady:
                return "Apple Intelligence model is still downloading. Check Settings > Apple Intelligence & Siri."
            default:
                return "Apple Intelligence is not available on this device. AI gift suggestions require iOS 26 or later with Apple Intelligence enabled."
            }
        default:
            return "Apple Intelligence is not available on this device."
        }
    }

    func generateGiftSuggestions(
        person: Person,
        budgetMin: Double,
        budgetMax: Double
    ) async throws -> [GiftSuggestion] {
        guard isAvailable else {
            throw GiftAIError.apiError("Apple Intelligence is not available. AI gift suggestions require iOS 26 or later with Apple Intelligence enabled.")
        }

        let prompt = """
        Suggest 5 birthday gift ideas for:
        - Name: \(person.name)
        - Age: \(person.upcomingAge) years old
        - Relationship: \(person.relationship ?? "Friend")
        - Interests: \(person.interests.isEmpty ? "Not specified" : person.interests.joined(separator: ", "))
        - Budget: $\(Int(budgetMin)) - $\(Int(budgetMax))

        Return ONLY a valid JSON array (no markdown, no explanation) with objects containing:
        "title": gift name (string)
        "reason": why it's a good gift (string)
        "priceRange": estimated price range (string, e.g. "$25-$35")
        "searchTerms": web search terms (string)
        """

        let session = LanguageModelSession()
        let response = try await session.respond(to: prompt)
        let content = response.content

        let cleanContent = content
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = cleanContent.data(using: .utf8) else {
            throw GiftAIError.parseError
        }

        do {
            let suggestions = try JSONDecoder().decode([GiftSuggestion].self, from: jsonData)
            return suggestions
        } catch {
            throw GiftAIError.parseError
        }
    }
}
