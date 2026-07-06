import Foundation

struct GiftSuggestion: Codable, Identifiable {
    let id: UUID
    let title: String
    let reason: String
    let priceRange: String
    let searchTerms: String

    init(title: String, reason: String, priceRange: String, searchTerms: String) {
        self.id = UUID()
        self.title = title
        self.reason = reason
        self.priceRange = priceRange
        self.searchTerms = searchTerms
    }
}

struct OpenAIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}

enum GiftAIError: LocalizedError {
    case noAPIKey
    case apiError(String)
    case parseError

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "Please add your API key in Settings to use AI gift suggestions."
        case .apiError(let message):
            return "Failed to get gift suggestions: \(message)"
        case .parseError:
            return "Failed to parse AI response. Please try again."
        }
    }
}

@MainActor
final class GiftAIService {
    static let shared = GiftAIService()
    private let keychainService = "com.zzoutuo.Giftly"
    private let keychainAccount = "openai_api_key"
    private let keychainModelAccount = "openai_model"
    private let keychainBaseURLAccount = "openai_base_url"
    private let defaultModel = "gpt-4o-mini"
    private let defaultBaseURL = "https://api.openai.com/v1"
    private init() {}

    func getAPIKey() -> String? {
        KeychainHelper.readString(service: keychainService, account: keychainAccount)
    }

    func saveAPIKey(_ key: String) {
        KeychainHelper.saveString(key, service: keychainService, account: keychainAccount)
    }

    func deleteAPIKey() {
        KeychainHelper.delete(service: keychainService, account: keychainAccount)
    }

    func getModel() -> String {
        KeychainHelper.readString(service: keychainService, account: keychainModelAccount) ?? defaultModel
    }

    func saveModel(_ model: String) {
        KeychainHelper.saveString(model, service: keychainService, account: keychainModelAccount)
    }

    func getBaseURL() -> String {
        KeychainHelper.readString(service: keychainService, account: keychainBaseURLAccount) ?? defaultBaseURL
    }

    func saveBaseURL(_ url: String) {
        KeychainHelper.saveString(url, service: keychainService, account: keychainBaseURLAccount)
    }

    var hasAPIKey: Bool {
        guard let key = getAPIKey() else { return false }
        return !key.isEmpty
    }

    func generateGiftSuggestions(
        person: Person,
        budgetMin: Double,
        budgetMax: Double
    ) async throws -> [GiftSuggestion] {
        guard let apiKey = getAPIKey(), !apiKey.isEmpty else {
            throw GiftAIError.noAPIKey
        }

        let baseURL = getBaseURL()
        let model = getModel()

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
        "searchTerms": Amazon search terms (string)
        """

        let url = URL(string: "\(baseURL)/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are a gift suggestion expert. Return only valid JSON."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.8
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GiftAIError.apiError("Invalid response")
        }

        guard httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GiftAIError.apiError("HTTP \(httpResponse.statusCode): \(errorBody)")
        }

        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        let content = openAIResponse.choices.first?.message.content ?? "[]"

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
