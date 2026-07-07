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
        canGenerate: Bool
    ) async {
        guard canGenerate else {
            errorMessage = "Unlock AI or add your API key in Settings."
            return
        }

        isLoading = true
        errorMessage = nil
        aiSuggestions = []

        do {
            aiSuggestions = try await GiftAIService.shared.generateGiftSuggestions(
                person: person,
                budgetMin: budgetMin,
                budgetMax: budgetMax
            )
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

    private func parsePriceRange(_ range: String) -> Double? {
        let numbers = range.compactMap { char -> Double? in
            if char.isNumber || char == "." {
                return char.wholeNumberValue.map(Double.init)
            }
            return nil
        }
        if numbers.isEmpty { return nil }
        return numbers.max()
    }
}
