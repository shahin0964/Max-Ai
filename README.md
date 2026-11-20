# Max AI (Android Flutter Application)

**Package:** `com.max.ai`  
**Framework:** Flutter (Material 3 Dark Theme)  
**Architecture:** Layered Architecture (MVVM + Provider + Repository Pattern)

---

## 🌟 Key Features

1. **Hybrid Online / Offline Intelligence:**
   - **Online Mode:** Uses Google Gemini API (`gemini-1.5-flash`) for fast, multimodal reasoning and natural chat.
   - **Offline Mode:** Uses the on-device `OfflineTaskService` to manage tasks, checklists, and local routines without internet (0 tokens used).
   - **Auto-Switching:** Real-time connectivity watcher dynamically toggles between Online and Offline modes.

2. **Token Saver Architecture (Rate-Limit Protection):**
   - **Sliding Window Context:** Retains only the last 4 turns (8 messages) to prevent the context from ballooning.
   - **System Prompt Caching:** Standardized instructions to maximize Gemini Prompt Caching (saving up to 95% token cost).
   - **Offline Fallback:** Common productivity and task actions run locally at zero token cost.

---

## 📁 Project Structure

```text
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_strings.dart
│   └── theme/
│       └── app_theme.dart
├── data/
│   ├── models/
│   │   ├── chat_message.dart
│   │   └── local_task.dart
│   └── services/
│       ├── gemini_api_service.dart
│       ├── offline_task_service.dart
│       └── connectivity_service.dart
└── presentation/
    ├── providers/
    │   ├── chat_provider.dart
    │   └── task_provider.dart
    ├── screens/
    │   ├── home_screen.dart
    │   ├── chat_screen.dart
    │   ├── tasks_screen.dart
    │   └── settings_screen.dart
    └── widgets/
        ├── message_bubble.dart
        ├── connection_badge.dart
        ├── chat_input_bar.dart
        └── task_tile.dart
```

---

## 🚀 How to Build the APK

### Method 1: Automatic Cloud Build (Recommended - Zero Setup)
1. Push this code to a GitHub repository.
2. The included GitHub Actions workflow (`.github/workflows/build-apk.yml`) will automatically compile the release APK.
3. Download `app-release.apk` directly from the GitHub **Actions > Artifacts** tab onto your Android phone!

### Method 2: Local / PC Build
```bash
flutter pub get
flutter build apk --release
```
The compiled APK will be at:
`build/app/outputs/flutter-apk/app-release.apk`
