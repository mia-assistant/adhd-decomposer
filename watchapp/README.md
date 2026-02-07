# TinySteps Watch App

watchOS companion app for the ADHD Task Decomposer.

## Status

⚠️ **Design Phase** - This directory contains SwiftUI stubs and design specs. Full implementation requires a native Xcode project.

## Structure

```
watchapp/
├── TinySteps Watch App/        # Main watch app
│   ├── ContentView.swift       # Tab navigation
│   ├── StepView.swift          # Current step display
│   ├── TimerView.swift         # Focus timer
│   ├── Assets.xcassets/        # App icons, colors
│   └── Info.plist              # App configuration
├── TinySteps Watch App Extension/
│   └── ComplicationController.swift
└── README.md
```

## Requirements

- Xcode 15+
- watchOS 9.0+ deployment target
- iOS 16.0+ for companion app
- Swift 5.9+

## Setup Instructions

### 1. Create Xcode Project

1. Open Xcode → New Project
2. Select watchOS → App
3. Product Name: "TinySteps Watch App"
4. Interface: SwiftUI
5. Check "Include Complication"

### 2. Configure App Groups

Both iOS and watchOS apps need shared App Group:

1. Select iOS target → Signing & Capabilities
2. Add "App Groups"
3. Create: `group.com.yourcompany.tinysteps`
4. Repeat for watchOS target

### 3. Add WatchConnectivity

In iOS app (AppDelegate or Flutter plugin):

```swift
import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    static let shared = WatchSessionManager()
    
    func startSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func sendTaskToWatch(_ task: TaskSync) {
        guard WCSession.default.isPaired else { return }
        
        do {
            let data = try JSONEncoder().encode(task)
            WCSession.default.transferUserInfo(["task": data])
        } catch {
            print("Failed to encode task: \(error)")
        }
    }
}
```

### 4. Flutter Integration

Create a method channel in your Flutter app:

```dart
// In lib/data/services/watch_service.dart
static const platform = MethodChannel('com.yourcompany.tinysteps/watch');

Future<void> syncTaskToWatch(Task task) async {
  await platform.invokeMethod('syncTask', task.toJson());
}
```

iOS side (in Runner):

```swift
// AppDelegate.swift
let watchChannel = FlutterMethodChannel(
    name: "com.yourcompany.tinysteps/watch",
    binaryMessenger: controller.binaryMessenger
)

watchChannel.setMethodCallHandler { call, result in
    if call.method == "syncTask" {
        if let args = call.arguments as? [String: Any] {
            WatchSessionManager.shared.sendTaskToWatch(args)
            result(nil)
        }
    }
}
```

## Testing

### Simulator

1. Run iOS app on iPhone simulator
2. Run watch app on paired Watch simulator
3. Use Xcode's "Trigger Background Fetch" for testing

### Device

1. Install iOS app via Xcode
2. Watch app auto-installs if paired
3. Check Watch app → My Watch → TinySteps

## Complications

Available complication families:

- `graphicCircular` - Progress ring with step count
- `graphicRectangular` - Task name + progress bar
- `graphicCorner` - Step count only

## Resources

- [WatchConnectivity Guide](https://developer.apple.com/documentation/watchconnectivity)
- [Creating Complications](https://developer.apple.com/documentation/clockkit)
- [Human Interface Guidelines - watchOS](https://developer.apple.com/design/human-interface-guidelines/watchos)
