import Foundation
import UserNotifications

enum NotificationManager {
    static func requestPermission() async {
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound])
    }

    /// Schedules "your seal broke" for the moment a relic unlocks.
    static func schedule(title: String, at date: Date, id: String) {
        let content = UNMutableNotificationContent()
        content.title = "A seal has broken"
        content.body = "\"\(title)\" can now be opened."
        content.sound = .default

        let parts = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
