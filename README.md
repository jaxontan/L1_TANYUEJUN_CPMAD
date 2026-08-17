# 🐠 Temasek of Fishes

A Flutter aquarium adventure demo app. Dive into an underwater kingdom: collect native fish species, grow your net worth, play a memory match game, and compete with fellow explorers on the reef.

## ✨ Features

- **Authentication** — Email/password sign up & sign in with Firebase Auth, plus a one-tap **Quick Demo Login**.
- **Marketplace** — Buy & collect 12 native fish species with the coin economy (start with 50 coins).
- **Memory Match Game** — Timed card-matching game with 3 difficulties, rewards Coins & EXP on victory:
  - Easy: 60s, +5 Coins, +5 EXP
  - Medium: 45s, +10 Coins, +10 EXP
  - Hard: 30s, +15 Coins, +15 EXP
- **Fish Tank** — Animated aquarium where your owned fish swim around. Tap a fish to learn more about it.
- **Leaderboard** — Live rankings of all explorers by EXP (tie-broken by total net worth).
- **Profile** — Edit name/email/password, set an avatar from gallery or camera, track Coins, Net Worth & EXP.
- **Animated Aquarium Theme** — Custom-painted rising bubbles, swaying seagrass, ocean gradient backgrounds.
- **Background Music** — Looping BGM powered by `audioplayers`.
- **State Management** — Classic `StatefulWidget` + `setState`, with `Navigator`-based routing (bottom nav bar + floating nav pills).

## 🔐 Demo Login Credentials

| Field    | Value          |
| -------- | -------------- |
| **Email**    | `demo@sea.com` |
| **Password** | `123456`       |

> Tip: On the login screen you can also tap **"Quick Demo Login (demo@sea.com)"** to log in automatically. If the demo account doesn't exist yet, the app will create it for you on first login.

## 🚀 Getting Started

1. Clone the repository.
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run
   ```
   > Requires a connected device or emulator (Android / iOS / web).

> **Note:** The app uses Firebase (Auth + Cloud Firestore). A pre-configured `firebase_options.dart` is included — if you want to use your own Firebase project, replace it with your project's config via `flutterfire configure`.

## 🧰 Tech Stack

- **Flutter** (Material 3) — Dart SDK ^3.12.2
- **Firebase Auth & Cloud Firestore** — authentication and cloud persistence
- **packages**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `image_picker`, `fluttertoast`, `audioplayers`

## 📁 Project Structure

```
lib/
├── main.dart                     # App entry, Firebase init, BGM
├── firebase_options.dart         # Firebase configuration
├── models/                       # FishItem, FishCard, UserProfile
├── services/
│   └── firebaseauth_service.dart # Auth + Firestore data layer
├── screens/
│   ├── Auth/     (login, signup)
│   ├── Marketplace/
│   ├── Games/    (memory game)
│   ├── FishTank/
│   ├── Leaderboard/
│   ├── Profile/
│   └── About/
├── widgets/                      # Reusable UI (theme, background, coins, nav)
└── theme/                        # FishTheme (colors, buttons, inputs)
```

## 🗺️ How to Play

1. Start with **50 coins**.
2. Buy fish from the **Marketplace** to grow your collection.
3. View your collection in the **Fish Tank**.
4. Play the **Memory Game** to earn Coins & EXP.
5. Climb the **Leaderboard** rankings by EXP.

© 2026 Temasek Fishes • Made with 💙 for Sea Explorers
