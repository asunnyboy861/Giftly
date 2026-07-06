import SwiftUI
import SwiftData

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
            }
        }
    }
}
