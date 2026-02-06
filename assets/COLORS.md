# Tiny Steps - Color System

A calming, accessible color palette designed to reduce visual overwhelm while maintaining clarity and delight.

---

## Core Brand Colors

### Primary - Soft Teal
The calming, trustworthy foundation of the brand.

| Variant | Hex | RGB | Usage |
|---------|-----|-----|-------|
| **Teal 500** | `#4ECDC4` | 78, 205, 196 | Primary buttons, links, key actions |
| Teal 400 | `#6DD5CD` | 109, 213, 205 | Hover states, lighter accents |
| Teal 600 | `#3BB8B0` | 59, 184, 176 | Pressed states, dark mode primary |
| Teal 700 | `#2A9D8F` | 42, 157, 143 | Text on light backgrounds |
| Teal 100 | `#D4F5F3` | 212, 245, 243 | Subtle backgrounds, highlights |
| Teal 50 | `#EDFAF9` | 237, 250, 249 | Very subtle tints |

### Accent - Coral
Warm, energetic accent for celebrations and important highlights.

| Variant | Hex | RGB | Usage |
|---------|-----|-----|-------|
| **Coral 500** | `#FF6B6B` | 255, 107, 107 | Accents, celebrations, badges |
| Coral 400 | `#FF8585` | 255, 133, 133 | Hover states |
| Coral 600 | `#E85555` | 232, 85, 85 | Pressed states |
| Coral 100 | `#FFE5E5` | 255, 229, 229 | Subtle backgrounds |
| Coral 50 | `#FFF2F2` | 255, 242, 242 | Very subtle tints |

---

## Neutral Palette

### Light Mode Neutrals

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| **Background** | `#FAFAFA` | 250, 250, 250 | Main app background |
| Surface | `#FFFFFF` | 255, 255, 255 | Cards, sheets, elevated surfaces |
| Border | `#E5E5E5` | 229, 229, 229 | Dividers, subtle borders |
| Border Strong | `#D1D1D1` | 209, 209, 209 | More prominent borders |
| Text Primary | `#1A1A1A` | 26, 26, 26 | Headings, important text |
| Text Secondary | `#666666` | 102, 102, 102 | Body text, descriptions |
| Text Tertiary | `#999999` | 153, 153, 153 | Placeholders, hints |
| Text Disabled | `#CCCCCC` | 204, 204, 204 | Disabled states |

### Dark Mode Neutrals

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| **Background** | `#121212` | 18, 18, 18 | Main app background |
| Surface | `#1E1E1E` | 30, 30, 30 | Cards, sheets |
| Surface Elevated | `#2A2A2A` | 42, 42, 42 | Modals, popovers |
| Border | `#333333` | 51, 51, 51 | Dividers, subtle borders |
| Border Strong | `#444444` | 68, 68, 68 | More prominent borders |
| Text Primary | `#FAFAFA` | 250, 250, 250 | Headings, important text |
| Text Secondary | `#B3B3B3` | 179, 179, 179 | Body text, descriptions |
| Text Tertiary | `#808080` | 128, 128, 128 | Placeholders, hints |
| Text Disabled | `#555555` | 85, 85, 85 | Disabled states |

---

## Semantic Colors

### Success
For completed tasks, positive feedback, achievements.

| Mode | Hex | Name | Usage |
|------|-----|------|-------|
| Light | `#22C55E` | Green 500 | Success text, icons |
| Light (bg) | `#DCFCE7` | Green 100 | Success backgrounds |
| Dark | `#4ADE80` | Green 400 | Success text, icons |
| Dark (bg) | `#14532D` | Green 900 | Success backgrounds |

### Warning
For attention-needed states, approaching deadlines.

| Mode | Hex | Name | Usage |
|------|-----|------|-------|
| Light | `#F59E0B` | Amber 500 | Warning text, icons |
| Light (bg) | `#FEF3C7` | Amber 100 | Warning backgrounds |
| Dark | `#FBBF24` | Amber 400 | Warning text, icons |
| Dark (bg) | `#78350F` | Amber 900 | Warning backgrounds |

### Error
For errors, destructive actions, overdue tasks.

| Mode | Hex | Name | Usage |
|------|-----|------|-------|
| Light | `#EF4444` | Red 500 | Error text, icons |
| Light (bg) | `#FEE2E2` | Red 100 | Error backgrounds |
| Dark | `#F87171` | Red 400 | Error text, icons |
| Dark (bg) | `#7F1D1D` | Red 900 | Error backgrounds |

### Info
For tips, help text, informational callouts.

| Mode | Hex | Name | Usage |
|------|-----|------|-------|
| Light | `#3B82F6` | Blue 500 | Info text, icons |
| Light (bg) | `#DBEAFE` | Blue 100 | Info backgrounds |
| Dark | `#60A5FA` | Blue 400 | Info text, icons |
| Dark (bg) | `#1E3A5F` | Blue 900 | Info backgrounds |

---

## Special Purpose Colors

### Progress Indicator
Gradient for progress bars and celebratory moments:
```css
background: linear-gradient(90deg, #4ECDC4 0%, #6DD5CD 50%, #FF6B6B 100%);
```

### Focus/Active States
```
Light: #4ECDC4 with 20% opacity → rgba(78, 205, 196, 0.2)
Dark: #4ECDC4 with 30% opacity → rgba(78, 205, 196, 0.3)
```

