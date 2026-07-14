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
    @State private var activeSheet: ActiveSheet?
    @State private var importInProgress = false
    @State private var importResult: PersonViewModel.ContactImportResult?
    @State private var deepLinkPersonId: String?
    @State private var deepLinkPerson: Person?

    private enum ActiveSheet: Identifiable {
        case addPerson
        case paywall
        case editPerson(Person)

        var id: String {
            switch self {
            case .addPerson: return "addPerson"
            case .paywall: return "paywall"
            case .editPerson(let person): return "editPerson-\(person.id.uuidString)"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                activeSheet: $activeSheet,
                deepLinkPerson: $deepLinkPerson,
                importInProgress: $importInProgress,
                importResult: $importResult,
                personViewModel: personViewModel,
                giftViewModel: giftViewModel,
                purchaseService: purchaseService
            )
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
        .onReceive(NotificationCenter.default.publisher(for: NotificationDelegate.deepLinkNotification)) { note in
            handleDeepLink(note)
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .addPerson:
                AddPersonView()
                    .environment(personViewModel)
            case .paywall:
                PaywallView()
            case .editPerson(let person):
                AddPersonView(person: person)
                    .environment(personViewModel)
            }
        }
        .alert("Import Complete", isPresented: Binding(
            get: { importResult != nil && importResult!.importedCount > 0 && importResult!.skippedDueToLimit == 0 && !importResult!.denied },
            set: { if !$0 { importResult = nil } }
        )) {
            Button("OK") { importResult = nil }
        } message: {
            if let result = importResult, result.importedCount > 0, result.skippedDueToLimit == 0 {
                Text("Successfully imported \(result.importedCount) birthday\(result.importedCount == 1 ? "" : "s") from your contacts.")
            }
        }
        .alert("Free Tier Limit Reached", isPresented: Binding(
            get: { importResult != nil && importResult!.skippedDueToLimit > 0 && !importResult!.denied },
            set: { if !$0 { importResult = nil } }
        )) {
            Button("Upgrade to Pro") {
                activeSheet = .paywall
                importResult = nil
            }
            Button("OK", role: .cancel) { importResult = nil }
        } message: {
            if let result = importResult, result.skippedDueToLimit > 0 {
                Text("Imported \(result.importedCount) birthday\(result.importedCount == 1 ? "" : "s"). \(result.skippedDueToLimit) contact\(result.skippedDueToLimit == 1 ? " was" : "s were") skipped because the free tier is limited to \(PersonViewModel.freeTierLimit) people. Upgrade to Pro for unlimited people.")
            }
        }
        .alert("Contact Access Denied", isPresented: Binding(
            get: { importResult?.denied == true },
            set: { if !$0 { importResult = nil } }
        )) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { importResult = nil }
        } message: {
            Text("Giftly needs access to your contacts to import birthdays. Please enable Contacts access in Settings.")
        }
        .alert("No New Birthdays", isPresented: Binding(
            get: { importResult != nil && importResult!.importedCount == 0 && !importResult!.denied && importResult!.skippedDueToLimit == 0 },
            set: { if !$0 { importResult = nil } }
        )) {
            Button("OK") { importResult = nil }
        } message: {
            Text("No new birthdays found in your contacts. You can add them manually.")
        }
    }

    private struct HomeView: View {
        @Binding var activeSheet: ActiveSheet?
        @Binding var deepLinkPerson: Person?
        @Binding var importInProgress: Bool
        @Binding var importResult: PersonViewModel.ContactImportResult?

        @Query(sort: [SortDescriptor(\Person.birthday)]) private var people: [Person]

        let personViewModel: PersonViewModel
        let giftViewModel: GiftViewModel
        let purchaseService: PurchaseService

        var body: some View {
            NavigationStack {
                Group {
                    if people.isEmpty {
                        EmptyStateView(
                            icon: "gift.fill",
                            title: "Never Forget a Birthday",
                            message: "Import birthdays from your contacts, or add them manually.",
                            actionTitle: "Import from Contacts",
                            action: { startContactImport() },
                            secondaryActionTitle: "Add Manually",
                            secondaryAction: { attemptAddPerson() }
                        )
                    } else {
                        HomeContent(
                            people: people,
                            personViewModel: personViewModel,
                            purchaseService: purchaseService,
                            activeSheet: $activeSheet
                        )
                    }
                }
                .navigationTitle("Giftly")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            startContactImport()
                        } label: {
                            if importInProgress {
                                ProgressView()
                            } else {
                                Image(systemName: "person.2.badge.gearshape")
                            }
                        }
                        .disabled(importInProgress)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            attemptAddPerson()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityIdentifier("addPersonButton")
                    }
                }
                .sheet(item: $deepLinkPerson) { person in
                    NavigationStack {
                        PersonDetailView(person: person)
                    }
                    .environment(personViewModel)
                    .environment(giftViewModel)
                }
            }
        }

        private func attemptAddPerson() {
            if personViewModel.canAddPerson(currentCount: people.count, isProUnlocked: purchaseService.isProUnlocked) {
                activeSheet = .addPerson
            } else {
                activeSheet = .paywall
            }
        }

        private func startContactImport() {
            importInProgress = true
            Task {
                let result = await personViewModel.importFromContacts(
                    existingPeople: people,
                    isProUnlocked: purchaseService.isProUnlocked
                )
                importInProgress = false
                importResult = result
            }
        }
    }

    private struct HomeContent: View {
        let people: [Person]
        let personViewModel: PersonViewModel
        let purchaseService: PurchaseService
        @Binding var activeSheet: ActiveSheet?

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    if !personViewModel.todaysBirthdays(from: people).isEmpty {
                        SectionTodayBirthdays
                    }

                    SectionUpcoming

                    if people.count >= PersonViewModel.freeTierLimit && !purchaseService.isProUnlocked {
                        UpgradeBanner
                    }
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
                    .buttonStyle(PressableCardStyle())
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
                    .buttonStyle(PressableCardStyle())
                }
            }
        }

        private var UpgradeBanner: some View {
            Button {
                activeSheet = .paywall
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Unlock Unlimited Birthdays")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Free tier limited to \(PersonViewModel.freeTierLimit) people. Upgrade for unlimited.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("GiftlyPurple").gradient)
                )
            }
        }
    }

    private func handleDeepLink(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let action = userInfo["action"] as? String ?? "open"

        if action == "giftIdeas", let personIdString = userInfo["personId"] as? String {
            deepLinkPersonId = personIdString
            deepLinkPerson = people.first { $0.id.uuidString == personIdString }
            selectedTab = 0
        } else if action == "open", let personIdString = userInfo["personId"] as? String {
            deepLinkPerson = people.first { $0.id.uuidString == personIdString }
            selectedTab = 0
        }
    }
}

struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
        .environment(AppViewModel())
        .modelContainer(for: [Person.self, GiftIdea.self, GiftHistory.self], inMemory: true)
}
