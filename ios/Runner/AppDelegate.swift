import Flutter
import UIKit
import UserNotifications
import AppIntents

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

// MARK: - Siri Shortcuts / App Intents

/// Error type for App Intent failures
enum AppIntentError: Error {
    case executionFailed(String)
}

// MARK: - FlutterAppIntentsPlugin (local stub)
/// Bridges App Intents to Flutter via method channels
class FlutterAppIntentsPlugin {
    static let shared = FlutterAppIntentsPlugin()
    
    func handleIntentInvocation(identifier: String, parameters: [String: Any]) async -> [String: Any] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                guard let appDelegate = UIApplication.shared.delegate as? FlutterAppDelegate,
                      let controller = appDelegate.window?.rootViewController as? FlutterViewController else {
                    continuation.resume(returning: ["success": false, "error": "Flutter not available"])
                    return
                }
                
                let channel = FlutterMethodChannel(
                    name: "com.tinysteps.app/intents",
                    binaryMessenger: controller.binaryMessenger
                )
                
                let args: [String: Any] = [
                    "identifier": identifier,
                    "parameters": parameters
                ]
                
                channel.invokeMethod("handleIntent", arguments: args) { result in
                    if let dict = result as? [String: Any] {
                        continuation.resume(returning: dict)
                    } else {
                        continuation.resume(returning: ["success": true, "value": "Intent handled"])
                    }
                }
            }
        }
    }
}

// MARK: - Start New Task Intent
/// Opens the decompose screen to break down a new task
@available(iOS 16.0, *)
struct StartNewTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Start a New Task"
    static var description = IntentDescription("Open Tiny Steps to break down a new task into manageable steps")
    static var isDiscoverable = true
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "start_new_task",
            parameters: [:]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Opening task breakdown"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to start new task"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

// MARK: - Continue Task Intent
/// Resumes working on the current active task
@available(iOS 16.0, *)
struct ContinueTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Continue My Task"
    static var description = IntentDescription("Resume working on your current task in Tiny Steps")
    static var isDiscoverable = true
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "continue_task",
            parameters: [:]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Continuing your task"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to continue task"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

// MARK: - Show Progress Intent
/// Opens the stats screen to view progress
@available(iOS 16.0, *)
struct ShowProgressIntent: AppIntent {
    static var title: LocalizedStringResource = "Show My Progress"
    static var description = IntentDescription("View your task completion statistics in Tiny Steps")
    static var isDiscoverable = true
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "show_progress",
            parameters: [:]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Opening your progress"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to show progress"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

// MARK: - Start Routine Intent
/// Starts a specific routine by name
@available(iOS 16.0, *)
struct StartRoutineIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Routine"
    static var description = IntentDescription("Start a routine in Tiny Steps")
    static var isDiscoverable = true
    static var openAppWhenRun = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> & OpensIntent {
        let plugin = FlutterAppIntentsPlugin.shared
        let result = await plugin.handleIntentInvocation(
            identifier: "start_routine",
            parameters: [:]
        )
        
        if let success = result["success"] as? Bool, success {
            let value = result["value"] as? String ?? "Starting routine"
            return .result(value: value)
        } else {
            let errorMessage = result["error"] as? String ?? "Failed to start routine"
            throw AppIntentError.executionFailed(errorMessage)
        }
    }
}

// MARK: - App Shortcuts Provider
/// Provides Siri voice command phrases for the app
@available(iOS 16.0, *)
struct TinyStepsShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            // Start new task shortcut
            AppShortcut(
                intent: StartNewTaskIntent(),
                phrases: [
                    "Break down a task with \(.applicationName)",
                    "Start a new task in \(.applicationName)",
                    "Decompose a task using \(.applicationName)",
                    "Break down my task with \(.applicationName)"
                ],
                shortTitle: "New Task",
                systemImageName: "square.split.2x1"
            ),
            
            // Continue task shortcut
            AppShortcut(
                intent: ContinueTaskIntent(),
                phrases: [
                    "Continue my task in \(.applicationName)",
                    "Resume my task with \(.applicationName)",
                    "Keep working in \(.applicationName)",
                    "Continue with \(.applicationName)"
                ],
                shortTitle: "Continue",
                systemImageName: "play.fill"
            ),
            
            // Show progress shortcut
            AppShortcut(
                intent: ShowProgressIntent(),
                phrases: [
                    "Show my progress in \(.applicationName)",
                    "Check my progress with \(.applicationName)",
                    "View my stats in \(.applicationName)",
                    "How am I doing in \(.applicationName)"
                ],
                shortTitle: "Progress",
                systemImageName: "chart.bar.fill"
            ),
            
            // Start routine shortcut
            AppShortcut(
                intent: StartRoutineIntent(),
                phrases: [
                    "Start my routine in \(.applicationName)",
                    "Start morning routine with \(.applicationName)",
                    "Begin my routine using \(.applicationName)"
                ],
                shortTitle: "Routine",
                systemImageName: "repeat"
            )
        ]
    }
}
