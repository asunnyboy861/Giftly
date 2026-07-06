import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppViewModel.self) private var appViewModel

    @Query(sort: [SortDescriptor(\Person.birthday)]) private var people: [Person]

    @State private var personViewModel = PersonViewModel()
    @State private var giftViewModel = GiftViewModel()
    @StateObject private var purchaseService = PurchaseService.shared

    @State private var selectedTab = 0
    @State private var showingAddPerson = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(Color("GiftlyPurple"))
        .environment(personViewModel)
        .environment(giftViewModel)
        .environmentObject(purchaseService)
        .onAppear {
            personViewModel.attach(context: modelContext)
            giftViewModel.attach(context: modelContext)
        }
    }

    private var HomeView: some View {
        NavigationStack {
            Group {
                if people.isEmpty {
                    EmptyStateView(
                        icon: "gift.fill",
                        title: "Never Forget a Birthday",
                        message: "Add the people you care about and Giftly will help you plan thoughtful gifts.",
                        actionTitle: "Add First Person",
                        action: { showingAddPerson = true }
                    )
                } else {
                    HomeContent
                }
            }
            .navigationTitle("Giftly")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddPerson = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPerson) {
                AddPersonView()
            }
        }
    }

    private var HomeContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !personViewModel.todaysBirthdays(from: people).isEmpty {
                    SectionTodayBirthdays
                }

                SectionUpcoming
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private var SectionTodayBirthdays: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "party.popper.fill")
                    .foregroundStyle(Color("GiftlyCoral"))
                Text("Today's Birthdays")
                    .font(.title3.weight(.semibold))
            }
            ForEach(personViewModel.todaysBirthdays(from: people)) { person in
                NavigationLink {
                    PersonDetailView(person: person)
                } label: {
                    BirthdayCardView(person: person, isToday: true)
                }
            }
        }
    }

    private var SectionUpcoming: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(Color("GiftlyPurple"))
                Text("Upcoming Birthdays")
                    .font(.title3.weight(.semibold))
            }
            ForEach(personViewModel.upcomingBirthdays(from: people, limit: 10)) { person in
                NavigationLink {
                    PersonDetailView(person: person)
                } label: {
                    BirthdayCardView(person: person, isToday: false)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppViewModel())
        .modelContainer(for: [Person.self, GiftIdea.self, GiftHistory.self], inMemory: true)
}
