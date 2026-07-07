import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PersonViewModel.self) private var personViewModel

    @Query(sort: [SortDescriptor(\Person.birthday)]) private var people: [Person]

    @State private var searchText = ""
    @State private var filterFavorites = false
    @State private var personToDelete: Person?
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            List {
                if filteredPeople.isEmpty {
                    ContentUnavailableView(
                        filterFavorites ? "No Favorites Yet" : "No People Yet",
                        systemImage: filterFavorites ? "star" : "person.2",
                        description: Text(filterFavorites ? "Mark people as favorites to see them here." : "Add people to see their birthdays here.")
                    )
                } else {
                    ForEach(monthGroups, id: \.0) { month, group in
                        Section {
                            ForEach(group) { person in
                                NavigationLink {
                                    PersonDetailView(person: person)
                                } label: {
                                    CalendarRow(person: person)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        personToDelete = person
                                        showDeleteConfirm = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        } header: {
                            Text(month)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Calendar")
            .searchable(text: $searchText, prompt: "Search people")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        filterFavorites.toggle()
                    } label: {
                        Image(systemName: filterFavorites ? "star.fill" : "star")
                            .foregroundStyle(filterFavorites ? Color("GiftlyCoral") : .accentColor)
                    }
                }
            }
            .alert("Delete Person?", isPresented: $showDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    if let person = personToDelete {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        personViewModel.deletePerson(person)
                    }
                    personToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    personToDelete = nil
                }
            } message: {
                if let person = personToDelete {
                    Text("Delete \(person.name) and all their gift ideas and history? This cannot be undone.")
                }
            }
        }
    }

    private var filteredPeople: [Person] {
        var result = people
        if filterFavorites {
            result = personViewModel.favorites(from: result)
        }
        if !searchText.isEmpty {
            result = personViewModel.searchPeople(result, query: searchText)
        }
        return result
    }

    private var monthGroups: [(String, [Person])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: filteredPeople) { person -> Int in
            calendar.dateComponents([.month], from: person.nextBirthday).month ?? 0
        }

        return grouped
            .sorted { $0.key < $1.key }
            .map { (monthIdx, people) in
                let date = calendar.date(from: DateComponents(month: monthIdx, day: 1)) ?? Date()
                let monthName = formatter.string(from: date)
                return (monthName, people.sorted { $0.daysUntilBirthday < $1.daysUntilBirthday })
            }
    }
}

struct CalendarRow: View {
    let person: Person

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(photoData: person.photoData, name: person.name, size: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(.body.weight(.medium))
                if let relationship = person.relationship, !relationship.isEmpty {
                    Text(relationship)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(birthdayDateText)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color("GiftlyPurple"))
                Text(person.daysUntilBirthday == 0 ? "Today!" : "\(person.daysUntilBirthday) days")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var birthdayDateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: person.nextBirthday)
    }
}

#Preview {
    CalendarView()
        .environment(AppViewModel())
        .environment(PersonViewModel())
        .modelContainer(for: Person.self, inMemory: true)
}
