# Aura Voice AI 🎙️🧠
**100% Offline, Private, Always-Active On-Device Voice AI Assistant for Android**

Designed and optimized for high-performance devices like **ASUS ROG Phone 7 (Snapdragon 8 Gen 2 / 12GB RAM)**.

---

## 🌟 প্রধান বৈশিষ্ট্যসমূহ (Key Features)

* 🚫 **Zero API Key & No Internet Needed:** কোনো সার্ভার বা এপিআই কি লাগবে না। সম্পূর্ণ অফলাইনে আপনার ফোনেই চলবে।
* 🧠 **On-Device Brain (3B Model):** **Qwen 2.5 3B / Llama 3.2 3B (GGUF, 4-bit)** লোকাল মডেল রান করার জন্য প্রস্তুত।
* 👂 **Always-Active Listening (Wake Word):** ব্যাকগ্রাউন্ডে "Hey Aura" বা "অরা" শুনলেই সাথে সাথে জেগে উঠবে।
* 🔄 **Continuous Learning / Training (Memory System):** 
  * সরাসরি ফোনে ভারী ব্যাকপ্রোপাগেশন ছাড়া ফোনে ক্ষতিকর গরম না করে এটি **Persistent Memory Engine (SQLite)** দিয়ে কাজ করে।
  * আপনি যখনই বলবেন: *"আমার নাম রাসেল"*, *"আমি গেম খেলতে পছন্দ করি"*, *"মনে রাখবা কাল সকালে আমার কাজ আছে"* — অরা নিজে থেকেই এগুলো মেমোরিতে সেভ করে রাখবে এবং পরবর্তী উত্তরে মনে রেখে কথা বলবে!
* 🗣️ **Offline Speech-to-Text & Text-to-Speech:** বাংলা ও ইংরেজি উভয় ভাষায় কথা বলতে ও শুনতে পারে।
* 🔋 **ASUS ROG 7 Optimized:** ব্যাকগ্রাউন্ড Foreground Service এবং WakeLock ম্যানেজমেন্ট যুক্ত।

---

## 🚀 GitHub Actions দিয়ে ১-ক্লিকে APK বিল্ড করার উপায়

এই রিপোজিটরিতে ইতিমধ্যে **GitHub Actions Workflow** যোগ করা আছে (`.github/workflows/build.yml`)। 

### পদক্ষেপ:
1. এই পুরো ফোল্ডারটি একটি নতুন GitHub রিপোজিটরিতে পুশ করুন:
   ```bash
   git init
   git add .
   git commit -m "Initial commit of Aura Voice AI"
   git branch -M main
   git remote add origin https://github.com/<your-username>/AuraVoiceAI.git
   git push -u origin main
   ```
2. GitHub-এ পুশ হওয়ার সাথে সাথে **Actions** ট্যাবে স্বয়ংক্রিয়ভাবে APK বিল্ড শুরু হবে।
3. বিল্ড শেষ হলে **Artifacts** সেকশন থেকে সরাসরি `AuraVoice-Debug-APK.zip` ডাউনলোড করে ফোনে ইনস্টল করে নিন!

---

## 📂 প্রজেক্ট স্ট্রাকচার (Architecture)

```
AuraVoiceAI/
├── .github/workflows/build.yml      # অটোমেটিক ক্লাউড APK বিল্ডার
├── app/
│   ├── src/main/
│   │   ├── AndroidManifest.xml      # Foreground Service & Mic পারমিশন
│   │   └── java/com/auravoice/assistant/
│   │       ├── MainActivity.kt      # Jetpack Compose UI ও কন্ট্রোলার
│   │       ├── service/
│   │       │   ├── VoiceAssistantForegroundService.kt  # সবসময় ব্যাকগ্রাউন্ডে শোনার ইঞ্জিন
│   │       │   └── BootReceiver.kt                     # ফোন রিবুট হলেও চালু থাকা
│   │       ├── audio/
│   │       │   ├── AudioRecordManager.kt               # মাইক্রোফোন বাফার ও রিয়েলটাইম অ্যাম্প্লিটিউড
│   │       │   ├── WakeWordDetector.kt                 # "Hey Aura" / "অরা" ডিটেক্টর
│   │       │   ├── SpeechToTextEngine.kt               # অফলাইন স্পিচ রিকগনিশন (বাংলা ও ইংরেজি)
│   │       │   └── TextToSpeechEngine.kt               # অফলাইন স্পিচ আউটপুট
│   │       ├── brain/
│   │       │   ├── LlamaEngine.kt                      # অন-ডিভাইস LLM ইনফারেন্স
│   │       │   └── MemoryManager.kt                    # অটোমেটিক লার্নিং ও রিয়েলটাইম মেমোরি
│   │       ├── data/
│   │       │   ├── AppDatabase.kt                      # SQLite Room ডাটাবেজ
│   │       │   └── MemoryEntity.kt                     # অর্জিত তথ্যের স্কিমা
│   │       └── ui/
│   │           ├── VoiceAssistantScreen.kt             # হোম স্ক্রিন ও লাইভ ভয়েস ট্রান্সক্রিপ্ট
│   │           ├── MemoryViewerScreen.kt               # শেখা তথ্য দেখা ও ডিলিট করার স্ক্রিন
│   │           └── components/GlowingMicOrb.kt         # ফিউচারিস্টিক নিয়ন অর্র্ব
```

---

## 📱 ASUS ROG 7 ব্যাকগ্রাউন্ড অপটিমাইজেশন সেটিংস

অ্যান্ড্রয়েড যেন ব্যাকগ্রাউন্ডে অরা-কে বন্ধ না করে দেয়:
1. **ASUS Mobile Manager / Armoury Crate** ওপেন করুন।
2. **Auto-start Manager** এ যান এবং `Aura AI` এনাবল করুন।
3. অ্যাপের অ্যাপ ইনফো (App Info) তে যান -> **Battery** -> **Unrestricted** সিলেক্ট করুন।
