# App Store Screenshot Sizes

This document specifies the required screenshot dimensions for App Store submissions.

## iOS App Store Requirements

### iPhone Screenshots (Required)

| Display Size | Pixel Dimensions | Device Examples |
|-------------|------------------|-----------------|
| **6.7"** | 1290 × 2796 | iPhone 14 Pro Max, iPhone 15 Pro Max, iPhone 15 Plus |
| **6.5"** | 1242 × 2688 | iPhone 11 Pro Max, iPhone XS Max |
| **5.5"** | 1242 × 2208 | iPhone 8 Plus, iPhone 7 Plus, iPhone 6s Plus |

### iPad Screenshots (Optional but Recommended)

| Display Size | Pixel Dimensions | Device Examples |
|-------------|------------------|-----------------|
| **12.9" (6th gen)** | 2048 × 2732 | iPad Pro 12.9" (3rd gen and later) |
| **12.9" (2nd gen)** | 2048 × 2732 | iPad Pro 12.9" (1st and 2nd gen) |
| **11"** | 1668 × 2388 | iPad Pro 11" |
| **10.5"** | 1668 × 2224 | iPad Air (3rd gen), iPad Pro 10.5" |

## Screenshot Requirements

- **Format:** PNG or JPEG (PNG recommended for quality)
- **Color space:** sRGB or P3
- **No alpha/transparency**
- **Min 1 screenshot, max 10 per localization**
- **Aspect ratio:** Must match device (portrait or landscape)

## Our Screenshot Set

We capture **6 screenshots** for the App Store listing:

| # | Name | Content |
|---|------|---------|
| 1 | `01_onboarding_en` | Welcome screen with "Tiny Steps" branding |
| 2 | `02_decompose_en` | Task input with example text |
| 3 | `03_execute_en` | Single step displayed with timer |
| 4 | `04_celebration_en` | Task completion with confetti |
| 5 | `05_templates_en` | Template browser grid |
| 6 | `06_stats_en` | Stats with streak and achievements |

## Running Screenshot Automation

```bash
# Take screenshots for default device (iPhone 6.7")
./scripts/take_screenshots.sh

# Take screenshots for specific device
./scripts/take_screenshots.sh iphone65

# Take screenshots for all devices
./scripts/take_screenshots.sh all
```

## Post-Processing with Fastlane Frameit

After capturing raw screenshots, use [fastlane frameit](https://docs.fastlane.tools/actions/frameit/) to add device frames:

```bash
# Install fastlane (if not already installed)
gem install fastlane

# Add device frames
cd screenshots
fastlane frameit
```

### Frameit Configuration

Create `screenshots/Framefile.json`:

```json
{
  "device_frame_version": "latest",
  "default": {
    "title": {
      "color": "#333333",
      "font": "fonts/SFPro-Bold.ttf"
    },
    "background": "#FFFFFF",
    "padding": 50,
    "show_complete_frame": true
  }
}
```

## Directory Structure

```
screenshots/
├── raw/                    # Raw screenshots from automation
│   ├── 01_onboarding_en.png
│   ├── 02_decompose_en.png
│   └── ...
├── framed/                 # Screenshots with device frames
│   └── ...
├── Framefile.json          # Frameit configuration
└── titles.strings          # Screenshot titles for frameit
```

## Localization

When adding new languages:

1. Run screenshots with locale parameter
2. Name files with locale suffix: `01_onboarding_es.png`
3. Update `titles.strings` for each language
