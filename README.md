# FinLit India — Frontend

Flutter mobile app for financial literacy education targeting women in rural India.

## Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Local Storage**: shared_preferences (persists registration state)

## Project Structure

```
lib/
├── main.dart                        # App entry point — checks if user is registered
├── models/
│   ├── lesson.dart                  # Lesson and QuizQuestion data models
│   └── user.dart                    # UserProfile data model
├── data/
│   └── mock_data.dart               # Hardcoded mock lessons, questions, user stats
└── screens/
    ├── registration_screen.dart     # First launch — phone number input
    ├── roadmap_screen.dart          # Main screen — Duolingo-style lesson map
    ├── profile_screen.dart          # User profile, stats, completed lessons
    └── lesson_screen.dart           # Lesson article + quiz + results dialog
```

## Screens

### 1. Registration
Shown only on first launch. User enters their phone number (+91) and taps Continue. Phone number is saved locally via shared_preferences. On subsequent launches the app goes directly to the Roadmap.

### 2. Roadmap
Main screen of the app. Shows:
- Top bar: streak 🔥, coins 💰, gems 💎
- Green section banner: current module name
- Scrollable zigzag path of lesson circles:
  - ✅ Green + checkmark = completed
  - 🔢 Number = current/unlocked lesson
  - 🔒 Grey + lock = locked
- Bottom navigation: Home, Shop, Profile

### 3. Profile
Shows user stats: name, streak, coins, gems, number of completed lessons.

### 4. Lesson + Quiz
Opened by tapping an available lesson circle. Contains:
- Lesson title and full article text
- Quiz at the bottom with 4 answer options per question
- Results dialog after submission: score % and coins earned 🎉

## Getting Started

### Requirements
- Flutter SDK
- Android Studio (for emulator)
- VS Code with Flutter + Dart extensions

### Run the app

```bash
flutter pub get
flutter run
```

### Reset registration (for testing)

To see the registration screen again, uninstall the app from the emulator and rerun.

## Current State

This is a prototype using **hardcoded mock data**. No backend or Firebase is connected yet.

Mock data includes:
- 10 lessons across 2 modules
- Lessons 1–3 pre-marked as completed
- Lesson 4 unlocked as current
- Lessons 5–10 locked

## Notes

- All UI text is in English
- Overscroll/stretch effect is disabled on all screens
- Designed for low digital literacy: large buttons, simple navigation, clear icons