# 🍃 MindfulBreak

A beautiful macOS menu bar app that helps you take healthy breaks using a Pomodoro-style approach. Reduce screen fatigue, avoid phone distractions, and enjoy mindful moments with stunning visuals.

![macOS](https://img.shields.io/badge/macOS-13.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### 🎯 Core Functionality
- **Menu Bar App** - Runs silently in your macOS menu bar, no dock icon clutter
- **20-Minute Work Timer** - Automatic reminders after focused work periods
- **Mindful Break Screen** - Beautiful, distraction-free break window
- **5-Minute Break Warning** - Gentle reminder if you're taking a longer break

### 🎨 Break Content Options

| Option | Description |
|--------|-------------|
| 🌙 **Nature Scene** | Stunning animated night landscape with stars, aurora, fireflies, mountains, forest, and reflective water - inspired by macOS screensavers |
| 📰 **Tech News** | Latest headlines from Hacker News API |
| 😄 **Programming Jokes** | Fresh jokes from JokeAPI to lighten your mood |
| 🎮 **Quick Game** | Play Tic-Tac-Toe against the computer |
| ✨ **Surprise Me** | Random selection from all options |

### 🌌 Nature Scene Features
- Twinkling stars with realistic animation
- Glowing moon with crater details
- Drifting clouds
- Multi-layer mountain silhouettes
- Animated pine forest
- Rippling water with moonlight reflections
- Floating fireflies
- Northern lights (Aurora Borealis)
- Occasional shooting stars

### 🎮 Game Features
- Classic Tic-Tac-Toe
- Play as X against computer
- Glowing neon-style markers
- Winning cells highlight
- Quick restart option

## 🚀 Installation & Running

### Prerequisites
- macOS 13.0 (Ventura) or later
- Swift 5.9+ (included with Xcode 15+ or can be installed separately)

### Option 1: Using Swift Package Manager (No Xcode Required)

```bash
# Clone or navigate to the project
cd /path/to/MindfulBreak

# Build and run (development)
swift run

# Or build release version
swift build -c release
.build/release/MindfulBreak
```

### Option 2: Using the Run Script

```bash
cd /path/to/MindfulBreak
chmod +x run.sh
./run.sh
```

### Option 3: Using Xcode

1. Open `MindfulBreak.xcodeproj` in Xcode
2. Press `⌘R` to build and run
3. The app will appear in your menu bar

## 📖 Usage

### Getting Started
1. Launch the app - look for the 🍃 leaf icon in your menu bar
2. Click the icon to open the preferences popover
3. Select your preferred break content type
4. Work for 20 minutes - you'll receive a notification
5. Click "Take a Break Now" or wait for the automatic reminder

### Menu Bar Options
- **Nature Scene** - Animated night landscape
- **Tech News** - Latest tech headlines
- **Programming Jokes** - Developer humor
- **Quick Game** - Tic-Tac-Toe
- **Surprise Me** - Random selection

### During Break
- Enjoy the breathing animation at the top
- View your selected content
- Click "Refresh" for new content
- Click "Back to Work" when ready
- After 5 minutes, you'll get a gentle reminder

## 🏗 Project Structure

```
MindfulBreak/
├── Package.swift              # Swift Package Manager config
├── README.md                  # This file
├── run.sh                     # Quick run script
├── Sources/
│   ├── main.swift             # App entry point & AppDelegate
│   ├── MenuBarView.swift      # Menu bar popover UI
│   ├── BreakView.swift        # Main break screen with all content
│   ├── BreakWindowController.swift  # Window management
│   └── BreakContentProvider.swift   # API calls & content loading
└── MindfulBreak.xcodeproj/    # Xcode project (optional)
```

## 🔧 Configuration

### Environment Variables (Optional)

| Variable | Description |
|----------|-------------|
| `UNSPLASH_ACCESS_KEY` | For dynamic nature photos from Unsplash API |

Set in terminal before running:
```bash
export UNSPLASH_ACCESS_KEY="your-api-key"
swift run
```

## 🎨 Design Philosophy

- **Minimal & Calm** - Dark mode UI with soothing colors
- **No Infinite Scrolling** - Single content item per break
- **No Distractions** - Encourages mindful refreshing over phone usage
- **Beautiful Animations** - Smooth, relaxing visual effects

## 🔌 APIs Used

| API | Purpose | Fallback |
|-----|---------|----------|
| [Hacker News API](https://github.com/HackerNews/API) | Tech news headlines | Curated static headlines |
| [JokeAPI](https://jokeapi.dev/) | Programming jokes | Built-in joke collection |

## 🐛 Troubleshooting

### App doesn't appear in menu bar
- Check if the app is running in Activity Monitor
- Try running with `swift run` to see any error output

### No notifications
- Go to **System Settings → Notifications → MindfulBreak**
- Enable alerts and sounds

### Build errors
- Ensure you have Swift 5.9+ installed
- Run `swift --version` to check
- Try `swift package clean` then rebuild

## 📋 Requirements

- **OS**: macOS 13.0 (Ventura) or later
- **Architecture**: Apple Silicon (M1/M2/M3) or Intel
- **Swift**: 5.9+
- **Network**: Required for live news/jokes (falls back to offline content)

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new break content types
- Improve animations
- Add new mini-games

## 📄 License

MIT License - feel free to use and modify for your own projects.

## 🙏 Acknowledgments

- Inspired by the Pomodoro Technique
- macOS screensaver aesthetics
- The developer community for programming humor

---

**Made with 💚 for mindful developers**

*Take breaks. Stay healthy. Code better.*
