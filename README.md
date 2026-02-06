# Tiny Steps 👣

An ADHD-friendly task decomposition app that breaks overwhelming tasks into tiny, doable steps.

**"Finally. A to-do list that gets ADHD."**

## Why Tiny Steps?

For people with ADHD, starting tasks can feel impossible. "Clean the house" might as well be "climb Mount Everest." 

Tiny Steps uses AI to break down any task into small, concrete actions that feel achievable:

**Before:** "Clean the kitchen" 😰

**After:**
1. Walk to the kitchen (1 min)
2. Put away dishes on the counter (3 min)
3. Wipe down the stove (2 min)
4. Take out the trash (2 min)
...

Each step shown one at a time. Confetti when you complete one. No guilt if you skip.

## Features

### Core
- 🎯 **AI-Powered Decomposition** - Enter any task, get tiny steps instantly
- 📚 **19 Pre-made Templates** - Common tasks ready to go (laundry, emails, morning routine)
- ⏱️ **Focus Timer** - Pomodoro-style sessions (5, 10, 15, 25 min)
- 🎉 **Dopamine Rewards** - Confetti, sounds, and celebration messages
- 😵 **"I'm Stuck" Button** - Break it down even smaller when paralyzed

### Smart Features
- 🧠 **3 AI Styles** - Standard, Quick (time pressure), Gentle (bad brain days)
- 🕐 **Time-Aware** - Morning prompts differ from late-night
- 🔔 **Gentle Reminders** - Non-judgmental nudges for unfinished tasks
- 📊 **Stats & Streaks** - Track your progress and build momentum

### Engagement
- 🏆 **Achievements** - Unlock badges for milestones
- 📤 **Share Cards** - Instagram-friendly completion graphics
- 🔥 **Streaks** - Visual streak counter with encouragement

### Platform Features
- 📱 **Android Widgets** - Current task and quick-add on home screen
- 🔗 **Deep Links** - Jump directly from notifications
- ♿ **Accessible** - Screen reader support, large touch targets, respects system settings

### Freemium Model
- 3 free AI decompositions per day
- Unlimited templates always free
- Premium: $4.99/mo or $29.99/year for unlimited AI

## Screenshots

*Coming soon*

## Getting Started

### Prerequisites

- Flutter 3.19+
- Dart 3.5+
- Android SDK 34+

### Installation

```bash
git clone https://github.com/mia-assistant/adhd-decomposer.git
cd adhd-decomposer
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --debug
# Debug APK at: build/app/outputs/flutter-apk/app-debug.apk
```

## Project Structure

```
lib/
├── core/
│   ├── constants/strings.dart      # Encouragements, UI text
│   └── theme/app_theme.dart        # Colors, typography
├── data/
│   ├── models/task.dart            # Task, TaskStep
│   ├── services/
│   │   ├── ai_service.dart         # OpenAI integration
│   │   ├── settings_service.dart   # Hive persistence
│   │   ├── stats_service.dart      # Usage tracking
│   │   ├── achievements_service.dart
│   │   ├── notification_service.dart
│   │   ├── share_service.dart
│   │   ├── sound_service.dart
│   │   └── analytics_service.dart
│   └── task_templates.dart         # Pre-made decompositions
├── presentation/
│   ├── providers/task_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── decompose_screen.dart
│   │   ├── execute_screen.dart
│   │   ├── templates_screen.dart
│   │   ├── stats_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── feedback_screen.dart
│   │   ├── paywall_screen.dart
│   │   └── onboarding/
│   └── widgets/
│       ├── share_card.dart
│       └── rate_app_dialog.dart
└── main.dart
```

## Tech Stack

- **Flutter** - Cross-platform UI
- **Provider** - State management  
- **Hive** - Local encrypted storage
- **OpenAI API** - Task decomposition (optional - works with mock data)
- **Confetti** - Celebration animations
- **Flutter Animate** - Smooth UI transitions
- **Flutter Local Notifications** - Reminders
- **Home Widget** - Android widgets
- **In App Review** - Native review prompts

## Design Principles

1. **One thing at a time** - Never overwhelm
2. **Celebrate everything** - Dopamine is the feature
3. **No guilt** - Skip button always available
4. **Calm UI** - Soft colors, rounded corners, breathing room
5. **Fast to value** - Task → steps in <3 seconds

## Stats

- 8,500+ lines of Dart code
- 25+ commits
- 30+ Dart files

## Roadmap

See [ROADMAP.md](ROADMAP.md) for full details.

**v1.2 (In Progress)**
- [ ] Body doubling mode with ambient sounds
- [ ] Calendar time blocking
- [ ] Recurring routines

**v1.3+**
- [ ] Apple Watch companion
- [ ] Siri shortcuts
- [ ] Cloud sync (optional)

## Legal

- [Privacy Policy](docs/PRIVACY_POLICY.md)
- [Terms of Service](docs/TERMS_OF_SERVICE.md)

## License

MIT

---

## Made with ❤️ for ADHD minds

*One tiny step at a time.*

**GitHub:** https://github.com/mia-assistant/adhd-decomposer
