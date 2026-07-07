import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
@Observable
final class AppViewModel {
    var hasCompletedOnboarding: Bool

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        hasCompletedOnboarding = true
    }

    func requestNotificationPermission() async -> Bool {
        let granted = await NotificationService.shared.requestPermission()
        if granted {
            NotificationService.shared.registerNotificationCategories()
            UserDefaults.standard.set(true, forKey: "notificationsEnabled")
        }
        return granted
    }

    func rescheduleAllReminders(for people: [Person]) {
        NotificationService.shared.scheduleAllReminders(for: people)
    }

    func appVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    func supportURL() -> URL? {
        URL(string: "https://asunnyboy861.github.io/Giftly/support.html")
    }

    func privacyPolicyURL() -> URL? {
        URL(string: "https://asunnyboy861.github.io/Giftly/privacy.html")
    }

    func termsOfUseURL() -> URL? {
        URL(string: "https://asunnyboy861.github.io/Giftly/terms.html")
    }
}
