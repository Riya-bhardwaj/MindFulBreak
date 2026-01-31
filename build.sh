#!/bin/bash

# MindfulBreak Build Script
# Usage: ./build.sh [options]

set -e

APP_NAME="MindfulBreak"
BUILD_DIR="build"
RELEASE=false
CREATE_DMG=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_usage() {
    echo "Usage: ./build.sh [options]"
    echo ""
    echo "Options:"
    echo "  --release    Build in release mode (optimized)"
    echo "  --dmg        Create a DMG file for distribution"
    echo "  -h, --help   Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./build.sh              # Debug build"
    echo "  ./build.sh --release    # Release build"
    echo "  ./build.sh --release --dmg  # Release build with DMG"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --release)
            RELEASE=true
            shift
            ;;
        --dmg)
            CREATE_DMG=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_usage
            exit 1
            ;;
    esac
done

echo -e "${GREEN}Building $APP_NAME...${NC}"

# Create build directory
mkdir -p "$BUILD_DIR"

# Build configuration
if [ "$RELEASE" = true ]; then
    echo -e "${YELLOW}Building in release mode...${NC}"
    BUILD_CONFIG="release"
    swift build -c release
else
    echo -e "${YELLOW}Building in debug mode...${NC}"
    BUILD_CONFIG="debug"
    swift build
fi

# Get the built executable path
EXECUTABLE_PATH=".build/$BUILD_CONFIG/$APP_NAME"

if [ ! -f "$EXECUTABLE_PATH" ]; then
    echo -e "${RED}Build failed: Executable not found at $EXECUTABLE_PATH${NC}"
    exit 1
fi

# Create app bundle structure
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo -e "${YELLOW}Creating app bundle...${NC}"

rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp "$EXECUTABLE_PATH" "$MACOS_DIR/$APP_NAME"

# Copy resources if they exist
if [ -d "Sources/Resources" ]; then
    cp -r Sources/Resources/* "$RESOURCES_DIR/" 2>/dev/null || true
fi

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.mindfulbreak.app</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>MindfulBreak</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo -e "${GREEN}App bundle created at: $APP_BUNDLE${NC}"

# Create DMG if requested
if [ "$CREATE_DMG" = true ]; then
    echo -e "${YELLOW}Creating DMG...${NC}"

    DMG_NAME="$APP_NAME-1.0.dmg"
    DMG_PATH="$BUILD_DIR/$DMG_NAME"

    # Remove existing DMG
    rm -f "$DMG_PATH"

    # Create DMG
    hdiutil create -volname "$APP_NAME" -srcfolder "$APP_BUNDLE" -ov -format UDZO "$DMG_PATH"

    echo -e "${GREEN}DMG created at: $DMG_PATH${NC}"
fi

echo -e "${GREEN}Build complete!${NC}"
echo ""
echo "To run the app:"
echo "  open $APP_BUNDLE"
