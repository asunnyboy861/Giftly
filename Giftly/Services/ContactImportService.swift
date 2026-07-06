import Foundation
@preconcurrency import Contacts
import SwiftData

@MainActor
final class ContactImportService: @unchecked Sendable {
    static let shared = ContactImportService()
    private let store = CNContactStore()
    private init() {}

    func requestAccess() async -> Bool {
        do {
            return try await store.requestAccess(for: .contacts)
        } catch {
            return false
        }
    }

    func fetchContactBirthdays() async throws -> [Person] {
        let keys: [CNKeyDescriptor] = [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactBirthdayKey,
            CNContactImageDataKey,
            CNContactThumbnailImageDataKey
        ] as [CNKeyDescriptor]

        let request = CNContactFetchRequest(keysToFetch: keys)

        let people: [Person] = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[Person], Error>) in
            DispatchQueue.global(qos: .userInitiated).async { [store] in
                var collected: [Person] = []
                do {
                    try store.enumerateContacts(with: request) { contact, _ in
                        guard let birthdayComponents = contact.birthday,
                              let birthday = Calendar.current.date(from: birthdayComponents) else {
                            return
                        }

                        let fullName = [
                            contact.givenName,
                            contact.familyName
                        ].filter { !$0.isEmpty }.joined(separator: " ").trimmingCharacters(in: .whitespaces)

                        guard !fullName.isEmpty else { return }

                        let photoData = contact.imageData ?? contact.thumbnailImageData
                        let person = Person(
                            name: fullName,
                            birthday: birthday,
                            photoData: photoData
                        )
                        collected.append(person)
                    }
                    continuation.resume(returning: collected)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        return people
    }

    func filterExistingContacts(
        newPeople: [Person],
        existingPeople: [Person]
    ) -> [Person] {
        let existingKeys = Set(existingPeople.map { person in
            person.name.lowercased().trimmingCharacters(in: .whitespaces)
        })
        return newPeople.filter { person in
            let key = person.name.lowercased().trimmingCharacters(in: .whitespaces)
            return !existingKeys.contains(key)
        }
    }
}
