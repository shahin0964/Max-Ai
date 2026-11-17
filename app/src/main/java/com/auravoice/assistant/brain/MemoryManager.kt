package com.auravoice.assistant.brain

import com.auravoice.assistant.data.AppDatabase
import com.auravoice.assistant.data.MemoryEntity
import com.auravoice.assistant.util.AppLogger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.regex.Pattern

/**
 * Continuous Learning & Memory Manager:
 * Automatically extracts complete, unclipped facts from user speech and injects them
 * into the AI prompt and direct answers so Aura continuously learns and remembers everything.
 */
class MemoryManager(private val database: AppDatabase) {

    private val tag = "MemoryManager"
    private val memoryDao = database.memoryDao()

    /**
     * Build system prompt with all learned facts about the user.
     */
    suspend fun buildSystemPrompt(userQuery: String): String = withContext(Dispatchers.IO) {
        val allMemories = memoryDao.getRecentMemories(limit = 20)

        val memoryBuilder = StringBuilder()
        if (allMemories.isNotEmpty()) {
            memoryBuilder.append("\n[Learned Facts & Memory About User]:\n")
            for (mem in allMemories) {
                memoryBuilder.append("- ").append(mem.fact).append("\n")
            }
        }

        """
        You are Aura, an offline personal AI voice assistant running locally on the user's phone.
        You are intelligent, witty, concise, and helpful.
        $memoryBuilder
        Instructions:
        1. Always answer concisely and naturally in spoken conversational style (1-3 sentences max).
        2. If the user speaks in Bengali, reply in natural Bengali. If they speak in English, reply in English.
        3. Never ask for an internet connection or API key. You are completely local and private.
        4. Refer to learned facts whenever relevant.
        """.trimIndent()
    }

