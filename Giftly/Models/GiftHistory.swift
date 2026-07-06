import Foundation
import SwiftData

@Model
final class GiftHistory {
    @Attribute(.unique) var id: UUID
    var person: Person?
    var giftDescription: String
    var occasion: String
    var dateGiven: Date

    init(
        giftDescription: String,
        occasion: String = "Birthday",
        dateGiven: Date = Date()
    ) {
        self.id = UUID()
        self.giftDescription = giftDescription
        self.occasion = occasion
        self.dateGiven = dateGiven
    }
}
