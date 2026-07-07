import SwiftUI
import SwiftData
import UserNotifications

@main
struct GiftlyApp: App {
    let modelContainer: ModelContainer

    @State private var appViewModel = AppViewModel()

    init() {
        do {
            let schema = Schema([
                Person.self,
                GiftIdea.self,
                GiftHistory.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }

        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if appViewModel.hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .environment(appViewModel)
            .modelContainer(modelContainer)
            .task {
                NotificationService.shared.registerNotificationCategories()
                await rescheduleAllReminders()
            }
        }
    }

    @MainActor
    private func rescheduleAllReminders() async {
        let context = modelContainer.mainContext
        let descriptor = FetchDescriptor<Person>()
        if let people = try? context.fetch(descriptor) {
            NotificationService.shared.scheduleAllReminders(for: people)
        }
    }
}
