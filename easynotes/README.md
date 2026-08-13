# 📝 Easy Notes - Production Flutter App

A modern, offline-first note-taking application designed with **Material 3**, built using Flutter and the **Hive** NoSQL embedded database.

---

## 🌟 Key Features

- **⚡ Blazing Fast Offline Storage**: Built with Hive NoSQL engine for instantaneous read/write without any network overhead.
- **🎨 Material 3 & Dynamic Color**: Seamless Light and Dark mode with 8 soothing pastel card palettes.
- **📌 Pin to Top**: Keep important notes always visible.
- **🔍 Instant Search & Tags**: Filter effortlessly across titles, body content, and custom hashtags.
- **💾 Real-time Auto-Save**: Never lose a single stroke. Auto-saves continuously as you type.
- **📐 Responsive Masonry Grid & List**: Toggle between multi-column staggered view and clean linear list view.
- **🛡️ 100% Private & No Permissions**: Zero internet access, zero accounts, zero analytics or telemetry.

---

## 🏗️ Architecture & Project Structure

Clean separation of concerns with modular layers:

```
lib/
├── database/
│   ├── boxes.dart            # Hive Box identifiers
│   └── hive_service.dart     # Database initialization & CRUD methods
├── models/
│   ├── note.dart             # Note data model with annotations
│   └── note.g.dart           # Generated Hive TypeAdapter
├── screens/
│   ├── splash_screen.dart    # Animated brand launch screen
│   ├── home_screen.dart      # Main dashboard with search and grid
│   ├── note_editor_screen.dart # Auto-saving note composer
│   └── settings_screen.dart  # Theme and storage preferences
├── services/
│   ├── note_service.dart     # Provider ChangeNotifier managing notes state
│   └── theme_service.dart    # Light/Dark theme manager
├── utils/
│   ├── app_colors.dart       # Material 3 colors & card palettes
│   ├── app_theme.dart        # Light and Dark ThemeData
│   ├── constants.dart        # Global configuration
│   └── date_formatter.dart   # Relative timestamp helper
├── widgets/
│   ├── color_picker_palette.dart # Horizontal color selector
│   ├── delete_dialog.dart    # Confirmation modal
│   ├── empty_state.dart      # Illustrated empty placeholder
│   ├── note_card.dart        # Rounded note item with pin & tags
│   ├── search_bar_widget.dart# Material 3 search bar
│   └── staggered_note_grid.dart # Dynamic masonry layout
└── main.dart                 # App bootstrap & MultiProvider
```

---

## 🚀 How to Build & Run

### Prerequisites
- Flutter SDK (>= 3.19.0)
- Android Studio / Android SDK (API 34)
- Java 17

### 1. Get Dependencies
```bash
flutter pub get
```

### 2. (Optional) Run Code Generator for Hive Adapters
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run on Connected Device / Emulator
```bash
flutter run
```

### 4. Build Production Release Android AppBundle (Play Store)
```bash
flutter build appbundle --release
```
Output path: `build/app/outputs/bundle/release/app-release.aab`

### 5. Build Standalone Release APK
```bash
flutter build apk --release --split-per-abi
```
Output path: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
