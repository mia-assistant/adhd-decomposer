# iOS Home Screen Widgets Setup

This document describes how to implement home screen widgets for iOS using WidgetKit.

## Overview

iOS widgets require Xcode and native Swift/SwiftUI development. The `home_widget` Flutter package handles the communication between Flutter and the native widget, but the widget UI must be built in SwiftUI.

## Prerequisites

- Xcode 14.0 or later
- macOS development machine
- Apple Developer account (for device testing)
- iOS 14.0+ target

## Setup Steps

### 1. Create Widget Extension in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target → Widget Extension
3. Name it `TinyStepsWidget`
4. Enable "Include Configuration Intent" if you want configurable widgets
5. Set minimum deployment target to iOS 14.0

### 2. Configure App Groups

Both the main app and widget need to share data via App Groups:

1. In Xcode, select the Runner target → Signing & Capabilities
2. Add "App Groups" capability
3. Create group: `group.com.miadevelops.adhd_decomposer`
4. Repeat for the TinyStepsWidget target

### 3. Create Widget Views

Create these files in the widget extension:

#### `TinyStepsWidget.swift`

```swift
import WidgetKit
import SwiftUI

// MARK: - Current Task Widget Entry
struct CurrentTaskEntry: TimelineEntry {
    let date: Date
    let taskName: String
    let currentStep: String
    let stepIndex: Int
    let totalSteps: Int
    let hasActiveTask: Bool
}

// MARK: - Provider
struct CurrentTaskProvider: TimelineProvider {
    func placeholder(in context: Context) -> CurrentTaskEntry {
        CurrentTaskEntry(
            date: Date(),
            taskName: "Clean the kitchen",
            currentStep: "Gather cleaning supplies",
            stepIndex: 1,
            totalSteps: 5,
            hasActiveTask: true
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CurrentTaskEntry) -> Void) {
        let entry = readWidgetData()
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CurrentTaskEntry>) -> Void) {
        let entry = readWidgetData()
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
    
    private func readWidgetData() -> CurrentTaskEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.miadevelops.adhd_decomposer")
        
        return CurrentTaskEntry(
            date: Date(),
            taskName: userDefaults?.string(forKey: "task_name") ?? "No active task",
            currentStep: userDefaults?.string(forKey: "current_step") ?? "Tap to start a task",
            stepIndex: userDefaults?.integer(forKey: "current_step_index") ?? 0,
            totalSteps: userDefaults?.integer(forKey: "total_steps") ?? 0,
            hasActiveTask: userDefaults?.bool(forKey: "has_active_task") ?? false
        )
    }
}

// MARK: - Current Task Widget View
struct CurrentTaskWidgetView: View {
    var entry: CurrentTaskEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.taskName)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Text(entry.currentStep)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.21)) // #FF6B35
                .lineLimit(2)
            
            if entry.hasActiveTask && entry.totalSteps > 0 {
                Text("Step \(entry.stepIndex + 1) of \(entry.totalSteps)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .widgetURL(URL(string: "tinysteps://execute"))
    }
}

// MARK: - Quick Add Widget
struct QuickAddWidgetView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("✨")
                .font(.largeTitle)
            
            Text("Break down a task")
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Tap to start")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.42, blue: 0.21), Color(red: 1.0, green: 0.55, blue: 0.26)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .widgetURL(URL(string: "tinysteps://decompose"))
    }
}

// MARK: - Widget Definitions
@main
struct TinyStepsWidgets: WidgetBundle {
    var body: some Widget {
        CurrentTaskWidget()
        QuickAddWidget()
    }
}

struct CurrentTaskWidget: Widget {
    let kind: String = "CurrentTaskWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CurrentTaskProvider()) { entry in
            CurrentTaskWidgetView(entry: entry)
        }
        .configurationDisplayName("Current Task")
        .description("Shows your current task and step progress")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct QuickAddWidget: Widget {
    let kind: String = "QuickAddWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickAddProvider()) { _ in
            QuickAddWidgetView()
        }
        .configurationDisplayName("Quick Add")
        .description("Quickly break down a new task")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct QuickAddProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry { SimpleEntry(date: Date()) }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) { completion(SimpleEntry(date: Date())) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        completion(Timeline(entries: [SimpleEntry(date: Date())], policy: .never))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}
```

### 4. Update Info.plist

Add the deep link scheme to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>tinysteps</string>
        </array>
    </dict>
</array>
```

### 5. Configure home_widget for iOS

Update `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import home_widget

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Register widget background task
        if #available(iOS 17.0, *) {
            // Widget activities for iOS 17+
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

### 6. Trigger Widget Updates

The Flutter code already calls `HomeWidget.updateWidget()` when task data changes. For iOS, you also need to:

1. Import WidgetKit in your widget extension
2. Call `WidgetCenter.shared.reloadAllTimelines()` when data changes

This is handled automatically by the `home_widget` package when using `HomeWidget.updateWidget()`.

## Testing

1. Build and run the app on a device or simulator (iOS 14+)
2. Long-press on the home screen to enter edit mode
3. Tap the "+" button to add a widget
4. Search for "Tiny Steps"
5. Select either "Current Task" or "Quick Add" widget
6. Place it on your home screen

## Troubleshooting

### Widget not appearing in widget gallery
- Ensure minimum deployment target is iOS 14.0
- Clean build folder (Cmd+Shift+K) and rebuild
- Check that the widget extension is properly signed

### Data not syncing
- Verify App Groups are configured identically on both targets
- Check that the group identifier matches in code and entitlements
- Ensure you're using the same UserDefaults suite name

### Deep links not working
- Verify URL scheme is registered in Info.plist
- Test with Safari by typing `tinysteps://execute`

## References

- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [home_widget package](https://pub.dev/packages/home_widget)
- [Creating a Widget Extension](https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension)
