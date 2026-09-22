# Multi-Screen Pong Screensaver

# work in progress - will not work yet

A dynamic retro Pong screensaver for macOS. Features responsive dual-paddle AI, customizable puck skins including UFO and Corgi themes with built-in vector fallbacks, authentic center divider styling, and clean frame-clearing engine that completely eliminates ghosting trails.

## Features
- **Multi-Monitor Support:** Runs smoothly across connected displays at 60 FPS with zero performance overhead.
- **Responsive Paddle AI:** Dual tracking paddles adjust tracking movement with deflection angles based on point of contact.
- **Customizable Skins:** Choose between a Classic Ball, UFO Spacecraft, or Corgi Puppy directly within the native macOS System Settings sheet.
- **Zero Ghosting Trails:** High-performance AppKit drawing loop refreshes the entire canvas on every frame.

## Installation & Setup

Because this is a free, open-source project built without a paid Apple Developer certificate, macOS Gatekeeper will show an "unidentified developer" prompt upon first install. Follow these steps to install:

### Option 1: Install Pre-Built Release
1. Download `PongScreensaver.saver` from the repository releases.
2. If quarantined by macOS Gatekeeper, clear the flag in Terminal:
   ```bash
   xattr -d com.apple.quarantine ~/Downloads/PongScreensaver.saver
   ```
3. Double-click the `.saver` bundle to install it into **System Settings** -> **Screen Saver**.

### Option 2: Build & Install From Source
1. Clone the repository and build using Xcode or `xcodebuild`:
   ```bash
   xcodebuild -project PongScreensaver.xcodeproj -scheme PongScreensaver -configuration Release build
   ```
2. Copy the built bundle to your local Screen Savers directory:
   ```bash
   cp -R build/Release/PongScreensaver.saver ~/Library/Screen\ Savers/
   ```
3. Open **System Settings** -> **Screen Saver** and select **PongScreensaver**.

## Customization
Click **Screen Saver Options** inside macOS System Settings to toggle between the available theme skins (Classic Ball, UFO Spacecraft, Corgi Puppy).

## License
[MIT](LICENSE)
