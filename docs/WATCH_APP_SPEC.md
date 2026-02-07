# Apple Watch Companion App Specification

## Overview

TinySteps Watch App is a watchOS companion for the ADHD Task Decomposer Flutter app. It provides glanceable task progress and quick step completion directly from the wrist.

**Target:** watchOS 9.0+  
**Framework:** SwiftUI + WatchConnectivity  
**Status:** Design Spec (Flutter doesn't support native watchOS)

---

## Screens

### 1. Current Step (Main Screen)

The primary interface - shows what to do RIGHT NOW.

```
┌─────────────────────┐
│      Step 3/8       │
│                     │
│   "Open the email   │
│    and read the     │
│    first line"      │
│                     │
│  ┌─────┐  ┌─────┐   │
│  │ ✓   │  │ →   │   │
│  │Done │  │Skip │   │
│  └─────┘  └─────┘   │
└─────────────────────┘
```

**Interactions:**
- **Tap step text** → Expand to full text (scrollable)
- **Done button** → Complete step, haptic success, advance
- **Skip button** → Skip step, light haptic, advance
- **Swipe left** → Timer view
- **Digital Crown** → Scroll if text is long

**Design Notes:**
- Step text: 18pt SF Pro, max 3 lines with "..." truncation
- Buttons: Minimum 44pt touch targets
- Progress: "Step X/Y" at top in 12pt subdued color

### 2. Timer View

For timed steps or pomodoro-style focus.

```
┌─────────────────────┐
│                     │
│      ╭─────╮        │
│     ╱       ╲       │
│    │  4:32   │      │
│     ╲       ╱       │
│      ╰─────╯        │
│                     │
│   "Write intro..."  │
│      ┌─────┐        │
│      │Pause│        │
│      └─────┘        │
└─────────────────────┘
```

**Interactions:**
- **Circular progress** → Fills as time passes
- **Pause/Resume** → Toggle timer
- **Haptic pulses** → Every 5 minutes (configurable)
- **Completion** → Strong haptic + optional sound
- **Swipe right** → Back to step view

**Timer Features:**
- Default durations: 5, 10, 15, 25 minutes
- Custom duration via phone app
- Background timer support
- Complications update during timer

### 3. Task Overview

Quick glance at the full task (accessible via force touch or scroll up).

```
┌─────────────────────┐
│   Clean Kitchen     │
│   ━━━━━━━━░░░ 62%   │
│                     │
│ ✓ Clear counters    │
│ ✓ Load dishwasher   │
│ ✓ Wipe surfaces     │
│ → Sweep floor       │
│ ○ Take out trash    │
│ ○ Replace towels    │
└─────────────────────┘
```

---

## Complications

### Circular (Graphic Circular)
```
    ╭───╮
   ╱ 3/8 ╲
  │   ●   │
   ╲     ╱
    ╰───╯
```
- Progress ring shows completion %
- Center: step count
- Tap → Opens app to current step

### Modular (Graphic Rectangular)
```
┌─────────────────┐
│ 🎯 Clean Kitchen│
│ ━━━━━━░░ Step 5 │
└─────────────────┘
```
- Task name (truncated)
- Progress bar + step number

### Corner (Graphic Corner)
```
┌────┐
│ 3/8│
│ ●● │
└────┘
```
- Minimal: just step count
- Small progress dots

### Inline (Modular Small)
```
[ 🎯 3/8 ]
```
- Icon + step fraction

---

## Watch-Phone Sync

### WatchConnectivity Implementation

```swift
// Data transferred phone → watch
struct TaskSync: Codable {
    let taskId: String
    let taskTitle: String
    let steps: [StepSync]
    let currentStepIndex: Int
    let timerDuration: Int? // seconds, nil if no timer
}

struct StepSync: Codable {
    let id: String
    let text: String
    let isCompleted: Bool
    let isSkipped: Bool
}

// Data transferred watch → phone
struct StepAction: Codable {
    let taskId: String
    let stepId: String
    let action: String // "complete", "skip", "undo"
    let timestamp: Date
}
```

### Sync Strategy

1. **App Launch Sync**
   - Phone sends full active task on watch app launch
   - Uses `transferUserInfo` for reliability

2. **Real-time Updates**
   - Step completions use `sendMessage` (if reachable)
   - Falls back to `transferUserInfo` if phone unreachable
   - Watch queues actions when offline

3. **Background Refresh**
   - Complications update via `transferCurrentComplicationUserInfo`
   - Phone pushes updates when task changes
   - Budget: ~50 updates/day

4. **Conflict Resolution**
   - Phone is source of truth
   - Watch actions include timestamps
   - Phone reconciles on next sync

---

## Haptic Feedback

| Action | Haptic Type |
|--------|-------------|
| Step completed | `.success` |
| Step skipped | `.click` |
| Timer pulse (5 min) | `.notification` |
| Timer complete | `.success` + `.success` |
| Error/No connection | `.failure` |
| Button tap | `.click` |

---

## Accessibility

- **VoiceOver:** Full support for all elements
- **Dynamic Type:** Text scales with system settings
- **Reduce Motion:** Disable progress animations
- **Bold Text:** Respected in all labels
- **High Contrast:** Alternative color scheme

---

## Color Scheme

```swift
// Light Mode
let primaryAction = Color.green      // Done button
let secondaryAction = Color.gray     // Skip button  
let progressRing = Color.blue
let stepText = Color.primary
let subtleText = Color.secondary

// Dark Mode (default on watch)
let primaryAction = Color.green
let secondaryAction = Color(white: 0.3)
let progressRing = Color.cyan
let stepText = Color.white
let subtleText = Color.gray
```

---

## Performance Considerations

- **Battery:** Minimize background updates
- **Memory:** Keep only active task in memory
- **Network:** Batch sync when possible
- **Animations:** Keep under 60fps, prefer system animations

---

## Future Enhancements

1. **Siri Shortcuts:** "Hey Siri, what's my next step?"
2. **Focus Filters:** Show/hide based on Focus mode
3. **Health Integration:** Log task completion as mindfulness minutes
4. **Widgets:** Lock screen widgets (iOS 16+)
5. **Ultra Support:** Larger display optimizations

---

## Implementation Notes

Since Flutter doesn't support watchOS natively, implementation requires:

1. **Native Swift Project:** Separate Xcode project for watch app
2. **Method Channels:** Flutter ↔ iOS communication
3. **Shared Data:** App Groups for shared UserDefaults
4. **Background Modes:** Enable for WatchConnectivity

See `watchapp/README.md` for setup instructions.
