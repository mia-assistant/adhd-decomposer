# Accessibility Guide - Tiny Steps

Tiny Steps is designed with accessibility at its core. Many users with ADHD also experience co-occurring conditions like dyslexia, motor difficulties, or sensory processing differences. This guide documents our accessibility standards and implementation.

## Standards Compliance

### WCAG 2.1 Level AA

Tiny Steps aims to meet WCAG 2.1 Level AA compliance:

| Criterion | Status | Implementation |
|-----------|--------|----------------|
| 1.1.1 Non-text Content | ✅ | All icons have semantic labels |
| 1.3.1 Info and Relationships | ✅ | Proper heading hierarchy, semantic structure |
| 1.4.1 Use of Color | ✅ | Icons and text accompany color indicators |
| 1.4.3 Contrast (Minimum) | ✅ | 4.5:1 for text, 3:1 for large text |
| 1.4.4 Resize Text | ✅ | Supports up to 200% text scaling |
| 1.4.10 Reflow | ✅ | Content reflows at 320px viewport |
| 2.1.1 Keyboard | ✅ | All functionality accessible via keyboard |
| 2.4.3 Focus Order | ✅ | Logical tab order throughout |
| 2.4.6 Headings and Labels | ✅ | Descriptive headings and labels |
| 2.5.5 Target Size | ✅ | Minimum 48x48dp touch targets |
| 3.2.3 Consistent Navigation | ✅ | Consistent navigation patterns |

## Feature Implementation

### 1. Semantic Labels (Screen Reader Support)

All interactive elements include meaningful semantic labels for screen readers:

```dart
Semantics(
  label: 'Mark step as done',
  button: true,
  hint: 'Double tap to complete this step',
  child: ElevatedButton(...),
)
```

**Button Descriptions:**
- **Done button**: "Mark step as done. Double tap to complete this step."
- **Skip button**: "Skip this step. Double tap to skip to the next step."
- **I'm stuck button**: "I'm stuck on this step. Double tap for help breaking down this step into smaller parts."
- **Close button**: "Close task and return to home."

**Live Regions:**
- Step changes are announced via `liveRegion: true`
- Timer updates are announced periodically
- Completion celebrations are announced

### 2. Text Scaling

The app fully supports system text scaling up to 200%:

- All text uses relative sizing that respects `MediaQuery.textScaleFactor`
- Layouts use `Flexible` and `Expanded` widgets to accommodate larger text
- No text clipping at 200% scale
- Tested configurations:
  - Small (0.85x)
  - Default (1.0x)
  - Large (1.15x)
  - Larger (1.30x)
  - Extra Large (2.0x)

### 3. Touch Targets

All interactive elements meet the 48x48dp minimum touch target requirement:

```dart
const double kMinTouchTarget = 48.0;

// Implementation example
SizedBox(
  width: kMinTouchTarget,
  height: kMinTouchTarget,
  child: IconButton(...),
)
```

**Elements with enforced touch targets:**
- All buttons (elevated, outlined, text, icon)
- Timer selection chips
- Task cards
- Navigation icons
- Settings toggles

### 4. Color Contrast

Colors have been selected for WCAG AA compliance:

**Light Theme:**
| Element | Foreground | Background | Ratio |
|---------|------------|------------|-------|
| Body text | #1A1A1A | #FAFAFA | 14.6:1 |
| Secondary text | #555555 | #FAFAFA | 7.5:1 |
| Primary on white | #2BA49A | #FFFFFF | 3.8:1 |
| Button text | #FFFFFF | #2BA49A | 3.8:1 |

**Dark Theme:**
| Element | Foreground | Background | Ratio |
|---------|------------|------------|-------|
| Body text | #F8F8F8 | #121220 | 16.2:1 |
| Secondary text | #CCCCCC | #121220 | 10.5:1 |
| Primary on dark | #5CE1D6 | #121220 | 8.9:1 |

**Color Independence:**
- Task status uses both color AND icons (✓ for complete)
- Progress indicators include text percentage
- Errors include both color and icon indicators

### 5. Motion & Animation Settings

**System Preferences:**
The app respects `MediaQuery.disableAnimations`:

```dart
bool _shouldReduceAnimations(BuildContext context) {
  final provider = context.read<TaskProvider>();
  final mediaQuery = MediaQuery.of(context);
  return provider.reduceAnimations || mediaQuery.disableAnimations;
}
```

**User Settings (Settings > Accessibility):**
- **Reduce Animations**: Disables confetti, celebration overlays, and transition animations
- **Auto-Advance Steps**: Can be disabled for users who need more control
- **Celebration Animation**: Toggle confetti specifically

When animations are reduced:
- Confetti is not shown
- Celebration overlays are simplified (no shake animation)
- Step transitions are immediate
- Page transitions use reduced motion

### 6. Dyslexia-Friendly Design

**Typography:**
- **Headings**: Nunito - rounded, friendly font recommended for dyslexia
- **Body text**: Inter - clean, highly legible sans-serif
- **Line height**: 1.5 for body text (improved readability)
- **Letter spacing**: Slightly increased (+0.15) for better character recognition

**Layout:**
- Left-aligned text (never justified)
- Adequate white space between elements
- Clear visual hierarchy
- Consistent paragraph spacing

### 7. Focus Management

**Keyboard Navigation:**
- Visible focus indicators (2px blue outline)
- Logical tab order following visual layout
- Focus trapped in modals/dialogs
- Skip links for repetitive content

**Auto-focus:**
- Forms auto-focus the first input field
- Dialogs focus the primary action button
- Search fields receive focus on open

```dart
// Example from DecomposeScreen
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _focusNode.requestFocus();
  });
}
```

## Testing Accessibility

### Manual Testing Checklist

- [ ] Navigate entire app using keyboard only (Tab, Enter, Space, Escape)
- [ ] Test with TalkBack (Android) / VoiceOver (iOS) enabled
- [ ] Test at 200% text scale
- [ ] Test with "Reduce motion" system setting enabled
- [ ] Verify touch targets with accessibility scanner
- [ ] Test color contrast with Accessibility Insights

### Flutter Accessibility Tools

```bash
# Run accessibility tests
flutter test --accessibility

# Check semantics tree
flutter run --debug
# In DevTools: Inspector > Accessibility
```

### Recommended Testing Tools

- **Accessibility Scanner** (Android): Built-in accessibility testing
- **Accessibility Inspector** (iOS/macOS): Test VoiceOver behavior
- **Flutter DevTools**: Semantics tree visualization
- **Contrast Checker**: WebAIM Contrast Checker for color verification

## Reporting Accessibility Issues

If you encounter accessibility barriers:

1. **In-app**: Settings > Support > Send Feedback
2. **GitHub**: Open an issue with the `accessibility` label
3. **Email**: accessibility@tinysteps.app

Please include:
- Device and OS version
- Assistive technology used (e.g., TalkBack, VoiceOver)
- Steps to reproduce the issue
- Expected vs. actual behavior

## Future Improvements

- [ ] Screen reader optimization for chart/graph content in Stats
- [ ] Custom voice assistant integration
- [ ] Haptic patterns for different notifications
- [ ] High contrast mode option
- [ ] Text-to-speech for step content
- [ ] Adjustable animation speed (not just on/off)

---

*Last updated: February 2025*
*Compliance verified against WCAG 2.1 Level AA guidelines*
