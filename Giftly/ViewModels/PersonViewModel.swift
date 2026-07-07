import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
@Observable
final class PersonViewModel {
    var modelContext: ModelContext?

    static let freeTierLimit = 5

    func attach(context: ModelContext) {
        self.modelContext = context
    }

    func canAddPerson(currentCount: Int, isProUnlocked: Bool) -> Bool {
        return isProUnlocked || currentCount < Self.freeTierLimit
    }

    func createPerson(
        name: String,
        birthday: Date,
        photoData: Data?,
        relationship: String?,
        interests: [String],
        notes: String?,
        phoneNumber: String? = nil
    ) -> Person? {
        guard let context = modelContext, !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return nil
        }

        let person = Person(
            name: name.trimmingCharacters(in: .whitespaces),
            birthday: birthday,
            photoData: photoData,
            relationship: relationship?.isEmpty == false ? relationship : nil,
            interests: interests.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty },
            notes: notes?.isEmpty == false ? notes : nil,
            phoneNumber: phoneNumber?.trimmingCharacters(in: .whitespaces).isEmpty == false
                ? phoneNumber?.trimmingCharacters(in: .whitespaces) : nil
        )
        context.insert(person)
        do {
            try context.save()
            NotificationService.shared.scheduleBirthdayReminders(for: person)
            return person
        } catch {
            return nil
        }
    }

    func updatePerson(_ person: Person) {
        guard let context = modelContext else { return }
        do {
            try context.save()
            NotificationService.shared.cancelReminders(for: person.id)
            NotificationService.shared.scheduleBirthdayReminders(for: person)
        } catch {
        }
    }

    func deletePerson(_ person: Person) {
        guard let context = modelContext else { return }
        NotificationService.shared.cancelReminders(for: person.id)
        context.delete(person)
        do {
            try context.save()
        } catch {
        }
    }

    func toggleFavorite(_ person: Person) {
        person.isFavorite.toggle()
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
        }
    }

    struct ContactImportResult {
        let importedCount: Int
        let denied: Bool
        let skippedDueToLimit: Int
    }

    func importFromContacts(existingPeople: [Person], isProUnlocked: Bool) async -> ContactImportResult {
        guard let context = modelContext else { return ContactImportResult(importedCount: 0, denied: false, skippedDueToLimit: 0) }

        let granted = await ContactImportService.shared.requestAccess()
        guard granted else { return ContactImportResult(importedCount: 0, denied: true, skippedDueToLimit: 0) }

        do {
            let fetchedPeople = try await ContactImportService.shared.fetchContactBirthdays()
            let newPeople = ContactImportService.shared.filterExistingContacts(
                newPeople: fetchedPeople,
                existingPeople: existingPeople
            )

            let availableSlots: Int
            if isProUnlocked {
                availableSlots = newPeople.count
            } else {
                availableSlots = max(0, Self.freeTierLimit - existingPeople.count)
            }

            let peopleToInsert = Array(newPeople.prefix(availableSlots))
            let skippedCount = newPeople.count - peopleToInsert.count

            for person in peopleToInsert {
                context.insert(person)
            }
            try context.save()

            for person in peopleToInsert {
                NotificationService.shared.scheduleBirthdayReminders(for: person)
            }

            return ContactImportResult(importedCount: peopleToInsert.count, denied: false, skippedDueToLimit: skippedCount)
        } catch {
            return ContactImportResult(importedCount: 0, denied: false, skippedDueToLimit: 0)
        }
    }

    func upcomingBirthdays(from people: [Person], limit: Int = 5) -> [Person] {
        return people
            .filter { $0.daysUntilBirthday >= 0 }
            .sorted { $0.daysUntilBirthday < $1.daysUntilBirthday }
            .prefix(limit)
            .map { $0 }
    }

    func todaysBirthdays(from people: [Person]) -> [Person] {
        return people.filter { $0.isBirthdayToday }
    }

    func favorites(from people: [Person]) -> [Person] {
        return people.filter { $0.isFavorite }
    }

    func searchPeople(_ people: [Person], query: String) -> [Person] {
        guard !query.isEmpty else { return people }
        let lowercased = query.lowercased()
        return people.filter { person in
            if person.name.lowercased().contains(lowercased) { return true }
            if let relationship = person.relationship,
               relationship.lowercased().contains(lowercased) { return true }
            if person.interests.contains(where: { $0.lowercased().contains(lowercased) }) {
                return true
            }
            return false
        }
    }
}
