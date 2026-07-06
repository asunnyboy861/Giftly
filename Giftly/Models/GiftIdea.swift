import Foundation
import SwiftData

@Model
final class GiftIdea {
    @Attribute(.unique) var id: UUID
    var person: Person?
    var title: String
    var giftDescription: String?
    var estimatedPrice: Double?
    var status: GiftStatus
    var searchTerms: String?
    var createdAt: Date
    var purchasedAt: Date?

    init(
        title: String,
        giftDescription: String? = nil,
        estimatedPrice: Double? = nil,
        searchTerms: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.giftDescription = giftDescription
        self.estimatedPrice = estimatedPrice
        self.status = .idea
        self.searchTerms = searchTerms
        self.createdAt = Date()
        self.purchasedAt = nil
    }
}
