# Developer Setup & Build Guide

This was created with the help of Google Gemini.

This guide explains how to set up the file structure, configure the customizable assets (UFO and Corgi), and compile the screensaver project from source using the command-line tools.

---

## 🛠️ Project File Structure

To build successfully, your local repository directory must be arranged exactly like this:

- 📂 **Root Folder**
  - 📄 `README.md` (General user installation manual)
  - 📄 `README_DEV.md` (This development file)
  - 📄 `LICENSE` (MIT Open-Source text)
  - 📄 `.gitignore` (Filters out local compilation junk files)
  - 📄 `PongScreensaver.xcodeproj` (Main Xcode project system engine launcher)
  - 📂 **PongScreensaver/** (Primary source logic folder)
    - 📄 `Info.plist` (Plug-in architecture map declaring the Principal class to macOS)
    - 📄 `PongScreensaverView.swift` (Primary game engine and non-trail canvas logic)
    - 📄 `PongSettingsController.swift` (Preference dropdown management logic)
    - 📄 `PongSettingsView.xib` (The visual user settings window layout)
    - 📂 `Assets.xcassets/` (Graphic storage container)
      - 📂 `ufo_icon.imageset/` (Custom UFO sprite mapping folder)
        - 📄 `Contents.json` (Xcode asset mapping schema metadata)
        - 🖼️ `ufo.png` (Your transparent UFO graphic file)
      - 📂 `corgi_icon.imageset/` (Custom Corgi sprite mapping folder)
        - 📄 `Contents.json` (Xcode asset mapping schema metadata)
        - 🖼️ `corgi.png` (Your transparent Corgi puppy graphic file)

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
