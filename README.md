# MindfulBreak

A minimal macOS menu bar app for mindful breaks. Take regular breaks with entertaining content - tech news, programming jokes, a quick game, or tech memes.

## Features

- **Menu Bar App** - Lives quietly in your menu bar with a leaf icon
- **Break Reminders** - Pomodoro-style timer for regular break notifications
- **Tech News** - Latest headlines from Hacker News
- **Programming Jokes** - Random programming humor to brighten your break
- **Quick Game** - Play Tic-Tac-Toe during your break
- **Tech Memes** - Programming memes to make you smile
- **Breathing Animation** - Calming visual to help you relax
- **Full-Screen Mode** - Expand the break window for an immersive experience
- **5+ Minute Warning** - Alert if you've been on break too long
- **Refresh Content** - Load new content without closing the break window

## Requirements

- macOS 13.0 or later
- Swift 5.9+

## Installation

### From DMG (Recommended)

1. Download the latest `MindfulBreak-1.0.dmg` from releases
2. Open the DMG and drag MindfulBreak to your Applications folder
3. Launch MindfulBreak from Applications

### Build from Source

```sh
# Clone the repository
git clone https://github.com/Riya-bhardwaj/MindFulBreak.git
cd MindFulBreak

# Build and run (debug)
./build.sh
open MindfulBreak.app

# Build release with DMG
./build.sh --release --dmg
```

> **Note:** Do not use `swift run` directly. This app requires a proper macOS app bundle for notifications and other system features. Always use `./build.sh` followed by `open MindfulBreak.app`.

### Build Options

```
./build.sh [options]

Options:
  --release    Build in release mode (optimized)
  --dmg        Create a DMG file for distribution
  -h, --help   Show help message
```

## Usage

1. **Launch** - Click the leaf icon in your menu bar to see the dropdown
2. **Choose Content** - Select your preferred break content type:
   - Tech News
   - Programming Jokes
   - Quick Game
   - Tech Meme
3. **Take a Break** - Click "Take a Break Now" to open the break window
4. **During Break** - Enjoy your content with a calming breathing animation
5. **Refresh** - Click refresh to load new content
6. **Full-Screen** - Toggle full-screen mode for an immersive break
7. **Back to Work** - Click "Back to Work" when you're ready

## Configuration

Edit `Sources/Resources/config.json` to customize timing:

```json
{
    "workDurationMinutes": 45,
    "breakDurationSeconds": 300,
    "warningTimeSeconds": 5
}
```

Then rebuild with `./build.sh`.

## Project Structure

```
MindfulBreak/
├── Sources/
│   ├── main.swift                    # App entry point
│   ├── MenuBarView.swift             # Menu bar dropdown UI
│   ├── BreakView.swift               # Break window UI with content cards
│   ├── BreakContentProvider.swift    # Content loading (news, jokes, memes)
│   └── BreakWindowController.swift   # Window management
├── MindfulBreak/
│   ├── MindfulBreakApp.swift         # Alternative app entry
│   ├── Views/
│   │   ├── MenuBarView.swift
│   │   ├── BreakView.swift
│   │   └── BreakWindowController.swift
│   ├── Services/
│   │   └── BreakContentProvider.swift
│   └── Assets.xcassets/
├── Package.swift
├── build.sh
├── .gitignore
├── LICENSE
└── README.md
```

## License

MIT License - see [LICENSE](LICENSE) for details.