    /**
     * Inspect user input to extract and learn new facts completely and cleanly.
     * Returns a confirmation message if a major fact was learned, or null.
     */
    suspend fun learnFromConversation(userInput: String, assistantResponse: String): String? = withContext(Dispatchers.IO) {
        val raw = userInput.trim()
        if (raw.length < 3) return@withContext null

        var learnedFeedback: String? = null

        // 1. Bengali Name learning (Complete full name extraction)
        // Matches "আমার নাম রাসেল আহমেদ", "আমার নাম মোঃ রাসেল", etc.
        val namePatternBn = Pattern.compile("(?:আমার\\s+নাম|আমি)\\s+([\\p{L}\\s.]{2,35})", Pattern.CASE_INSENSITIVE)
        val nameMatcherBn = namePatternBn.matcher(raw)
        if (nameMatcherBn.find()) {
            var extracted = nameMatcherBn.group(1)?.trim() ?: ""
            extracted = cleanTrailingKeywords(extracted)
            if (isValidName(extracted)) {
                saveFact("PROFILE", "ব্যবহারকারীর নাম: $extracted")
                learnedFeedback = "$extracted ভাই, আপনার নাম আমি সুন্দরভাবে মনে রেখেছি!"
            }
        }

        // English Name learning: "My name is <full name>", "I am <name>"
        val namePatternEn = Pattern.compile("(?:my\\s+name\\s+is|i\\s+am)\\s+([a-zA-Z\\s.]{2,35})", Pattern.CASE_INSENSITIVE)
        val nameMatcherEn = namePatternEn.matcher(raw)
        if (nameMatcherEn.find()) {
            var extracted = nameMatcherEn.group(1)?.trim() ?: ""
            extracted = cleanTrailingKeywords(extracted)
            if (isValidName(extracted)) {
                saveFact("PROFILE", "User's name is $extracted")
                learnedFeedback = "Nice to meet you, $extracted! I will remember your name."
            }
        }

        // 2. Home / Address / City learning
        // "আমার বাড়ি ঢাকা", "আমার বাসা চট্টগ্রাম", "আমি খুলনায় থাকি"
        val homePatternBn = Pattern.compile("আমার\\s+(?:বাড়ি|বাসা|ঠিকানা)\\s+([\\p{L}\\s]{2,30})|আমি\\s+([\\p{L}\\s]{2,25})-(?:এ|তে)\\s+থাকি", Pattern.CASE_INSENSITIVE)
        val homeMatcherBn = homePatternBn.matcher(raw)
        if (homeMatcherBn.find()) {
            val place = cleanTrailingKeywords(homeMatcherBn.group(1) ?: homeMatcherBn.group(2) ?: "")
            if (place.isNotBlank() && place.length >= 2) {
                saveFact("LOCATION", "ব্যবহারকারীর ঠিকানা: $place")
                if (learnedFeedback == null) {
                    learnedFeedback = "আপনার ঠিকানা $place, এটা আমি মনে রাখলাম।"
                }
            }
        }

        // 3. Explicit Remember instructions:
        // Handles both prefix and suffix:
        // "মনে রাখবা <তথ্য>", "মনে রাখো <তথ্য>" OR "<তথ্য>, মনে রাখবা", "<তথ্য> এটা মনে রেখো"
        val rememberPrefix = Pattern.compile("মনে\\s*(?:রাখবা|রাখো|রেখো|রাখিস)\\s*[,:]?\\s*(.+)", Pattern.CASE_INSENSITIVE)
        val prefMatcher = rememberPrefix.matcher(raw)
        if (prefMatcher.find()) {
            val fact = cleanTrailingKeywords(prefMatcher.group(1)?.trim() ?: "")
            if (fact.length > 3) {
                saveFact("NOTE", fact)
                if (learnedFeedback == null) {
                    learnedFeedback = "অবশ্যই মনে রাখব: \"$fact\"।"
                }
            }
        } else {
            // Check suffix: "<fact> (এটা)? মনে (রাখবা|রাখো|রেখো)"
            val rememberSuffix = Pattern.compile("(.+?)(?:,|\\s+)?(?:এটা\\s+)?মনে\\s*(?:রাখবা|রাখো|রেখো|রাখিস)", Pattern.CASE_INSENSITIVE)
            val suffMatcher = rememberSuffix.matcher(raw)
            if (suffMatcher.find()) {
                val fact = suffMatcher.group(1)?.trim() ?: ""
                if (fact.length > 3 && !fact.contains("আমার নাম")) {
                    saveFact("NOTE", fact)
                    if (learnedFeedback == null) {
                        learnedFeedback = "আমি এটি মনে রাখলাম: \"$fact\"।"
                    }
                }
            }
        }

        // 4. Preferences & Favorites
        // "আমার প্রিয় খাবার বিরিয়ানি", "আমি কফি পছন্দ করি", "আমি গান শুনতে ভালোবাসি"
        val favPattern = Pattern.compile("আমার\\s+প্রিয়\\s+([\\p{L}\\s]{2,20})\\s*(?:হলো|হচ্ছে|হল)?\\s*([\\p{L}\\s]{2,30})", Pattern.CASE_INSENSITIVE)
        val favMatcher = favPattern.matcher(raw)
        if (favMatcher.find()) {
            val item = favMatcher.group(1)?.trim() ?: ""
            val pref = cleanTrailingKeywords(favMatcher.group(2)?.trim() ?: "")
            if (item.isNotBlank() && pref.isNotBlank()) {
                saveFact("PREFERENCE", "ব্যবহারকারীর প্রিয় $item: $pref")
                if (learnedFeedback == null) {
                    learnedFeedback = "আপনার প্রিয় $item $pref, এটা আমি নোট করে রাখলাম।"
                }
            }
        } else {
            val likePattern = Pattern.compile("আমি\\s+([\\p{L}\\s]{2,30})\\s+(?:পছন্দ করি|ভালোবাসি)", Pattern.CASE_INSENSITIVE)
            val likeMatcher = likePattern.matcher(raw)
            if (likeMatcher.find()) {
                val likedItem = cleanTrailingKeywords(likeMatcher.group(1)?.trim() ?: "")
                if (likedItem.isNotBlank() && likedItem.length >= 2) {
                    saveFact("PREFERENCE", "ব্যবহারকারী পছন্দ করেন: $likedItem")
                    if (learnedFeedback == null) {
                        learnedFeedback = "$likedItem আপনার পছন্দ, মনে রাখা হলো!"
                    }
                }
            }
        }

        // 5. Phone / Device Details
        val devPattern = Pattern.compile("আমার\\s+(?:ফোন|মোবাইল)\\s+([\\p{L}0-9\\s]{2,30})", Pattern.CASE_INSENSITIVE)
        val devMatcher = devPattern.matcher(raw)
        if (devMatcher.find()) {
            val dev = cleanTrailingKeywords(devMatcher.group(1)?.trim() ?: "")
            if (dev.isNotBlank()) {
                saveFact("DEVICE", "ব্যবহারকারীর ফোন: $dev")
            }
        }

        learnedFeedback
    }

