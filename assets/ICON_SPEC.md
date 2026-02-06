# Tiny Steps - App Icon Design Specification

## Concept

The app icon should visually represent the core value proposition: **breaking overwhelming tasks into manageable tiny steps**. The design must feel calming, approachable, and empowering—never overwhelming or childish.

### Design Philosophy
- **Simple**: Instantly recognizable at small sizes
- **Calming**: Soft colors, rounded shapes, breathing room
- **Progressive**: Visual sense of forward movement or achievement
- **Friendly**: Approachable without being cartoon-ish

---

## Color Palette

| Role | Color | Hex |
|------|-------|-----|
| Primary | Soft Teal | `#4ECDC4` |
| Accent | Coral | `#FF6B6B` |
| Background | Off-White | `#FAFAFA` |
| Dark Variant | Deep Teal | `#2A9D8F` |

### Gradient Option
- Linear gradient from `#4ECDC4` (top-left) to `#3BB8B0` (bottom-right) for depth

---

## Design Concepts

### Concept A: Stepping Stones ⭐ (Recommended)
Three rounded squares/circles arranged diagonally (bottom-left to top-right), increasing slightly in size or brightness. The top one has a subtle sparkle or checkmark.

**Why it works:**
- Clear visual metaphor for progress
- Scales well at all sizes
- Unique in the productivity app space

### Concept B: Stacked Blocks
Three soft, rounded blocks stacked in a playful, slightly offset arrangement. Each block a shade lighter, suggesting building/progress.

**Why it works:**
- Represents "building" your task list
- 3D-ish depth adds visual interest
- Familiar "building blocks" metaphor

### Concept C: Checkbox with Sparkle
A single rounded checkbox with a check inside, plus a small sparkle/star accent in coral.

**Why it works:**
- Universal "task complete" symbol
- The sparkle adds delight/reward feeling
- Extremely simple and recognizable

### Concept D: Puzzle Piece
A single rounded puzzle piece in teal with a coral accent notch.

**Why it works:**
- "Piece by piece" metaphor
- Unique silhouette
- May feel too abstract

---

## Style Guidelines

### Shape Language
- **Corner radius**: 22-24% of icon size (matching iOS app icon spec)
- **Internal elements**: Rounded corners, no sharp edges
- **Stroke weight**: If using outlines, 8-10% of icon width
- **Padding**: 10-15% margin from icon edge

### Typography
- No text in the icon (doesn't scale well)
- If app name variant needed, use a clean geometric sans-serif (e.g., Inter, SF Pro)

### Depth & Shadow
- Subtle inner shadow for depth (optional)
- Avoid heavy drop shadows
- Flat or soft gradient preferred over skeuomorphic

---

## Size Specifications

### iOS (App Store & Device)

| Purpose | Size (px) | Scale |
|---------|-----------|-------|
| iPhone Notification | 20×20 | @2x, @3x |
| iPhone Settings | 29×29 | @2x, @3x |
| iPhone Spotlight | 40×40 | @2x, @3x |
| iPhone App | 60×60 | @2x, @3x |
| iPad Notifications | 20×20 | @1x, @2x |
| iPad Settings | 29×29 | @1x, @2x |
| iPad Spotlight | 40×40 | @1x, @2x |
| iPad App | 76×76 | @1x, @2x |
| iPad Pro App | 83.5×83.5 | @2x |
| App Store | 1024×1024 | @1x |

**iOS Notes:**
- All icons must be square with no transparency
- iOS automatically applies corner mask
- Provide as PNG, no alpha channel
- Do not include rounded corners in asset

### Android (Adaptive Icons)

| Purpose | Size (px) | Notes |
|---------|-----------|-------|
| mdpi | 48×48 | Baseline |
| hdpi | 72×72 | 1.5× |
| xhdpi | 96×96 | 2× |
| xxhdpi | 144×144 | 3× |
| xxxhdpi | 192×192 | 4× |
| Play Store | 512×512 | High-res |

**Android Adaptive Icon Layers:**
- **Foreground**: 108×108dp (with 72×72dp safe zone centered)
- **Background**: Solid color `#4ECDC4` or subtle gradient
- Both layers provided as 432×432px at xxxhdpi

**Safe Zone:** Keep all important elements within the center 66% (72dp of 108dp) to survive all mask shapes (circle, squircle, rounded square, etc.)

---

## File Deliverables

```
assets/
├── icon/
│   ├── ios/
│   │   ├── AppIcon.appiconset/
│   │   │   ├── icon-20@2x.png
│   │   │   ├── icon-20@3x.png
│   │   │   ├── icon-29@2x.png
│   │   │   ├── icon-29@3x.png
│   │   │   ├── icon-40@2x.png
│   │   │   ├── icon-40@3x.png
│   │   │   ├── icon-60@2x.png
│   │   │   ├── icon-60@3x.png
│   │   │   ├── icon-76.png
│   │   │   ├── icon-76@2x.png
│   │   │   ├── icon-83.5@2x.png
│   │   │   ├── icon-1024.png
│   │   │   └── Contents.json
│   │   └── icon-marketing-1024.png
│   ├── android/
│   │   ├── mipmap-mdpi/
│   │   │   └── ic_launcher.png
│   │   ├── mipmap-hdpi/
│   │   │   └── ic_launcher.png
│   │   ├── mipmap-xhdpi/
│   │   │   └── ic_launcher.png
│   │   ├── mipmap-xxhdpi/
│   │   │   └── ic_launcher.png
│   │   ├── mipmap-xxxhdpi/
│   │   │   └── ic_launcher.png
│   │   ├── ic_launcher_foreground.xml
│   │   ├── ic_launcher_background.xml
│   │   └── playstore-icon-512.png
│   └── source/
│       ├── icon-master.fig (or .sketch / .ai)
│       └── icon-master.svg
```

---

## Design Review Checklist

- [ ] Recognizable at 29×29px (smallest iOS size)
- [ ] Works on light AND dark backgrounds
- [ ] No fine details that disappear at small sizes
- [ ] Distinct silhouette from competitors
- [ ] Conveys "calm productivity" at a glance
- [ ] Passes squint test (recognizable when blurred)
- [ ] Android safe zone respected (all key elements in center 66%)

---

## Competitor Reference

Icons to differentiate from:
- **Todoist**: Red checkmark (avoid similar checkmark style)
- **Things 3**: Blue gradient with white checkbox
- **TickTick**: Blue/purple checkmark
- **Any.do**: Teal circle (avoid similar teal circle)

Our differentiation: **Stepping/building metaphor** rather than checkbox-centric.

---

## Next Steps

1. Create 3 rough concepts based on Concepts A-C
2. Test at multiple sizes (especially 60×60, 29×29)
3. User feedback round
4. Refine winner
5. Export all sizes
6. Test on actual device home screens
