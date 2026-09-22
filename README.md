# Multi-Screen Pong Screensaver

A dynamic, multi-monitor retro Pong screensaver for macOS. Watch a match play out seamlessly across your connected displays. Features customizable puck skins including a UFO and a Corgi, with a clean frame-clearing engine that completely eliminates ghosting trails.

## Features
- **Multi-Monitor Synchronization:** Syncs ball physics locally across multiple screens without system-wide network overhead.
- **Dynamic Paddle AI:** Smooth tracking logic adjusts paddle response speeds automatically based on the ball's positioning.
- **Customizable Skins:** Choose between a Classic Ball, a UFO, or a Corgi Puppy inside the native macOS settings sheet.
- **Zero Ghosting Trails:** Optimized drawing loop completely flushes the canvas on every cycle at 60 FPS.

## Installation & Setup

Because this is a free, open-source project built without a paid Apple Developer signature, macOS Gatekeeper will show an "unidentified developer" warning upon installation. Follow these quick steps to bypass it safely:

### Option 1: The Fast Terminal Fix (Recommended)
1. Download the latest `PongScreensaver.saver` bundle from the [Releases](link-to-releases) tab.
2. Open your Mac Terminal app and clear the download quarantine flag by running:
   ```bash
   xattr -d com.apple.quarantine ~/Downloads/PongScreensaver.saver
   ```
3. Double-click the file to open it in **System Settings** and install it!

### Option 2: Manual Drag & Right-Click
1. Copy the `PongScreensaver.saver` bundle into your Mac's local screensaver folder:
   `~/Library/Screen Savers/`
2. Open **System Settings** -> **Wallpapers & Screen Savers**.
3. If blocked, navigate to the folder above in Finder, **Right-Click (Control-Click)** the file, select **Open**, and authorize the exception.

## Customization
Click **Screen Saver Options** inside macOS System Settings to toggle between the available theme assets.

## License
[MIT](LICENSE)
