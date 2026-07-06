import SwiftUI
import SwiftData

struct PersonDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(PersonViewModel.self) private var personViewModel
    @Environment(GiftViewModel.self) private var giftViewModel

    let person: Person

    @State private var showingEdit = false
    @State private var showingGiftIdeas = false
    @State private var showingAISuggestions = false
    @State private var showingPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeaderCard
                StatsGrid
                GiftIdeasSection
                GiftHistorySection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEdit = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddPersonView(person: person)
        }
        .sheet(isPresented: $showingGiftIdeas) {
            GiftIdeaListView(person: person)
        }
        .sheet(isPresented: $showingAISuggestions) {
            GiftSuggestionView(person: person)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    private var HeaderCard: some View {
        VStack(spacing: 12) {
            AvatarView(photoData: person.photoData, name: person.name, size: 100)

            Text(person.name)
                .font(.title2.weight(.bold))

            if let relationship = person.relationship, !relationship.isEmpty {
                Text(relationship)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                Image(systemName: "cake")
                Text(formattedBirthday)
            }
            .font(.caption)
            .foregroundStyle(Color("GiftlyPurple"))

            if person.isBirthdayToday {
                Text("🎉 Birthday is today!")
                    .font(.headline)
                    .foregroundStyle(Color("GiftlyCoral"))
            } else {
                Text("\(person.daysUntilBirthday) days until birthday")
                    .font(.headline)
                    .foregroundStyle(Color("GiftlyPurple"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var StatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Turning",
                value: "\(person.upcomingAge)",
                subtitle: "years old",
                icon: "number",
                color: "GiftlyCoral"
            )
            StatCard(
                title: "Zodiac",
                value: person.zodiacSign,
                subtitle: "sign",
                icon: "sparkles",
                color: "GiftlyMint"
            )
        }
    }

    private var GiftIdeasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "gift")
                    .foregroundStyle(Color("GiftlyCoral"))
                Text("Gift Ideas")
                    .font(.headline)
                Spacer()
                Text("\(person.giftIdeas.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                Button {
                    showingGiftIdeas = true
                } label: {
                    Label("View List", systemImage: "list.bullet")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .tint(Color("GiftlyPurple"))

                Button {
                    if purchaseService_canUseAI {
                        showingAISuggestions = true
                    } else {
                        showingPaywall = true
                    }
                } label: {
                    Label("AI Ideas", systemImage: "wand.and.stars")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .tint(Color("GiftlyCoral"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    @EnvironmentObject private var purchaseService: PurchaseService

    private var purchaseService_canUseAI: Bool {
        purchaseService.isAIUnlocked && GiftAIService.shared.hasAPIKey
    }

    private var GiftHistorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock")
                    .foregroundStyle(Color("GiftlyMint"))
                Text("Gift History")
                    .font(.headline)
                Spacer()
                Text("\(person.giftHistory.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if person.giftHistory.isEmpty {
                Text("No gifts recorded yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(person.giftHistory.sorted(by: { $0.dateGiven > $1.dateGiven })) { history in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(history.giftDescription)
                                .font(.body)
                            Text("\(history.occasion) · \(formattedDate(history.dateGiven))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    if history.id != person.giftHistory.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var formattedBirthday: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: person.birthday)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color(color))
            Text(value)
                .font(.title2.weight(.bold))
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NavigationStack {
        PersonDetailView(person: Person(name: "Sarah", birthday: Date()))
            .environment(AppViewModel())
            .environment(PersonViewModel())
            .environment(GiftViewModel())
            .environmentObject(PurchaseService.shared)
            .modelContainer(for: [Person.self, GiftIdea.self, GiftHistory.self], inMemory: true)
    }
}
