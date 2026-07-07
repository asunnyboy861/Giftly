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
    @State private var showingConfetti = false
    @State private var showingDeleteConfirm = false

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
                Menu {
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        showingEdit = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Divider()
                    Button(role: .destructive) {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showingDeleteConfirm = true
                    } label: {
                        Label("Delete Person", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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
        .overlay {
            if showingConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showingConfetti = false
                        }
                    }
            }
        }
        .onAppear {
            if person.isBirthdayToday {
                showingConfetti = true
            }
        }
        .alert("Delete Person?", isPresented: $showingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                personViewModel.deletePerson(person)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Delete \(person.name) and all their gift ideas and history? This cannot be undone.")
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
                Text("Birthday is today!")
                    .font(.headline)
                    .foregroundStyle(Color("GiftlyCoral"))
            } else {
                Text("\(person.daysUntilBirthday) days until birthday")
                    .font(.headline)
                    .foregroundStyle(Color("GiftlyPurple"))
            }

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                personViewModel.toggleFavorite(person)
            } label: {
                Label(
                    person.isFavorite ? "Favorited" : "Add to Favorites",
                    systemImage: person.isFavorite ? "star.fill" : "star"
                )
                .font(.caption.weight(.medium))
                .foregroundStyle(person.isFavorite ? Color("GiftlyCoral") : .secondary)
            }

            if let phone = person.phoneNumber, !phone.isEmpty {
                HStack(spacing: 12) {
                    if let telURL = URL(string: "tel:\(phone)"), telURL.scheme == "tel" {
                        Link(destination: telURL) {
                            Label("Call", systemImage: "phone.fill")
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("GiftlyMint"))
                    }
                    if let smsURL = URL(string: "sms:\(phone)"), smsURL.scheme == "sms" {
                        Link(destination: smsURL) {
                            Label("Message", systemImage: "message.fill")
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("GiftlyCoral"))
                    }
                }
                .padding(.top, 4)
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
                    UISelectionFeedbackGenerator().selectionChanged()
                    if purchaseService.isProUnlocked {
                        showingGiftIdeas = true
                    } else {
                        showingPaywall = true
                    }
                } label: {
                    Label("View List", systemImage: "list.bullet")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .tint(Color("GiftlyPurple"))

                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
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
                Text("No gifts recorded yet. When you mark a gift as Given, it will appear here.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(person.giftHistory.sorted(by: { $0.dateGiven > $1.dateGiven })) { history in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(history.giftDescription)
                                .font(.body)
                            Text("\(history.occasion) - \(formattedDate(history.dateGiven))")
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

struct ConfettiView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            ForEach(0..<30, id: \.self) { i in
                Circle()
                    .fill([Color("GiftlyPurple"), Color("GiftlyCoral"), Color("GiftlyMint")].randomElement() ?? .purple)
                    .frame(width: CGFloat.random(in: 6...12), height: CGFloat.random(in: 6...12))
                    .position(
                        x: UIScreen.main.bounds.width / 2,
                        y: UIScreen.main.bounds.height / 3
                    )
                    .offset(
                        x: animate ? CGFloat.random(in: -200...200) : 0,
                        y: animate ? CGFloat.random(in: 100...600) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .rotationEffect(.degrees(animate ? CGFloat.random(in: 0...360) : 0))
                    .animation(.easeOut(duration: 3).delay(Double.random(in: 0...0.3)), value: animate)
            }
        }
        .onAppear {
            animate = true
        }
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
