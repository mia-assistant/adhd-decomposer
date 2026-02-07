# Tiny Steps - Screenshot Generation

## Prerequisites

1. Install fastlane:
```bash
brew install fastlane
```

2. For iOS, install snapshot helper:
```bash
cd ios
fastlane snapshot init
```

## iOS Screenshots

### Setup (one-time)
1. Open `ios/Runner.xcworkspace` in Xcode
2. Add a new UI Testing target: File → New → Target → UI Testing Bundle
3. Name it `RunnerUITests`
4. Copy `ScreenshotTests.swift` to the test target
5. Update `Appfile` with your Apple ID and Team ID

### Capture
```bash
cd /path/to/adhd-decomposer
fastlane ios screenshots
```

Screenshots saved to: `fastlane/screenshots/ios/`

## Android Screenshots

### Option 1: Manual (Recommended for Flutter)
Since Flutter doesn't play well with fastlane's Android screenshot tools, 
use the integration test approach:

```bash
# Run the app in screenshot mode
flutter drive --target=test_driver/screenshots.dart
```

### Option 2: Use Flutter's integration_test
1. Screenshots captured in `test_driver/screenshots/`
2. Manually organize into Play Store folders

## Required Screenshots

### App Store (iOS)
- 6.7" (iPhone 16 Pro Max): 1290 x 2796
- 6.1" (iPhone 16): 1179 x 2556  
- 12.9" iPad: 2048 x 2732

### Play Store (Android)
- Phone: 1080 x 1920 or 1440 x 2560
- 7" Tablet: 1200 x 1920
- 10" Tablet: 1920 x 1200

## Recommended Screens to Capture

1. **Welcome** - First onboarding screen with app value prop
2. **Home** - Main screen with tasks (ideally with 1-2 tasks visible)
3. **New Task** - The decompose screen with a typed task
4. **Breakdown** - After AI breaks down a task (the magic moment!)
5. **Execute** - Doing a task with progress visible
6. **Celebration** - Task completion with confetti (if possible)
7. **Templates** - Pre-made task templates
8. **Stats** - Achievement/progress screen

## Tips

- Use demo/mock data for consistent screenshots
- Add `--screenshot-mode` launch argument to:
  - Skip onboarding
  - Pre-populate sample data
  - Disable animations for cleaner captures
