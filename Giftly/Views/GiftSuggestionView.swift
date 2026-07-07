import SwiftUI
import SwiftData

struct GiftSuggestionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GiftViewModel.self) private var giftViewModel
    @EnvironmentObject private var purchaseService: PurchaseService

    let person: Person

    @State private var budgetMin: Double = 20
    @State private var budgetMax: Double = 80
    @State private var hasGenerated: Bool = false

    private var canGenerate: Bool {
        purchaseService.isAIUnlocked && GiftAIService.shared.hasAPIKey
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if !canGenerate {
                        LockedState
                    } else {
                        BudgetCard
                        if giftViewModel.isLoading {
                            LoadingCard
                        } else if let error = giftViewModel.errorMessage {
                            ErrorCard(error)
                        } else if giftViewModel.aiSuggestions.isEmpty && hasGenerated {
                            EmptyResultsCard
                        } else if !giftViewModel.aiSuggestions.isEmpty {
                            SuggestionsList
                        } else {
                            PromptCard
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("AI Suggestions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var LockedState: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color("GiftlyCoral").gradient)
            Text("Unlock AI Suggestions")
                .font(.title3.weight(.bold))
            Text("Get personalized gift ideas powered by AI. Add your API key in Settings to get started.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            NavigationLink {
                SettingsView()
            } label: {
                Text("Open Settings")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("GiftlyPurple"))
            .padding(.horizontal)
        }
        .padding()
    }

    private var BudgetCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundStyle(Color("GiftlyMint"))
                Text("Budget Range")
                    .font(.headline)
                Spacer()
                Text("$\(Int(budgetMin)) - $\(Int(budgetMax))")
                    .font(.headline)
                    .foregroundStyle(Color("GiftlyPurple"))
            }
            VStack(alignment: .leading) {
                Text("Min: $\(Int(budgetMin))")
                    .font(.caption)
                Slider(value: $budgetMin, in: 0...500, step: 5) { editing in
                    if !editing && budgetMin > budgetMax {
                        budgetMax = budgetMin
                    }
                }
                .tint(Color("GiftlyMint"))
            }
            VStack(alignment: .leading) {
                Text("Max: $\(Int(budgetMax))")
                    .font(.caption)
                Slider(value: $budgetMax, in: 0...1000, step: 5) { editing in
                    if !editing && budgetMax < budgetMin {
                        budgetMin = budgetMax
                    }
                }
                .tint(Color("GiftlyPurple"))
            }
            Button {
                Task {
                    await generate()
                }
            } label: {
                Label("Generate Ideas", systemImage: "wand.and.stars")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color("GiftlyCoral"))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var PromptCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 48))
                .foregroundStyle(Color("GiftlyCoral").gradient)
            Text("Ready to generate")
                .font(.headline)
            Text("Tap \"Generate Ideas\" above to get 5 personalized gift suggestions for \(person.name).")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var LoadingCard: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
            Text("Generating ideas for \(person.name)...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func ErrorCard(_ error: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.red.gradient)
            Text(error)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task { await generate() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var EmptyResultsCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("No suggestions returned. Try adjusting the budget.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var SuggestionsList: some View {
        VStack(spacing: 12) {
            ForEach(giftViewModel.aiSuggestions) { suggestion in
                SuggestionCard(suggestion: suggestion) {
                    _ = giftViewModel.addSuggestionAsIdea(suggestion, to: person)
                }
            }
        }
    }

    private func generate() async {
        hasGenerated = true
        await giftViewModel.generateAISuggestions(
            for: person,
            budgetMin: budgetMin,
            budgetMax: budgetMax,
            canGenerate: canGenerate
        )
    }
}

struct SuggestionCard: View {
    let suggestion: GiftSuggestion
    var onAdd: () -> Void

    @State private var added = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(suggestion.title)
                    .font(.headline)
                Spacer()
                Text(suggestion.priceRange)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color("GiftlyPurple").opacity(0.15)))
                    .foregroundStyle(Color("GiftlyPurple"))
            }
            Text(suggestion.reason)
                .font(.body)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.caption)
                Text(suggestion.searchTerms)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            HStack(spacing: 8) {
                Button {
                    onAdd()
                    added = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Label(added ? "Added" : "Add as Idea", systemImage: added ? "checkmark" : "plus")
                        .font(.caption.weight(.medium))
                }
                .buttonStyle(.bordered)
                .tint(Color("GiftlyMint"))
                .disabled(added)

                if let searchURL = amazonSearchURL(suggestion.searchTerms) {
                    Link(destination: searchURL) {
                        Label("Search", systemImage: "cart.fill")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.bordered)
                    .tint(Color("GiftlyCoral"))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func amazonSearchURL(_ terms: String) -> URL? {
        let encoded = terms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? terms
        return URL(string: "https://www.amazon.com/s?k=\(encoded)")
    }
}

#Preview {
    GiftSuggestionView(person: Person(name: "Sarah", birthday: Date()))
        .environment(AppViewModel())
        .environment(GiftViewModel())
        .environmentObject(PurchaseService.shared)
        .modelContainer(for: Person.self, inMemory: true)
}
