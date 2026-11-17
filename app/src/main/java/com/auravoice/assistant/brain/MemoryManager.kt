package com.auravoice.assistant.brain

import com.auravoice.assistant.data.AppDatabase
import com.auravoice.assistant.data.MemoryEntity
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.regex.Pattern

/**
 * Continuous Learning & Memory Manager:
 * Automatically learns facts from user speech and injects them
 * into the AI prompt so Aura gets smarter over time.
 */
class MemoryManager(private val database: AppDatabase) {

    private val memoryDao = database.memoryDao()

    /**
     * Build system prompt with all learned facts about the user.
     */
    suspend fun buildSystemPrompt(userQuery: String): String = withContext(Dispatchers.IO) {
        // Fetch top recent memories
        val allMemories = memoryDao.getRecentMemories(limit = 15)

        val memoryBuilder = StringBuilder()
        if (allMemories.isNotEmpty()) {
            memoryBuilder.append("\n[Learned Facts & Memory About User]:\n")
            for (mem in allMemories) {
                memoryBuilder.append("- ").append(mem.fact).append("\n")
            }
        }

        """
        You are Aura, an offline personal AI voice assistant running locally on the user's phone.
        You are friendly, concise, and helpful.
        $memoryBuilder
        Instructions:
        1. Always answer concisely and naturally in spoken conversational style (1-3 sentences max).
        2. If the user speaks in Bengali, reply in natural Bengali. If they speak in English, reply in English.
        3. Never ask for an internet connection or API key. You are completely local and private.
        4. Refer to learned facts whenever relevant.
        """.trimIndent()
    }

    /**
     * Inspect user input and assistant response to extract and learn new facts.
     */
    suspend fun learnFromConversation(userInput: String, assistantResponse: String) = withContext(Dispatchers.IO) {
        val trimmed = userInput.trim()

        // 1. Bengali Name learning: "আমার নাম <নাম>"
        val namePatternBn = Pattern.compile("আমার\\s+নাম\\s+([\\p{L}]+)", Pattern.CASE_INSENSITIVE)
        val nameMatcherBn = namePatternBn.matcher(trimmed)
        if (nameMatcherBn.find()) {
            val name = nameMatcherBn.group(1)
            saveFact("PROFILE", "ব্যবহারকারীর নাম: $name")
        }

        // English Name learning: "My name is <name>"
        val namePatternEn = Pattern.compile("my\\s+name\\s+is\\s+([a-zA-Z]+)", Pattern.CASE_INSENSITIVE)
        val nameMatcherEn = namePatternEn.matcher(trimmed)
        if (nameMatcherEn.find()) {
            val name = nameMatcherEn.group(1)
            saveFact("PROFILE", "User's name is $name")
        }

        // 2. Explicit Remember instructions: "মনে রাখবা <তথ্য>", "মনে রাখো <তথ্য>", "remember that <fact>"
        val rememberBn = Pattern.compile("মনে\\s+(?:রাখবা|রাখো|রেখো)\\s+(.+)", Pattern.CASE_INSENSITIVE)
        val remMatcherBn = rememberBn.matcher(trimmed)
        if (remMatcherBn.find()) {
            val fact = remMatcherBn.group(1)
            saveFact("NOTE", fact ?: "")
        }

        val rememberEn = Pattern.compile("remember\\s+(?:that\\s+)?(.+)", Pattern.CASE_INSENSITIVE)
        val remMatcherEn = rememberEn.matcher(trimmed)
        if (remMatcherEn.find()) {
            val fact = remMatcherEn.group(1)
            saveFact("NOTE", fact ?: "")
        }

        // 3. Likes/Preferences: "আমি <জিনিস> পছন্দ করি", "আমি <জিনিস> ভালোবাসি", "I like/love <thing>"
        val likeBn = Pattern.compile("আমি\\s+(.+?)\\s+(?:পছন্দ করি|ভালোবাসি)", Pattern.CASE_INSENSITIVE)
        val likeMatcherBn = likeBn.matcher(trimmed)
        if (likeMatcherBn.find()) {
            val item = likeMatcherBn.group(1)
            saveFact("PREFERENCE", "ব্যবহারকারী পছন্দ করেন: $item")
        }

        val likeEn = Pattern.compile("i\\s+(?:like|love|prefer)\\s+(.+)", Pattern.CASE_INSENSITIVE)
        val likeMatcherEn = likeEn.matcher(trimmed)
        if (likeMatcherEn.find()) {
            val item = likeMatcherEn.group(1)
            saveFact("PREFERENCE", "User likes: $item")
        }

        // 4. Phone/Device: "আমার ফোন <মডেল>", "I have a <phone>"
        val deviceBn = Pattern.compile("আমার\\s+(?:ফোন|মোবাইল)\\s+(.+)", Pattern.CASE_INSENSITIVE)
        val devMatcherBn = deviceBn.matcher(trimmed)
        if (devMatcherBn.find()) {
            val dev = devMatcherBn.group(1)
            saveFact("DEVICE", "ব্যবহারকারীর ফোন: $dev")
        }
    }

    private suspend fun saveFact(category: String, fact: String) {
        val cleanFact = fact.trim()
        if (cleanFact.isNotBlank() && cleanFact.length > 2) {
            // Avoid duplicate facts
            val existing = memoryDao.searchMemories(cleanFact)
            if (existing.isEmpty()) {
                memoryDao.insertMemory(
                    MemoryEntity(
                        category = category,
                        fact = cleanFact,
                        confidence = 1.0f
                    )
                )
            }
        }
    }
}