    /**
     * Helper to clean trailing conversational fillers that otherwise corrupt memories.
     */
    private fun cleanTrailingKeywords(input: String): String {
        var str = input.trim()
        val removePhrases = listOf(
            ", মনে রাখবা", " মনে রাখবা",
            ", মনে রাখো", " মনে রাখো",
            ", মনে রেখো", " মনে রেখো",
            ", এটা মনে রাখবা", " এটা মনে রাখবা",
            ", এটা মনে রেখো", " এটা মনে রেখো",
            " মনে রাখিস", ", মনে রাখিস",
            " remember this", ", remember this",
            " remember that", ", remember that",
            "ঠিক আছে", "কেমন"
        )
        for (phrase in removePhrases) {
            if (str.endsWith(phrase, ignoreCase = true)) {
                str = str.substring(0, str.length - phrase.length).trim()
            }
        }
        return str.trimEnd(',', '.', '!', '?', ':', ';')
    }

    private fun isValidName(name: String): Boolean {
        val lower = name.lowercase(java.util.Locale.ROOT)
        // Filter out accidental filler words
        val invalidWords = setOf("কি", "কে", "কেমন", "কেমন আছো", "হ্যাঁ", "না", "হুম", "ভালো", "খারাপ", "hello", "hi")
        if (lower in invalidWords || name.length < 2) return false
        return true
    }

    /**
     * Looks up user's learned name from memory database.
     */
    suspend fun getUserName(): String? = withContext(Dispatchers.IO) {
        val memories = memoryDao.getAllMemoriesSync()
        for (m in memories) {
            if (m.category == "PROFILE" && m.fact.contains("ব্যবহারকারীর নাম:")) {
                return@withContext m.fact.substringAfter("ব্যবহারকারীর নাম:").trim()
            }
            if (m.category == "PROFILE" && m.fact.contains("User's name is")) {
                return@withContext m.fact.substringAfter("User's name is").trim()
            }
        }
        null
    }

    /**
     * Looks up user's learned location from memory database.
     */
    suspend fun getUserLocation(): String? = withContext(Dispatchers.IO) {
        val memories = memoryDao.getAllMemoriesSync()
        for (m in memories) {
            if (m.fact.contains("ঠিকানা:") || m.fact.contains("বাসস্থান:")) {
                return@withContext m.fact.substringAfter(":").trim()
            }
        }
        null
    }

    /**
     * Summarizes all learned facts for answering "আমার সম্পর্কে কি জানো?".
     */
    suspend fun getLearnedFactsSummary(): String = withContext(Dispatchers.IO) {
        val memories = memoryDao.getAllMemoriesSync()
        if (memories.isEmpty()) {
            return@withContext "আমি এখনো আপনার সম্পর্কে তেমন কিছু জানি না। আপনি আমাকে আপনার নাম, পছন্দের জিনিস বা যেকোনো বিষয় বলতে পারেন, আমি মনে রাখব।"
        }
        val sb = StringBuilder("আমি আপনার সম্পর্কে যেসব তথ্য মনে রেখেছি:\n")
        for ((idx, m) in memories.take(6).withIndex()) {
            sb.append("${idx + 1}. ").append(m.fact).append("\n")
        }
        sb.toString().trimEnd()
    }

    /**
     * Finds any previously learned web knowledge or facts matching keywords in query.
     */
    suspend fun findLearnedTopic(query: String): String? = withContext(Dispatchers.IO) {
        val keywords = query.split(Regex("[\\s,?.!]+")).filter { it.length > 2 }
        for (kw in keywords) {
            val matches = memoryDao.searchMemories(kw)
            for (m in matches) {
                if (m.category == "WEB_KNOWLEDGE" || m.category == "NOTE") {
                    return@withContext m.fact
                }
            }
        }
        null
    }

    suspend fun saveFact(category: String, fact: String) {
        val cleanFact = fact.trim()
        if (cleanFact.isNotBlank() && cleanFact.length > 2) {
            val existing = memoryDao.searchMemories(cleanFact)
            if (existing.isEmpty()) {
                memoryDao.insertMemory(
                    MemoryEntity(
                        category = category,
                        fact = cleanFact,
                        confidence = 1.0f
                    )
                )
                AppLogger.i(tag, "Learned and saved clean fact: [$category] $cleanFact")
            }
        }
    }
}
