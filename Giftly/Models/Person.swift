import Foundation
import SwiftData

@Model
final class Person {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthday: Date
    var photoData: Data?
    var relationship: String?
    var interests: [String]
    var notes: String?
    var phoneNumber: String?
    var isFavorite: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \GiftIdea.person)
    var giftIdeas: [GiftIdea] = []

    @Relationship(deleteRule: .cascade, inverse: \GiftHistory.person)
    var giftHistory: [GiftHistory] = []

    init(
        name: String,
        birthday: Date,
        photoData: Data? = nil,
        relationship: String? = nil,
        interests: [String] = [],
        notes: String? = nil,
        phoneNumber: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.birthday = birthday
        self.photoData = photoData
        self.relationship = relationship
        self.interests = interests
        self.notes = notes
        self.phoneNumber = phoneNumber
        self.isFavorite = false
        self.createdAt = Date()
    }

    var nextBirthday: Date {
        let calendar = Calendar.current
        let now = Date()
        let birthComponents = calendar.dateComponents([.month, .day], from: birthday)
        if let nextDate = calendar.nextDate(
            after: now,
            matching: birthComponents,
            matchingPolicy: .nextTime
        ) {
            return nextDate
        }
        return birthday
    }

    var daysUntilBirthday: Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let birthday = calendar.startOfDay(for: nextBirthday)
        let components = calendar.dateComponents([.day], from: now, to: birthday)
        return components.day ?? 0
    }

    var upcomingAge: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: nextBirthday)
        return ageComponents.year ?? 0
    }

    var currentAge: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: Date())
        return ageComponents.year ?? 0
    }

    var isBirthdayToday: Bool {
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.month, .day], from: Date())
        let birthdayComponents = calendar.dateComponents([.month, .day], from: birthday)
        return todayComponents.month == birthdayComponents.month &&
               todayComponents.day == birthdayComponents.day
    }

    var zodiacSign: String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: birthday)
        let month = components.month ?? 1
        let day = components.day ?? 1

        switch (month, day) {
        case (3, 21...31), (4, 1...19): return "Aries"
        case (4, 20...30), (5, 1...20): return "Taurus"
        case (5, 21...31), (6, 1...20): return "Gemini"
        case (6, 21...30), (7, 1...22): return "Cancer"
        case (7, 23...31), (8, 1...22): return "Leo"
        case (8, 23...31), (9, 1...22): return "Virgo"
        case (9, 23...30), (10, 1...22): return "Libra"
        case (10, 23...31), (11, 1...21): return "Scorpio"
        case (11, 22...30), (12, 1...21): return "Sagittarius"
        case (12, 22...31), (1, 1...19): return "Capricorn"
        case (1, 20...31), (2, 1...18): return "Aquarius"
        case (2, 19...29), (3, 1...20): return "Pisces"
        default: return ""
        }
    }
}
