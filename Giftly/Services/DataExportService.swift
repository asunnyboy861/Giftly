import Foundation
import SwiftData
import UIKit

struct PersonExportData: Codable {
    let name: String
    let birthday: Date
    let relationship: String?
    let interests: [String]
    let notes: String?
    let phoneNumber: String?
    let isFavorite: Bool
    let giftIdeas: [GiftIdeaExportData]
    let giftHistory: [GiftHistoryExportData]
}

struct GiftIdeaExportData: Codable {
    let title: String
    let giftDescription: String?
    let estimatedPrice: Double?
    let status: String
    let searchTerms: String?
}

struct GiftHistoryExportData: Codable {
    let giftDescription: String
    let occasion: String
    let dateGiven: Date
}

struct ExportEnvelope: Codable {
    let appVersion: String
    let exportDate: Date
    let people: [PersonExportData]
}

@MainActor
final class DataExportService {
    static let shared = DataExportService()
    private init() {}

    func exportPeople(_ people: [Person]) -> Data? {
        let exportData = people.map { person in
            PersonExportData(
                name: person.name,
                birthday: person.birthday,
                relationship: person.relationship,
                interests: person.interests,
                notes: person.notes,
                phoneNumber: person.phoneNumber,
                isFavorite: person.isFavorite,
                giftIdeas: person.giftIdeas.map { idea in
                    GiftIdeaExportData(
                        title: idea.title,
                        giftDescription: idea.giftDescription,
                        estimatedPrice: idea.estimatedPrice,
                        status: idea.status.rawValue,
                        searchTerms: idea.searchTerms
                    )
                },
                giftHistory: person.giftHistory.map { history in
                    GiftHistoryExportData(
                        giftDescription: history.giftDescription,
                        occasion: history.occasion,
                        dateGiven: history.dateGiven
                    )
                }
            )
        }

        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let envelope = ExportEnvelope(
            appVersion: appVersion,
            exportDate: Date(),
            people: exportData
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? encoder.encode(envelope)
    }

    func importPeople(from data: Data, into context: ModelContext) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let envelope = try decoder.decode(ExportEnvelope.self, from: data)

        for personData in envelope.people {
            let person = Person(
                name: personData.name,
                birthday: personData.birthday,
                relationship: personData.relationship,
                interests: personData.interests,
                notes: personData.notes,
                phoneNumber: personData.phoneNumber
            )
            person.isFavorite = personData.isFavorite

            for ideaData in personData.giftIdeas {
                let idea = GiftIdea(
                    title: ideaData.title,
                    giftDescription: ideaData.giftDescription,
                    estimatedPrice: ideaData.estimatedPrice,
                    searchTerms: ideaData.searchTerms
                )
                idea.status = GiftStatus(rawValue: ideaData.status) ?? .idea
                person.giftIdeas.append(idea)
                idea.person = person
            }

            for historyData in personData.giftHistory {
                let history = GiftHistory(
                    giftDescription: historyData.giftDescription,
                    occasion: historyData.occasion,
                    dateGiven: historyData.dateGiven
                )
                person.giftHistory.append(history)
                history.person = person
            }

            context.insert(person)
        }

        try context.save()
    }

    func saveExportToFile(_ data: Data, filename: String = "GiftlyBackup") -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: Date())
        let fullFilename = "\(filename)_\(dateStr).json"

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fullFilename)
        do {
            try data.write(to: tempURL, options: .atomic)
            return tempURL
        } catch {
            return nil
        }
    }
}
