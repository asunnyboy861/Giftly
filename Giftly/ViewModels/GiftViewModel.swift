import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
@Observable
final class GiftViewModel {
    var modelContext: ModelContext?

    var isLoading: Bool = false
    var errorMessage: String?
    var aiSuggestions: [GiftSuggestion] = []

    func attach(context: ModelContext) {
        self.modelContext = context
    }

    func addGiftIdea(
        to person: Person,
        title: String,
        description: String?,
        estimatedPrice: Double?,
        searchTerms: String?
    ) -> GiftIdea? {
        guard let context = modelContext,
              !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return nil
        }

        let idea = GiftIdea(
            title: title.trimmingCharacters(in: .whitespaces),
            giftDescription: description?.isEmpty == false ? description : nil,
            estimatedPrice: estimatedPrice,
            searchTerms: searchTerms?.isEmpty == false ? searchTerms : nil
        )
        idea.person = person
        person.giftIdeas.append(idea)
        context.insert(idea)

        do {
            try context.save()
            return idea
        } catch {
            return nil
        }
    }

    func updateGiftIdea(_ idea: GiftIdea) {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
        }
    }

    func deleteGiftIdea(_ idea: GiftIdea) {
        guard let context = modelContext else { return }
        context.delete(idea)
        do {
            try context.save()
        } catch {
        }
    }

    func advanceStatus(of idea: GiftIdea) {
        if let nextStatus = idea.status.next {
            idea.status = nextStatus
            if nextStatus == .purchased {
                idea.purchasedAt = Date()
            }
            if nextStatus == .given, let person = idea.person {
                let description = idea.title
                let occasion = "Birthday"
                _ = addGiftHistory(
                    to: person,
                    description: description,
                    occasion: occasion,
                    dateGiven: Date()
                )
            }
            guard let context = modelContext else { return }
            do {
                try context.save()
            } catch {
            }
        }
    }

    func markAsPurchased(_ idea: GiftIdea, actualPrice: Double?) {
        idea.status = .purchased
        idea.purchasedAt = Date()
        if let price = actualPrice {
            idea.estimatedPrice = price
        }
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
        }
    }

    func addGiftHistory(
        to person: Person,
        description: String,
        occasion: String = "Birthday",
        dateGiven: Date = Date()
    ) -> GiftHistory? {
        guard let context = modelContext,
              !description.trimmingCharacters(in: .whitespaces).isEmpty else {
            return nil
        }

        let history = GiftHistory(
            giftDescription: description.trimmingCharacters(in: .whitespaces),
            occasion: occasion,
            dateGiven: dateGiven
        )
        history.person = person
        person.giftHistory.append(history)
        context.insert(history)

        do {
            try context.save()
            return history
        } catch {
            return nil
        }
    }

    func deleteGiftHistory(_ history: GiftHistory) {
        guard let context = modelContext else { return }
        context.delete(history)
        do {
            try context.save()
        } catch {
        }
    }

    func generateAISuggestions(
        for person: Person,
        budgetMin: Double,
        budgetMax: Double,
        isAIUnlocked: Bool
    ) async {
        let appleAIAvailable: Bool
        if #available(iOS 26, *) {
            appleAIAvailable = AppleIntelligenceService.shared.isAvailable
        } else {
            appleAIAvailable = false
        }

        guard #available(iOS 26, *), appleAIAvailable else {
            errorMessage = "Apple Intelligence is not available on this device. AI gift suggestions require iOS 26 or later with Apple Intelligence enabled."
            return
        }

        guard AIUsageTracker.shared.canUseFreeTier(isAIUnlocked: isAIUnlocked) else {
            errorMessage = "You've used all 3 free suggestions this month. Upgrade to AI Add-on for unlimited suggestions."
            return
        }

        isLoading = true
        errorMessage = nil
        aiSuggestions = []

        do {
            aiSuggestions = try await AppleIntelligenceService.shared.generateGiftSuggestions(
                person: person,
                budgetMin: budgetMin,
                budgetMax: budgetMax
            )
            if !isAIUnlocked {
                AIUsageTracker.shared.incrementUsage()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func addSuggestionAsIdea(_ suggestion: GiftSuggestion, to person: Person) -> GiftIdea? {
        let price = parsePriceRange(suggestion.priceRange)
        return addGiftIdea(
            to: person,
            title: suggestion.title,
            description: suggestion.reason,
            estimatedPrice: price,
            searchTerms: suggestion.searchTerms
        )
    }

    private func parsePriceRange(_ priceRange: String) -> Double? {
        let pattern = #"\d+(?:\.\d+)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let matches = regex.matches(in: priceRange, range: NSRange(priceRange.startIndex..., in: priceRange))
        let numbers = matches.compactMap { match -> Double? in
            guard let matchRange = Range(match.range, in: priceRange) else { return nil }
            return Double(priceRange[matchRange])
        }
        return numbers.max()
    }
}
