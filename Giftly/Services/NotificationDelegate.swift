import Foundation
import UserNotifications
import SwiftUI

@MainActor
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    static let deepLinkNotification = Notification.Name("GiftlyDeepLinkNotification")

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let personId = userInfo["personId"] as? String
        let phoneNumber = userInfo["phoneNumber"] as? String
        let actionIdentifier = response.actionIdentifier

        switch actionIdentifier {
        case "CALL_ACTION":
            handleCall(phoneNumber: phoneNumber)
        case "MESSAGE_ACTION":
            handleMessage(phoneNumber: phoneNumber)
        case "GIFT_ACTION":
            if let personId = personId {
                NotificationCenter.default.post(
                    name: Self.deepLinkNotification,
                    object: nil,
                    userInfo: ["personId": personId, "action": "giftIdeas"]
                )
            }
        default:
            if let personId = personId {
                NotificationCenter.default.post(
                    name: Self.deepLinkNotification,
                    object: nil,
                    userInfo: ["personId": personId, "action": "open"]
                )
            }
        }

        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    private func handleCall(phoneNumber: String?) {
        if let phone = phoneNumber, !phone.isEmpty,
           let url = URL(string: "tel:\(phone)"), url.scheme == "tel" {
            UIApplication.shared.open(url)
        }
    }

    private func handleMessage(phoneNumber: String?) {
        if let phone = phoneNumber, !phone.isEmpty,
           let url = URL(string: "sms:\(phone)"), url.scheme == "sms" {
            UIApplication.shared.open(url)
        }
    }
}
