# 🎙️ Maya AI Assistant (v5.2.63)

> **Autonomous On-Device AI Voice Agent & Android Controller**  
> Built with modern **Jetpack Compose (Material 3)**, **Silero VAD**, **TFLite Wakeword Detection**, **Termux Bridge**, and **Multi-Turn Agentic Tool Calling**.

---

## 🌟 Key Highlights

- 🧠 **Autonomous Agentic Loop**: Supports Groq (Llama 3.3 70B), Google Gemini, and OpenRouter for real-time tool calling.
- 🎙️ **On-Device Voice Engine**:
  - `hey_maya.tflite` & `hello_maya.tflite` wake-word detection.
  - `silero_vad.tflite` speech gating.
  - 3 Distinct Voice Personas: **Maya**, **Friday**, **Venom**.
  - Interactive multi-layer **Glowing Voice Orb** with live speech amplitude reactivity.
- 💻 **Termux Live Automation Bridge**:
  - Executes bash commands via `com.termux.permission.RUN_COMMAND`.
  - Built-in **Terminal Reel** console for live output streaming.
- 📱 **Screen Perception & Accessibility Driver**:
  - Reads screen elements in any app via `MayaAccessibilityService`.
  - Auto-tap by text, coordinate clicks, and gesture swipes.
  - Built-in macro execution (`builtin_macros.json`).
- 🛠️ **Device Control Hub**:
  - WhatsApp messaging, phone calls, SMS, flashlight toggle, and volume sliders.
- 💾 **Continuous Memory**:
  - Room SQLite database for persistent user preferences and long-term memory.
- 🎨 **100% Identical Maya UI/UX**:
  - Inter & JetBrains Mono typography.
  - 5-tab Navigation: Voice Home, Chat Cockpit, Terminal Reel, Tools & Automations, Settings.
  - Floating translucent HUD overlay when triggered as the system assistant.

---

## 📦 Download & Release

Every push to `main` builds a new APK automatically via GitHub Actions.  
Check the [Releases](https://github.com/shahin0964/Max-Ai/releases) tab to download the latest signed APK.
