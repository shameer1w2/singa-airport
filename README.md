# ✈️ Sinport — Singapore Airport Navigation App

A Flutter UI implementation of the **Sinport** airport navigation app for Singapore Changi Airport, based on the Dribbble design reference by Phenomenon Studio.

---

## 📱 Screens

| Screen | Description |
|--------|-------------|
| **Home** | Flight card, quick services, nearby places, departure board, airport map preview |
| **Explore** | Searchable list of airport places with category filters |
| **Map** | Interactive terminal map with gate pins and level selector |
| **Flights** | Live departure/arrival board with status filters |
| **Services** | Airport transfers, hotels, and airport services |
| **Profile** | User profile, trip stats, saved flights, settings |

---

## 🛠 Tech Stack

- **Flutter** 3.x + **Dart** 3.x
- [`google_fonts`](https://pub.dev/packages/google_fonts) — Inter typeface
- [`flutter_animate`](https://pub.dev/packages/flutter_animate) — smooth entrance animations
- [`smooth_page_indicator`](https://pub.dev/packages/smooth_page_indicator) — page dots
- [`percent_indicator`](https://pub.dev/packages/percent_indicator) — progress indicators
- Pure **CustomPainter** for the terminal map

---

## 🎨 Design Decisions

### Color System
- **Background**: `#0D0D0F` — near-black for depth
- **Primary**: `#6C63FF` — purple accent for navigation elements
- **Accent**: `#00D9C0` — teal for highlights and CTAs
- **Surface cards**: `#1E1E26` with subtle borders

### Layout
- `SliverAppBar` on home for collapsible header behavior
- `IndexedStack` for tab navigation to preserve scroll state
- `BottomNavigationBar` with animated pill indicator for selected tab
- Horizontal `ListView` for places and hotels cards

### Interactions
- `HapticFeedback` on all taps
- `flutter_animate` entrance animations with staggered delays
- Pulsing boarding alert with `AnimationController`
- Modal bottom sheets for place/flight details
- `CustomPainter`-drawn terminal map with interactive gate pins

### Data
All data is hardcoded dummy data in `lib/models/models.dart`.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0

### Run

```bash
# Clone or extract the project
cd sinport_app

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build APK
flutter build apk --release
```

---

## 📂 Project Structure

```
sinport_app/
├── lib/
│   ├── main.dart                 # App entry + bottom navigation
│   ├── theme/
│   │   └── app_theme.dart        # Colors, typography, theme
│   ├── models/
│   │   └── models.dart           # Data models + sample data
│   ├── widgets/
│   │   └── shared_widgets.dart   # Reusable UI components
│   └── screens/
│       ├── home_screen.dart      # Home / Dashboard
│       ├── explore_screen.dart   # Place discovery
│       ├── map_screen.dart       # Airport terminal map
│       ├── flights_screen.dart   # Live flight board
│       ├── services_screen.dart  # Transfers, hotels, services
│       └── profile_screen.dart   # User profile & settings
├── assets/
│   └── images/
├── pubspec.yaml
└── README.md
```

---

## 🧑‍💻 Notes

- The map is built with Flutter's `CustomPainter` (no maps SDK required)
- No API keys or external services needed — fully self-contained
- Designed for **dark mode only**, matching the Dribbble reference
- Tested on iOS and Android viewport sizes
