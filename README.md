# ⚡ Max AI (Powered by OpenJarvis Framework)

> **Next-Generation Autonomous On-Device & Cloud Hybrid AI Assistant for Android**  
> Package Name: `com.max.ai`  
> Application Name: `Max AI`  

---

## 🌟 Overview & Unique Design

**Max AI** is an intelligent on-device and cloud-hybrid Android assistant built using the core architectural principles of [OpenJarvis](https://github.com/open-jarvis/OpenJarvis). Designed with an **Aura Quantum Holographic Cyber** aesthetic, Max AI combines local-first autonomous execution with world-class cloud cognition.

### ✨ Highlights & Unique UI:
1. **Interactive 3D Holographic AI Reactor Core (`HolographicReactorOrb`)**:
   - Custom animated canvas engine with 3 concentric 3D-perspective tilted orbital rings rotating in opposing directions.
   - Pulsing energy core that dynamically reacts to voice & cognitive states:
     - 🔵 **IDLE**: Gentle quantum breathing pulse (Cyan/Violet)
     - 🟢 **LISTENING**: Acoustic sensor wave amplification (Neon Emerald)
     - 🟠 **THINKING**: Rapid orbital particle acceleration (Amber Flare)
     - 🟣 **SPEAKING**: Harmonic resonance soundwave pulses (Violet Glow)
2. **Hybrid Cognitive Engine**:
   - ⚡ **Google Gemini**: Gemini 2.5 Flash, 3.8 Pro, 2.5 Flash Lite
   - 🧠 **Anthropic Claude**: Claude 3.5 Sonnet, Claude 3.5 Haiku
   - 🤖 **OpenAI**: GPT-4o, GPT-4o Mini
   - 🏠 **OpenJarvis / Ollama Local Server**: Direct on-device or LAN inference (`http://127.0.0.1:8000/v1/chat/completions` or `http://localhost:11434`)
3. **Autonomous ReAct Agent Loop (`AgentExecutorService`)**:
   - Multi-step reasoning: `Thought` ➔ `Action` ➔ `Observation` ➔ `Final Answer`.
   - Tool execution engine supporting:
     - 🌐 `web_search`: Live internet search and news synthesis
     - 📊 `device_telemetry`: Battery percentage, RAM usage, hardware diagnostics
     - 💾 `memory_recall` & `save_memory`: OpenJarvis episodic memory stack
     - 🧮 `calculator`: Accurate mathematical evaluations
4. **OpenJarvis Episodic Memory Stack**:
   - Persistent facts, user preferences, identity definitions, and tasks.
   - Seamless dynamic injection into system prompts for personalized intelligence.
5. **Real-time Hardware & Engine Telemetry Cockpit**:
   - Live battery level and charging state
   - Active RAM usage gauge (GB used / GB total)
   - Round-trip inference latency (ms)
   - One-tap connection ping test for all providers.

---

## 📱 Project Directory Structure

```
MaxAi_OpenJarvis/
├── .github/
│   └── workflows/
│       └── build-and-release.yml   # Automatic GitHub Actions APK build & release
├── android/
│   ├── app/
│   │   ├── build.gradle.kts       # applicationId = "com.max.ai"
│   │   └── src/main/
│   │       ├── AndroidManifest.xml # Permissions (INTERNET, RECORD_AUDIO, etc.)
│   │       └── kotlin/com/max/ai/
│   │           └── MainActivity.kt # System Telemetry MethodChannel
│   ├── build.gradle.kts
│   └── settings.gradle.kts
├── lib/
│   ├── main.dart                   # App entrypoint & service initialization
│   ├── models/
│   │   ├── agent_task.dart         # ReAct agent loop data models
│   │   ├── chat_message.dart       # Message entity with tool calls & latency
│   │   ├── memory_item.dart        # Episodic long-term memory entity
│   │   ├── model_provider.dart     # AI Provider enum & model definitions
│   │   └── telemetry_data.dart     # Battery, RAM & Hardware stats model
│   ├── screens/
│   │   ├── agent/agent_screen.dart # Autonomous mission runner & timeline
│   │   ├── chat/chat_screen.dart   # Interactive chat cockpit with reactor
│   │   ├── dashboard/dashboard_screen.dart # Hardware & engine telemetry
│   │   ├── memory/memory_screen.dart # Knowledge base & episodic memory
│   │   ├── settings/settings_screen.dart # API keys, local server URL, sliders
│   │   ├── voice/voice_screen.dart # Fullscreen holographic voice cockpit
│   │   └── main_shell.dart         # Cyberpunk bottom navigation shell
│   ├── services/
│   │   ├── agent_executor_service.dart # Autonomous ReAct loop engine
│   │   ├── agent_tools_service.dart    # Tool handlers (search, device, math)
│   │   ├── ai_engine_service.dart      # Hybrid provider dispatch & latency ping
│   │   ├── hardware_telemetry_service.dart # Native MethodChannel bridge
│   │   ├── memory_service.dart         # SharedPreferences long-term memory
│   │   ├── settings_service.dart       # Persistent preferences
│   │   └── voice_service.dart          # STT & TTS voice controller
│   ├── theme/
│   │   └── app_theme.dart          # Cyberpunk Void & Holographic Neon theme
│   └── widgets/
│       ├── agent_step_timeline.dart # Interactive execution timeline accordion
│       ├── glass_panel.dart         # Frosted glass card with glow borders
│       ├── holographic_reactor_orb.dart # 3D Canvas AI Reactor
│       ├── hud_telemetry_bar.dart   # Top floating status & provider pill
│       └── model_selector_sheet.dart# Bottom sheet model & latency tester
└── pubspec.yaml                    # Flutter dependencies
```

---

## 🚀 Building & Releasing the APK

### Method 1: Automatic GitHub Actions (Recommended)
1. Initialize a git repository in this folder:
   ```bash
   cd ~/projects/MaxAi_OpenJarvis
   git init
   git add .
   git commit -m "feat: initial commit of Max AI with OpenJarvis engine"
   git remote add origin git@github.com:your-username/Max-Ai.git
   git branch -M main
   git push -u origin main
   ```
2. The included GitHub Actions workflow (`.github/workflows/build-and-release.yml`) will automatically:
   - Check out code
   - Set up JDK 21 & Flutter
   - Generate signing keystore or use GitHub secret `KEYSTORE_BASE64`
   - Build `MaxAI-release-v1.0.x.apk`
   - Create a GitHub Release with the APK ready to download!

---

## ⚙️ Configuration & Local OpenJarvis Server

In **Settings & Model Config** inside the app:
- **Google Gemini API Key**: Add your Gemini key to use `gemini-2.5-flash` or `gemini-3.8-pro`.
- **OpenJarvis / Ollama Local Server**: Set URL to `http://127.0.0.1:8000` (if running OpenJarvis daemon on Termux) or your PC's LAN IP `http://192.168.x.x:8000` to run 100% on-device/local AI!
