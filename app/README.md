# Developer Setup & Build Guide

This guide explains how the project is structured, how custom assets can be added, and how to compile the screensaver bundle from source.

---

## 🛠️ Project File Structure

The repository is structured as follows:

- 📂 **Root Folder**
  - 📄 `README.md` (General user installation manual)
  - 📄 `LICENSE` (MIT Open-Source text)
  - 📄 `.gitignore` (Filters out local compilation junk files)
  - 📁 `PongScreensaver.xcodeproj/` (Xcode project package containing `project.pbxproj`)
  - 📂 **app/** (Primary source logic folder)
    - 📄 `README.md` (This developer guide)
    - 📄 `Info.plist` (Plug-in architecture map declaring the Principal class to macOS)
    - 📄 `PongScreensaverView.swift` (Primary game engine and rendering logic)
    - 📄 `PongSettingsController.swift` (Preference sheet controller logic)
    - 📄 `PongSettingsView.xib` (The visual user settings window layout)

> **Note on Custom Assets:** The screensaver has built-in vector renderers for UFO and Corgi themes when running without external asset bundles. If you wish to provide custom PNG sprites, you can add them to the Xcode project as described below.

---

## 🎨 Adding Custom UFO & Corgi Images

The screensaver searches explicitly for the image asset tokens `"ufo_icon"` and `"corgi_icon"`. Follow these steps to map them using text configurations or raw file transfers:

### 1. The UFO Image Assets Configuration
Create a subfolder named `ufo_icon.imageset` inside your `Assets.xcassets/` directory. Place your transparent image asset inside named `ufo.png` along with a file named `Contents.json` containing this code:

```json
{
  "images" : [
    {
      "filename" : "ufo.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

### 2. The Corgi Image Assets Configuration
Create a subfolder named `corgi_icon.imageset` inside your `Assets.xcassets/` directory. Place your transparent image asset inside named `corgi.png` along with a file named `Contents.json` containing this code:

```json
{
  "images" : [
    {
      "filename" : "corgi.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

---

## 🚀 Compiling and Bundling the Release via Terminal (VS Code)

Because a `.saver` file is built using Apple's frameworks, use the macOS native command-line compilation utility `xcodebuild`. Open your integrated VS Code terminal and complete these final deployment steps:

### 1. Compile the Standalone Production Binary
Execute the compiler from the root of your project directory to build a highly optimized production bundle:
```bash
xcodebuild -project PongScreensaver.xcodeproj -scheme PongScreensaver -configuration Release build
```

### 2. Extract the Finished Bundle
When the compiler finishes running, open the local hidden directory inside Finder to retrieve your app file:
```bash
open build/Release/
```
*(Note: If you have custom global developer behaviors set up, your file may instead be located under `open ~/Library/Developer/Xcode/DerivedData/`)*

### 3. Zip the Binary Package for Distribution
Because macOS plugin packages are actually specialized folders, they will corrupt if uploaded uncompressed to GitHub. Compress the package directly from your terminal loop:
```bash
cd build/Release/
zip -r ~/Desktop/PongScreensaver.saver.zip PongScreensaver.saver
```
Your compiled **`PongScreensaver.saver.zip`** asset bundle is now on your Desktop, ready to be safely dropped directly onto your GitHub Releases section!
