import SwiftUI
import SwiftData

struct GiftIdeaListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GiftViewModel.self) private var giftViewModel

    let person: Person

    @State private var showingAdd = false
    @State private var newIdeaTitle = ""
    @State private var newIdeaPrice: String = ""
    @State private var newIdeaDescription = ""

    var body: some View {
        NavigationStack {
            List {
                if person.giftIdeas.isEmpty {
                    ContentUnavailableView(
                        "No Gift Ideas Yet",
                        systemImage: "gift",
                        description: Text("Tap + to add your first idea, or use AI suggestions.")
                    )
                } else {
                    ForEach(statusSections, id: \.0) { status, ideas in
                        if !ideas.isEmpty {
                            Section {
                                ForEach(ideas) { idea in
                                    GiftIdeaRow(idea: idea)
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                giftViewModel.deleteGiftIdea(idea)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                            Button {
                                                giftViewModel.advanceStatus(of: idea)
                                            } label: {
                                                Label(idea.status.next?.rawValue ?? "Done",
                                                      systemImage: idea.status.next?.systemImage ?? "checkmark")
                                            }
                                            .tint(Color("GiftlyMint"))
                                        }
                                }
                            } header: {
                                HStack {
                                    Image(systemName: status.systemImage)
                                    Text(status.rawValue)
                                    Spacer()
                                    Text("\(ideas.count)")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Gift Ideas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddGiftIdeaSheet()
            }
        }
    }

    private var statusSections: [(GiftStatus, [GiftIdea])] {
        GiftStatus.allCases.map { status in
            (status, person.giftIdeas.filter { $0.status == status }.sorted { $0.createdAt > $1.createdAt })
        }
    }

    private func AddGiftIdeaSheet() -> some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Gift title", text: $newIdeaTitle)
                    TextField("Estimated price ($)", text: $newIdeaPrice)
                        .keyboardType(.decimalPad)
                    TextField("Notes (optional)", text: $newIdeaDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Idea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        newIdeaTitle = ""
                        newIdeaPrice = ""
                        newIdeaDescription = ""
                        showingAdd = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addIdea()
                    }
                    .disabled(newIdeaTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func addIdea() {
        let price = Double(newIdeaPrice.trimmingCharacters(in: .whitespaces))
        _ = giftViewModel.addGiftIdea(
            to: person,
            title: newIdeaTitle,
            description: newIdeaDescription,
            estimatedPrice: price,
            searchTerms: nil
        )
        newIdeaTitle = ""
        newIdeaPrice = ""
        newIdeaDescription = ""
        showingAdd = false
    }
}

struct GiftIdeaRow: View {
    let idea: GiftIdea

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: idea.status.systemImage)
                .font(.title3)
                .foregroundStyle(Color(idea.status.statusColor))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(idea.title)
                    .font(.body.weight(.medium))
                if let desc = idea.giftDescription, !desc.isEmpty {
                    Text(desc)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                if let price = idea.estimatedPrice {
                    Text(String(format: "$%.2f", price))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color("GiftlyPurple"))
                }
            }
        }
        .padding(.vertical, 4)
    }
}

extension GiftStatus {
    var statusColor: String {
        switch self {
        case .idea: return "GiftlyPurple"
        case .planned: return "GiftlyMint"
        case .purchased: return "GiftlyCoral"
        case .given: return "secondary"
        }
    }
}

#Preview {
    GiftIdeaListView(person: Person(name: "Sarah", birthday: Date()))
        .environment(AppViewModel())
        .environment(GiftViewModel())
        .modelContainer(for: [Person.self, GiftIdea.self, GiftHistory.self], inMemory: true)
}
