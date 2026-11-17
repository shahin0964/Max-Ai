package com.auravoice.assistant.audio

import android.content.Context
import android.content.SharedPreferences
import com.auravoice.assistant.util.AppLogger
import java.util.Locale

data class AssistantIdentity(
    val assistantName: String = "Aura",
    val assistantTitle: String = "Personal AI Assistant",
    val primaryWakeWord: String = "Hey Aura",
    val userCallsign: String = "স্যার",
    val additionalWakeWords: List<String> = listOf("অরা", "শোনো", "হেই অরা", "শুনছো", "ম্যাক্স", "জার্ভিস")
)

/**
 * AssistantIdentityManager:
 * Manages assistant name, custom wake word, and user callsign settings.
 * Persists changes to SharedPreferences so the user has 100% control over the assistant's name and triggers.
 */
class AssistantIdentityManager(context: Context) {

    private val tag = "AssistantIdentityManager"
    private val prefs: SharedPreferences = context.getSharedPreferences("aura_identity_prefs", Context.MODE_PRIVATE)

    companion object {
        private const val KEY_NAME = "assistant_name"
        private const val KEY_TITLE = "assistant_title"
        private const val KEY_WAKE_WORD = "primary_wake_word"
        private const val KEY_CALLSIGN = "user_callsign"
        private const val KEY_EXTRA_WAKE_WORDS = "extra_wake_words"
    }

    fun getIdentity(): AssistantIdentity {
        val name = prefs.getString(KEY_NAME, "Aura") ?: "Aura"
        val title = prefs.getString(KEY_TITLE, "Personal AI Assistant") ?: "Personal AI Assistant"
        val wakeWord = prefs.getString(KEY_WAKE_WORD, "Hey Aura") ?: "Hey Aura"
        val callsign = prefs.getString(KEY_CALLSIGN, "স্যার") ?: "স্যার"
        val extraWordsStr = prefs.getString(KEY_EXTRA_WAKE_WORDS, "অরা,শোনো,হেই অরা,শুনছো,ম্যাক্স,জার্ভিস") ?: ""
        val extraWords = extraWordsStr.split(",").map { it.trim() }.filter { it.isNotBlank() }

        return AssistantIdentity(
            assistantName = name,
            assistantTitle = title,
            primaryWakeWord = wakeWord,
            userCallsign = callsign,
            additionalWakeWords = extraWords
        )
    }

    fun updateIdentity(
        name: String,
        wakeWord: String,
        userCallsign: String,
        title: String = "Personal AI Assistant"
    ) {
        val cleanName = name.trim().ifBlank { "Aura" }
        val cleanWakeWord = wakeWord.trim().ifBlank { "Hey $cleanName" }
        val cleanCallsign = userCallsign.trim().ifBlank { "স্যার" }

        prefs.edit()
            .putString(KEY_NAME, cleanName)
            .putString(KEY_WAKE_WORD, cleanWakeWord)
            .putString(KEY_CALLSIGN, cleanCallsign)
            .putString(KEY_TITLE, title.trim())
            .apply()

        AppLogger.i(tag, "Updated identity: Name='$cleanName', WakeWord='$cleanWakeWord', Callsign='$cleanCallsign'")
    }

    /**
     * Gathers all active wake words for matching.
     */
    fun getAllWakeWords(): List<String> {
        val identity = getIdentity()
        val set = mutableSetOf<String>()
        set.add(identity.primaryWakeWord.lowercase(Locale.ROOT))
        set.add(identity.assistantName.lowercase(Locale.ROOT))
        set.addAll(identity.additionalWakeWords.map { it.lowercase(Locale.ROOT) })

        // Automatically add standard Bengali transliteration of the assistant name
        val nameLower = identity.assistantName.lowercase(Locale.ROOT)
        when (nameLower) {
            "jarvis" -> {
                set.add("জার্ভিস")
                set.add("জারভিস")
                set.add("হেই জার্ভিস")
                set.add("hey jarvis")
            }
            "max" -> {
                set.add("ম্যাক্স")
                set.add("মাক্স")
                set.add("হেই ম্যাক্স")
                set.add("hey max")
            }
            "aura" -> {
                set.add("অরা")
                set.add("ওরা")
                set.add("হেই অরা")
                set.add("hey aura")
            }
            "friday" -> {
                set.add("ফ্রাইডে")
                set.add("hey friday")
            }
        }

        return set.toList()
    }
}
