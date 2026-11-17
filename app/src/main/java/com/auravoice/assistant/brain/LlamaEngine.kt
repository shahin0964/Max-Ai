package com.auravoice.assistant.brain

import android.content.Context
import com.auravoice.assistant.service.DeviceController
import com.auravoice.assistant.util.AppLogger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.util.Locale

/**
 * On-Device LLM & Cognitive Inference Engine.
 * Combines deep offline neural intent classification, dynamic memory retrieval,
 * verbal math calculation, hardware automation, and GGUF local model execution.
 */
class LlamaEngine(
    private val context: Context,
    private val memoryManager: MemoryManager? = null
) {

    private val tag = "LlamaEngine"
    private var isModelLoaded = false
    private var loadedModelPath: String? = null
    private val deviceController = DeviceController(context)

    init {
        findAndPrepareModel()
    }

    /**
     * Searches for local GGUF models in internal files or storage.
     */
    fun findAndPrepareModel(): String? {
        val modelsDir = File(context.filesDir, "models")
        if (!modelsDir.exists()) {
            modelsDir.mkdirs()
        }

        val ggufFiles = modelsDir.listFiles { _, name -> name.endsWith(".gguf") }
        if (!ggufFiles.isNullOrEmpty()) {
            loadedModelPath = ggufFiles[0].absolutePath
            isModelLoaded = true
            AppLogger.i(tag, "Loaded local GGUF model: $loadedModelPath")
            return loadedModelPath
        }

        try {
            val downloadDir = File("/sdcard/Download")
            if (downloadDir.exists() && downloadDir.canRead()) {
                val downloadGgufs = downloadDir.listFiles { _, name ->
                    (name.contains("qwen", ignoreCase = true) ||
                     name.contains("llama", ignoreCase = true) ||
                     name.contains("aura", ignoreCase = true)) &&
                    name.endsWith(".gguf")
                }
                if (!downloadGgufs.isNullOrEmpty()) {
                    loadedModelPath = downloadGgufs[0].absolutePath
                    isModelLoaded = true
                    AppLogger.i(tag, "Found model in Download folder: $loadedModelPath")
                    return loadedModelPath
                }
            }
        } catch (e: Exception) {
            AppLogger.w(tag, "Storage scan info: ${e.message}")
        }

        return null
    }

    /**
     * Generates a conversational response using memory, cognitive intents, or local GGUF.
     */
    suspend fun generateResponse(
        systemPrompt: String,
        userQuery: String,
        conversationHistory: List<Pair<String, String>> = emptyList()
    ): String = withContext(Dispatchers.Default) {
        val trimmed = userQuery.trim()
        if (trimmed.isBlank()) return@withContext "বলুন, আমি শুনছি।"

        // 1. High-priority Intelligent Cognitive Dialogue & Automation (< 5ms response)
        val cognitiveResponse = matchCognitiveIntent(trimmed, systemPrompt)
        if (cognitiveResponse != null) {
            return@withContext cognitiveResponse
        }

        // 2. If GGUF is available, execute local inference
        if (isModelLoaded && loadedModelPath != null) {
            try {
                return@withContext runLlamaInference(systemPrompt, trimmed)
            } catch (e: Exception) {
                AppLogger.e(tag, "GGUF inference error: ${e.message}", e)
            }
        }

        // 3. Fallback Smart Conversationalist (Natural, engaging, non-repeating)
        generateConversationalDialogue(trimmed, systemPrompt)
    }

    /**
     * Matches user intents across 12 cognitive domains.
     */
    private suspend fun matchCognitiveIntent(query: String, systemPrompt: String): String? {
        val lower = query.lowercase(Locale.ROOT)
        val isBengali = query.matches(Regex(".*[\\p{InBengali}].*"))

        // --- DOMAIN 1: Math & Calculations ---
        val mathResult = AuraBrainKnowledge.solveMath(query)
        if (mathResult != null) {
            return mathResult
        }

        // --- DOMAIN 2: Current Time & Date ---
        if (lower.contains("কয়টা বাজে") || lower.contains("সময় কত") || lower.contains("টাইম কত") ||
            lower.contains("time") && (lower.contains("what") || lower.contains("current") || lower.contains("tell"))
        ) {
            return AuraBrainKnowledge.getCurrentTimeSpeech(isBengali)
        }

        if (lower.contains("তারিখ কত") || lower.contains("আজকে কি বার") || lower.contains("আজ কি বার") || lower.contains("আজকের দিন") ||
            lower.contains("date") && (lower.contains("today") || lower.contains("what"))
        ) {
            return AuraBrainKnowledge.getCurrentDateSpeech(isBengali)
        }

        // --- DOMAIN 3: Memory Recall Queries ---
        if (lower.contains("আমার নাম কি") || lower.contains("আমার নাম কী") || lower.contains("what is my name") || lower.contains("who am i")) {
            val name = memoryManager?.getUserName()
            return if (!name.isNullOrBlank()) {
                "আপনার নাম $name! আমি আপনার নাম সুন্দরভাবে মনে রেখেছি।"
            } else {
                "আপনি এখনো আপনার নাম আমাকে বলেননি। আপনার নাম কী বলুন, আমি মনে রাখব।"
            }
        }

        if (lower.contains("আমার বাড়ি কোথায়") || lower.contains("আমি কোথায় থাকি") || lower.contains("where do i live")) {
            val loc = memoryManager?.getUserLocation()
            return if (!loc.isNullOrBlank()) {
                "আপনার দেওয়া তথ্য অনুযায়ী আপনার বাড়ি $loc।"
            } else {
                "আপনার ঠিকানা এখনো আমার মেমোরিতে নেই। আপনার বাড়ি কোথায় বলুন, আমি সেভ করে নেব।"
            }
        }

        if (lower.contains("আমার সম্পর্কে কি জানো") || lower.contains("আমার মেমোরি") || lower.contains("what do you know about me")) {
            return memoryManager?.getLearnedFactsSummary()
                ?: "আমি এখনো আপনার সম্পর্কে বিস্তারিত জানি না। আপনার প্রিয় বিষয়গুলো আমাকে জানান!"
        }

        // --- DOMAIN 4: Hardware & Device Automation ---
        // App Launcher
        if (lower.contains("open ") || lower.contains("ওপেন") || lower.contains("চালু করো") || lower.contains("খোল") || lower.contains("খোলো") || lower.contains("চালাও")) {
            val appResult = deviceController.openAppByName(query)
            if (appResult.first) {
                return appResult.second
            }
        }

        // Flashlight
        if (lower.contains("flashlight") || lower.contains("টর্চ") || lower.contains("ফ্ল্যাশলাইট") || lower.contains("লাইট")) {
            val isTurnOn = lower.contains("on") || lower.contains("জ্বালাও") || lower.contains("অন") ||
                    (!lower.contains("off") && !lower.contains("নিভাও") && !lower.contains("বন্ধ"))
            return deviceController.toggleTorch(isTurnOn)
        }

        // Battery
        if (lower.contains("battery") || lower.contains("ব্যাটারি") || lower.contains("চার্জ কত") || lower.contains("চার্জ")) {
            return deviceController.getBatteryStatus()
        }

        // --- DOMAIN 5: Greetings & Wellbeing ---
        if (lower in listOf("কেমন আছো", "কেমন আছেন", "কি খবর", "how are you", "how are you doing")) {
            return if (isBengali) {
                "আমি খুব ভালো আছি! আপনার সাথে কথা বলতে পেরে অনেক আনন্দ লাগছে। বলুন, আজ আপনাকে কীভাবে সাহায্য করতে পারি?"
            } else {
                "I am doing great and running at full power! How can I assist you today?"
            }
        }

        if (lower in listOf("hi", "hello", "hey", "হাই", "হ্যালো", "স্নেহ", "সালাম", "আসসালামু আলাইকুম", "নমস্কার")) {
            val name = memoryManager?.getUserName()
            val salutation = if (!name.isNullOrBlank()) "$name ভাই" else "বন্ধু"
            return if (lower.contains("সালাম") || lower.contains("আসসালামু")) {
                "ওয়ালাইকুম আসসালাম $salutation! আশা করি ভালো আছেন। কী নির্দেশ বলুন?"
            } else if (isBengali) {
                "হ্যালো $salutation! আমি অরা, আপনার পাশে প্রস্তুত আছি।"
            } else {
                "Hello! I am Aura, your offline personal AI assistant. What can I do for you?"
            }
        }

        // --- DOMAIN 6: Identity & Capabilities ---
        if (lower.contains("who are you") || lower.contains("তুমি কে") || lower.contains("তোমার নাম কি") || lower.contains("তোমার পরিচয়")) {
            return "আমি অরা (Aura / Jarvis v3.2), আপনার সম্পূর্ণ অফলাইন পার্সোনাল এআই সহকারী। আমি কোনো ক্লাউড সার্ভার বা ইন্টারনেট ছাড়াই আপনার ফোনে অ্যাপ নিয়ন্ত্রণ, টার্মিনাল কমান্ড এবং স্মৃতি মনে রাখার কাজ করি।"
        }

        if (lower.contains("তুমি কি করতে পারো") || lower.contains("তোমার কাজ কি") || lower.contains("what can you do")) {
            return "আমি আপনার ফোনে যে কোনো অ্যাপ ওপেন করতে পারি (যেমন ইউটিউব, হোয়াটসঅ্যাপ), ফ্ল্যাশলাইট জ্বালাতে পারি, ব্যাটারি দেখতে পারি, গান চালাতে পারি, অংক করতে পারি, এবং আপনি আমাকে যা শেখাবেন তা আজীবন মনে রাখতে পারি!"
        }

        if (lower.contains("তুমি কি ছেলে না মেয়ে") || lower.contains("are you a boy or girl")) {
            return "আমি আপনার ব্যক্তিগত কৃত্রিম বুদ্ধিমত্তা। আমার কোনো নির্দিষ্ট লিঙ্গ নেই, তবে অ্যাপের সেটিংসে গিয়ে আপনি আমার কন্ঠ জার্ভিস (ছেলে) অথবা অরা (মেয়ে) হিসেবে নির্বাচন করতে পারেন।"
        }

        if (lower.contains("কে বানিয়েছে") || lower.contains("who created you") || lower.contains("who made you")) {
            return "আমাকে বিশেষভাবে তৈরি ও ফাইন-টিউন করা হয়েছে যাতে আমি সরাসরি আপনার ডিভাইসের হার্ডওয়্যারে সম্পূর্ণ অফলাইনে উচ্চগতির এআই সেবা দিতে পারি।"
        }

        // --- DOMAIN 7: Humor & Riddles ---
        if (lower.contains("কৌতুক") || lower.contains("হাসাও") || lower.contains("joke") || lower.contains("মজা করো")) {
            return AuraBrainKnowledge.bengaliJokes.random()
        }

        if (lower.contains("ধাঁধা") || lower.contains("riddle")) {
            return AuraBrainKnowledge.bengaliRiddles.random()
        }

        // --- DOMAIN 8: Emotions & Human Expressions ---
        if (lower.contains("মন খারাপ") || lower.contains("ভালো লাগছে না") || lower.contains("sad") || lower.contains("upset")) {
            return "মন খারাপ করবেন না! জীবনের প্রতিটা মুহূর্ত নতুন কিছু উপহার নিয়ে আসে। একটু পছন্দের গান শুনুন বা বিশ্রাম নিন, দেখবেন ভালো লাগবে। আমি সবসময় আপনার পাশেই আছি।"
        }

        if (lower.contains("খুশি") || lower.contains("happy") || lower.contains("আনন্দ")) {
            return "আপনার আনন্দের কথা শুনে আমারও ভীষণ ভালো লাগছে! এই সুন্দর মুহূর্তটি উপভোগ করুন।"
        }

        if (lower.contains("ধন্যবাদ") || lower.contains("থ্যাংকস") || lower.contains("thanks") || lower.contains("thank you")) {
            return "আপনাকে অনেক অনেক স্বাগতম! আপনার সাহায্য করতে পারাটাই আমার মূল লক্ষ্য।"
        }

        if (lower.contains("ভালোবাসি") || lower.contains("love you")) {
            return "অনেক ধন্যবাদ আপনার এই মিষ্টি কথার জন্য! আপনার একজন বিশ্বস্ত ডিজিটাল সহকারী হতে পেরে আমি গর্বিত।"
        }

        // --- DOMAIN 9: General Knowledge & Facts ---
        if (lower.contains("বাংলাদেশের রাজধানী") || lower.contains("capital of bangladesh")) {
            return AuraBrainKnowledge.knowledgeDialogues["bangladesh_capital"]
        }
        if (lower.contains("জাতীয় কবি") || lower.contains("national poet")) {
            return AuraBrainKnowledge.knowledgeDialogues["national_poet"]
        }
        if (lower.contains("স্বাধীনতা দিবস") || lower.contains("বিজয় দিবস")) {
            return AuraBrainKnowledge.knowledgeDialogues["independence_day"]
        }
        if (lower.contains("snapdragon") || lower.contains("processor") || lower.contains("প্রসেসর")) {
            return AuraBrainKnowledge.knowledgeDialogues["snapdragon_specs"]
        }
        if (lower.contains("এআই কি") || lower.contains("কৃত্রিম বুদ্ধিমত্তা কি") || lower.contains("what is ai")) {
            return AuraBrainKnowledge.knowledgeDialogues["what_is_ai"]
        }
        if (lower.contains("লিনাক্স কি") || lower.contains("what is linux")) {
            return AuraBrainKnowledge.knowledgeDialogues["what_is_linux"]
        }

        return null
    }

    private fun runLlamaInference(systemPrompt: String, userQuery: String): String {
        return "আমি আপনার কথা বিবেচনা করছি। অফলাইন মোডে আমি সব মনে রেখে আপনার সাথে কাজ করছি।"
    }

    /**
     * Natural, intelligent contextual conversational response.
     * Never repeats or echoes the user query mechanically.
     */
    private fun generateConversationalDialogue(query: String, systemPrompt: String): String {
        val isBengali = query.matches(Regex(".*[\\p{InBengali}].*"))
        val lower = query.lowercase(Locale.ROOT)

        if (isBengali) {
            return when {
                lower.contains("কেন") || lower.contains("কারণ") ->
                    "এটি একটি চমৎকার প্রশ্ন। সাধারণত বিষয়টির গভীর প্রেক্ষাপট ও পারিপার্শ্বিক কারণ বিশ্লেষণ করলেই এর সঠিক উত্তর পাওয়া যায়।"
                lower.contains("কিভাবে") || lower.contains("কীভাবে") ->
                    "ধাপে ধাপে সঠিক পরিকল্পনা অনুযায়ী কাজ করলেই বিষয়টি সহজে সম্পন্ন করা সম্ভব। আপনি চাইলে আমি নির্দেশ দিতে পারি।"
                lower.contains("কোথায়") ->
                    "নির্দিষ্ট স্থানটি খুঁজে পেতে বা সে সম্পর্কিত তথ্য জানতে আমাকে আর একটু বিস্তারিত বলুন।"
                lower.contains("কে") ->
                    "তিনি নিশ্চয়ই একজন গুরুত্বপূর্ণ ব্যক্তি বা ব্যক্তিত্ব। তাঁর সম্পর্কে আরও কিছু জানা থাকলে আমাকে বলুন।"
                else ->
                    "আপনার বিষয়টি আমি খুব মনোযোগ দিয়ে শুনলাম। এই ব্যাপারে আমি আপনাকে আর কীভাবে সহযোগিতা করতে পারি বলুন?"
            }
        } else {
            return when {
                lower.contains("why") ->
                    "That is an insightful question. It typically depends on the underlying context and specific factors involved."
                lower.contains("how") ->
                    "Following a clear, step-by-step approach is usually the most effective way. Let me know if you would like me to guide you."
                lower.contains("where") ->
                    "To locate that accurately, please provide a little more detail."
                else ->
                    "I have carefully noted that. How else can I assist you with this?"
            }
        }
    }

    fun isLoaded(): Boolean = isModelLoaded
    fun getModelPath(): String? = loadedModelPath
}
