# iOS Widget Setup

The iOS widget code is ready in `ios/TinyStepsWidget/`. You need to add it to the Xcode project:

## Steps in Xcode

1. **Open `ios/Runner.xcworkspace` in Xcode**

2. **Add Widget Extension:**
   - File → New → Target
   - Choose "Widget Extension"
   - Product Name: `TinyStepsWidget`
   - Team: Your signing team
   - Uncheck "Include Configuration Intent"
   - Click Finish

3. **Replace Generated Code:**
   - Delete the generated `TinyStepsWidget.swift` content
   - Copy content from `ios/TinyStepsWidget/TinyStepsWidget.swift`
   - Or just delete the generated folder and use our prepared one

4. **Add App Group:**
   - Select Runner target → Signing & Capabilities
   - Click "+ Capability" → "App Groups"
   - Add group: `group.com.manuelpa.tinysteps`
   - Do the same for TinyStepsWidget target

5. **Update Bundle Identifier:**
   - Widget bundle ID should be: `com.manuelpa.tinysteps.TinyStepsWidget`

6. **Set Deployment Target:**
   - Widget minimum iOS version: 14.0 (for WidgetKit)

## Verify

Build and run on device. Long-press home screen → add widget → search "Tiny Steps"

## Files Reference

- `TinyStepsWidget.swift` - Main widget code with SwiftUI views
- `Assets.xcassets/` - Asset catalog for widget
