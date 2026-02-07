#!/bin/bash
# Screenshot automation script for App Store listings.
# 
# Usage: ./scripts/take_screenshots.sh [device]
# 
# Devices:
#   iphone67    - iPhone 6.7" (default)
#   iphone65    - iPhone 6.5"
#   iphone55    - iPhone 5.5"
#   ipad129     - iPad Pro 12.9"
#   all         - Run all device sizes
#
# Prerequisites:
# - Flutter SDK installed
# - iOS Simulator or Android emulator running
# - Run `flutter pub get` first

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DEVICE=${1:-iphone67}
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${PROJECT_ROOT}/screenshots/raw"

echo -e "${GREEN}📸 Tiny Steps Screenshot Automation${NC}"
echo "=================================="
echo ""

# Navigate to project root
cd "$PROJECT_ROOT"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Function to take screenshots for a device
take_screenshots() {
    local device_name=$1
    echo -e "${YELLOW}Taking screenshots for ${device_name}...${NC}"
    
    flutter drive \
        --driver=test_driver/integration_test.dart \
        --target=integration_test/screenshot_test.dart \
        --dart-define=SCREENSHOT_MODE=true \
        --dart-define=DEVICE_NAME="$device_name" \
        --no-pub
    
    echo -e "${GREEN}✅ Screenshots captured for ${device_name}${NC}"
}

# Function to list available simulators/emulators
list_devices() {
    echo "Available iOS Simulators:"
    xcrun simctl list devices available 2>/dev/null || echo "  (xcrun not available)"
    echo ""
    echo "Available Android Emulators:"
    flutter devices 2>/dev/null | grep -E "(android|ios)" || echo "  (no devices found)"
}

# Main execution
case $DEVICE in
    "iphone67"|"iphone65"|"iphone55"|"ipad129")
        take_screenshots "$DEVICE"
        ;;
    "all")
        echo "Running all device sizes..."
        for d in iphone67 iphone65 iphone55 ipad129; do
            take_screenshots "$d"
        done
        ;;
    "list")
        list_devices
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [device]"
        echo ""
        echo "Devices:"
        echo "  iphone67  - iPhone 6.7\" (1290 × 2796, default)"
        echo "  iphone65  - iPhone 6.5\" (1242 × 2688)"
        echo "  iphone55  - iPhone 5.5\" (1242 × 2208)"
        echo "  ipad129   - iPad Pro 12.9\" (2048 × 2732)"
        echo "  all       - Run all device sizes"
        echo "  list      - Show available simulators/emulators"
        echo ""
        echo "Output: screenshots/raw/"
        ;;
    *)
        echo -e "${RED}Unknown device: $DEVICE${NC}"
        echo "Run '$0 help' for usage"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}📁 Screenshots saved to: ${OUTPUT_DIR}${NC}"
echo ""
echo "Next steps:"
echo "  1. Review screenshots in screenshots/raw/"
echo "  2. Use fastlane frameit to add device frames"
echo "  3. Upload to App Store Connect"
