import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Register Flutter plugins
        GeneratedPluginRegistrant.register(with: self)
        
        // Configure notification handling
        configureNotifications(application)
        
        // Check if app was launched from notification
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            handleNotificationPayload(notification)
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Notification Configuration
    
    private func configureNotifications(_ application: UIApplication) {
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        // Configure notification categories for actionable notifications
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK",
            title: "Mark Complete ✓",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_TASK",
            title: "Snooze 15 min",
            options: []
        )
        
        let breakdownAction = UNNotificationAction(
            identifier: "BREAKDOWN_TASK",
            title: "Break it down",
            options: [.foreground]
        )
        
        // Task reminder category
        let taskCategory = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, snoozeAction, breakdownAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Gentle nudge category (for ADHD-friendly reminders)
        let nudgeCategory = UNNotificationCategory(
            identifier: "GENTLE_NUDGE",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register categories
        UNUserNotificationCenter.current().setNotificationCategories([taskCategory, nudgeCategory])
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Handle notification when app is in foreground
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier
        
        // Handle different actions
        switch actionIdentifier {
        case "COMPLETE_TASK":
            handleCompleteTask(userInfo: userInfo)
        case "SNOOZE_TASK":
            handleSnoozeTask(userInfo: userInfo)
        case "BREAKDOWN_TASK":
            handleBreakdownTask(userInfo: userInfo)
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification itself
            handleNotificationTap(userInfo: userInfo)
        default:
            break
        }
        
        completionHandler()
    }
    
    // MARK: - Notification Action Handlers
    
    private func handleNotificationPayload(_ payload: [String: AnyObject]) {
        // Forward to Flutter via method channel if needed
        if let taskId = payload["taskId"] as? String {
            // Navigate to specific task
            navigateToTask(taskId: taskId)
        }
    }
    
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        if let taskId = userInfo["taskId"] as? String {
            navigateToTask(taskId: taskId)
        }
    }
    
    private func handleCompleteTask(userInfo: [AnyHashable: Any]) {
        // Send complete action to Flutter
        sendEventToFlutter(event: "completeTask", data: userInfo)
    }
    
    private func handleSnoozeTask(userInfo: [AnyHashable: Any]) {
        // Reschedule notification for 15 minutes later
        guard let taskId = userInfo["taskId"] as? String,
              let title = userInfo["title"] as? String else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Gentle Reminder 💭"
        content.body = title
        content.sound = .default
        content.userInfo = userInfo
        content.categoryIdentifier = "GENTLE_NUDGE"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: "snooze-\(taskId)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func handleBreakdownTask(userInfo: [AnyHashable: Any]) {
        // Navigate to task breakdown screen
        if let taskId = userInfo["taskId"] as? String {
            sendEventToFlutter(event: "breakdownTask", data: ["taskId": taskId])
        }
    }
    
    private func navigateToTask(taskId: String) {
        sendEventToFlutter(event: "navigateToTask", data: ["taskId": taskId])
    }
    
    private func sendEventToFlutter(event: String, data: [AnyHashable: Any]) {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }
        
        let channel = FlutterMethodChannel(
            name: "com.tinysteps.app/notifications",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.invokeMethod(event, arguments: data)
    }
    
    // MARK: - URL Handling (Deep Links)
    
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        // Handle tinysteps:// URLs
        if url.scheme == "tinysteps" {
            handleDeepLink(url)
            return true
        }
        return super.application(app, open: url, options: options)
    }
    
    private func handleDeepLink(_ url: URL) {
        guard let controller = window?.rootViewController as? FlutterViewController else { return }
        
        let channel = FlutterMethodChannel(
            name: "com.tinysteps.app/deeplinks",
            binaryMessenger: controller.binaryMessenger
        )
        
        channel.invokeMethod("handleDeepLink", arguments: url.absoluteString)
    }
    
    // MARK: - Universal Links
    
    override func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            handleDeepLink(url)
            return true
        }
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}
