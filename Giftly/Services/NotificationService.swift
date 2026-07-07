import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
    private init() {}

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func getNotificationSettings() async -> UNNotificationSettings {
        await center.notificationSettings()
    }

    func registerNotificationCategories() {
        let callAction = UNNotificationAction(
            identifier: "CALL_ACTION",
            title: "Call",
            options: []
        )
        let messageAction = UNNotificationAction(
            identifier: "MESSAGE_ACTION",
            title: "Message",
            options: []
        )
        let giftAction = UNNotificationAction(
            identifier: "GIFT_ACTION",
            title: "Gift Ideas",
            options: [.foreground]
        )

        let birthdayCategory = UNNotificationCategory(
            identifier: "BIRTHDAY_REMINDER",
            actions: [callAction, messageAction, giftAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        center.setNotificationCategories([birthdayCategory])
    }

    func scheduleBirthdayReminders(for person: Person, reminderDays: [Int] = [7, 1, 0], reminderHour: Int = 9) {
        cancelReminders(for: person.id)

        let calendar = Calendar.current
        let birthComponents = calendar.dateComponents([.month, .day], from: person.birthday)

        for daysBefore in reminderDays {
            var triggerComponents = DateComponents()
            triggerComponents.hour = reminderHour
            triggerComponents.minute = 0

            if daysBefore == 0 {
                triggerComponents.month = birthComponents.month
                triggerComponents.day = birthComponents.day
            } else {
                let triggerDate = calendar.date(
                    byAdding: .day,
                    value: -daysBefore,
                    to: person.nextBirthday
                ) ?? person.nextBirthday
                let adjustedComponents = calendar.dateComponents([.month, .day], from: triggerDate)
                triggerComponents.month = adjustedComponents.month
                triggerComponents.day = adjustedComponents.day
            }

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: triggerComponents,
                repeats: true
            )

            let content = UNMutableNotificationContent()
            content.title = "🎁 Giftly"
            content.sound = .default
            content.categoryIdentifier = "BIRTHDAY_REMINDER"
            var userInfo: [String: Any] = [
                "personId": person.id.uuidString,
                "personName": person.name,
                "daysBefore": daysBefore
            ]
            if let phone = person.phoneNumber, !phone.isEmpty {
                userInfo["phoneNumber"] = phone
            }
            content.userInfo = userInfo

            if daysBefore == 0 {
                content.body = "It's \(person.name)'s birthday today! 🎂 They're turning \(person.upcomingAge)."
            } else if daysBefore == 1 {
                content.body = "Tomorrow is \(person.name)'s birthday! Don't forget to prepare something. 🎁"
            } else {
                content.body = "\(person.name)'s birthday is in \(daysBefore) days! They're turning \(person.upcomingAge). Time to plan a gift? 🎁"
            }

            let identifier = "birthday-\(person.id.uuidString)-\(daysBefore)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            Task {
                do {
                    try await center.add(request)
                } catch {
                    print("Failed to schedule notification: \(error.localizedDescription)")
                }
            }
        }
    }

    func scheduleAllReminders(for people: [Person], reminderDays: [Int] = [7, 1, 0], reminderHour: Int = 9) {
        for person in people {
            scheduleBirthdayReminders(for: person, reminderDays: reminderDays, reminderHour: reminderHour)
        }
    }

    func cancelReminders(for personId: UUID) {
        let identifiers = [7, 1, 0].map {
            "birthday-\(personId.uuidString)-\($0)"
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func cancelAllReminders() {
        center.removeAllPendingNotificationRequests()
    }

    func getPendingNotificationCount() async -> Int {
        await center.pendingNotificationRequests().count
    }
}
