# Tiny Steps 🚀

An ADHD-friendly task decomposition app that breaks overwhelming tasks into tiny, doable steps.

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

## Features

- 🎯 **AI-Powered Decomposition** - Enter any task and get it broken into tiny steps
- ⏱️ **Optional Timer** - Choose 5, 10, 15, or 25 minute focus sessions
- 🎉 **Dopamine Rewards** - Confetti, sounds, and celebration messages
- 🔄 **Progress Tracking** - See your completion rate and momentum
- 😵 **"I'm Stuck" Button** - Get even smaller steps when you're paralyzed
- 💾 **Local Storage** - Your tasks persist between sessions

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
# or for release
flutter build apk --release
```

## Architecture

```
lib/
├── core/
│   ├── constants/strings.dart
│   └── theme/app_theme.dart
├── data/
│   ├── models/task.dart
│   └── services/ai_service.dart
├── presentation/
│   ├── providers/task_provider.dart
│   └── screens/
│       ├── home_screen.dart
│       ├── decompose_screen.dart
│       ├── execute_screen.dart
│       └── settings_screen.dart
└── main.dart
```

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **Hive** - Local storage
- **Confetti** - Celebration animations
- **Flutter Animate** - UI animations

## Roadmap

- [ ] Real AI integration (OpenAI/Gemini)
- [ ] Recurring tasks
- [ ] Statistics and streaks
- [ ] Widget for quick task entry
- [ ] iOS release

## License

MIT

## Made with ❤️ for ADHD minds

*One tiny step at a time.*