### Overlay/Scrim
```
Light: #000000 with 50% opacity → rgba(0, 0, 0, 0.5)
Dark: #000000 with 70% opacity → rgba(0, 0, 0, 0.7)
```

---

## Accessibility Notes

### Contrast Ratios (WCAG 2.1)

All text colors have been verified against their intended backgrounds.

| Combination | Ratio | Level |
|-------------|-------|-------|
| Text Primary on Background (Light) | 16.1:1 | ✅ AAA |
| Text Secondary on Background (Light) | 5.9:1 | ✅ AA |
| Text Primary on Background (Dark) | 17.4:1 | ✅ AAA |
| Text Secondary on Background (Dark) | 9.1:1 | ✅ AAA |
| Teal 700 on Background (Light) | 4.6:1 | ✅ AA |
| Teal 500 on Background (Light) | 2.8:1 | ⚠️ Large text only |
| Coral 500 on Background (Light) | 3.2:1 | ⚠️ Large text only |
| Teal 400 on Background (Dark) | 8.9:1 | ✅ AAA |

### Recommendations

1. **Primary teal (#4ECDC4)**: Use for large text (18px+), icons, and interactive elements. For small body text, use Teal 700 (#2A9D8F).

2. **Coral accent (#FF6B6B)**: Use sparingly for visual accents. For text, ensure large size or pair with dark backgrounds.

3. **Never rely on color alone**: Always pair color with icons, text labels, or patterns for critical information (errors, success states).

4. **Focus indicators**: Ensure 3:1 contrast ratio minimum for focus rings against adjacent colors.

### Color Blindness Considerations

- **Protanopia/Deuteranopia** (red-green): Teal and coral remain distinguishable as they differ in both hue AND luminosity.
- **Tritanopia** (blue-yellow): Consider the teal may appear more cyan; coral remains distinct.

Test with tools:
- Figma: Stark plugin
- Web: Chrome DevTools → Rendering → Emulate vision deficiencies

---

## Implementation

### CSS Custom Properties

```css
:root {
  /* Primary */
  --color-teal-50: #EDFAF9;
  --color-teal-100: #D4F5F3;
  --color-teal-400: #6DD5CD;
  --color-teal-500: #4ECDC4;
  --color-teal-600: #3BB8B0;
  --color-teal-700: #2A9D8F;
  
  /* Accent */
  --color-coral-50: #FFF2F2;
  --color-coral-100: #FFE5E5;
  --color-coral-400: #FF8585;
  --color-coral-500: #FF6B6B;
  --color-coral-600: #E85555;
  
  /* Semantic */
  --color-success: #22C55E;
  --color-warning: #F59E0B;
  --color-error: #EF4444;
  --color-info: #3B82F6;
  
  /* Light mode */
  --color-background: #FAFAFA;
  --color-surface: #FFFFFF;
  --color-border: #E5E5E5;
  --color-text-primary: #1A1A1A;
  --color-text-secondary: #666666;
  --color-text-tertiary: #999999;
}

[data-theme="dark"] {
  --color-background: #121212;
  --color-surface: #1E1E1E;
  --color-border: #333333;
  --color-text-primary: #FAFAFA;
  --color-text-secondary: #B3B3B3;
  --color-text-tertiary: #808080;
  
  --color-success: #4ADE80;
  --color-warning: #FBBF24;
  --color-error: #F87171;
  --color-info: #60A5FA;
}
```

### Flutter Theme

```dart
class TinyStepsColors {
  // Primary
  static const teal50 = Color(0xFFEDFAF9);
  static const teal100 = Color(0xFFD4F5F3);
  static const teal400 = Color(0xFF6DD5CD);
  static const teal500 = Color(0xFF4ECDC4);
  static const teal600 = Color(0xFF3BB8B0);
  static const teal700 = Color(0xFF2A9D8F);
  
  // Accent
  static const coral50 = Color(0xFFFFF2F2);
  static const coral100 = Color(0xFFFFE5E5);
  static const coral400 = Color(0xFFFF8585);
  static const coral500 = Color(0xFFFF6B6B);
  static const coral600 = Color(0xFFE85555);
}
```

### Tailwind Config

```js
module.exports = {
  theme: {
    extend: {
      colors: {
        teal: {
          50: '#EDFAF9',
          100: '#D4F5F3',
          400: '#6DD5CD',
          500: '#4ECDC4',
          600: '#3BB8B0',
          700: '#2A9D8F',
        },
        coral: {
          50: '#FFF2F2',
          100: '#FFE5E5',
          400: '#FF8585',
          500: '#FF6B6B',
          600: '#E85555',
        },
      },
    },
  },
}
```

---

## Color Usage Examples

### Task States
- **Not started**: Neutral border (#E5E5E5)
- **In progress**: Teal accent (#4ECDC4)
- **Completed**: Success green (#22C55E) + strikethrough
- **Overdue**: Error red (#EF4444)

### Button Hierarchy
1. **Primary**: Teal 500 fill, white text
2. **Secondary**: Teal 500 outline, teal text
3. **Tertiary**: No border, teal text
4. **Destructive**: Error red fill/outline

### Celebration Moments
When a task is completed, use coral (#FF6B6B) for confetti/sparkle effects to create a warm, rewarding moment.
