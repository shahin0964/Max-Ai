package com.auravoice.assistant.audio

import android.util.Log

/**
 * WakeWordDetector:
 * Detects wake keywords like "Hey Aura", "Aura", "অরা", "শোনো"
 * with high efficiency to trigger assistant processing.
 */
class WakeWordDetector(
    private val onWakeWordDetected: () -> Unit
) {
    private val tag = "WakeWordDetector"
    private val wakeWords = listOf(
        "hey aura", "aura", "ora", "অরা", "শোনো", "হেই অরা", "শুনছো"
    )

    /**
     * Checks if transcribed text or keyword buffer contains a wake trigger.
     */
    fun checkWakeWord(text: String): Boolean {
        val lower = text.lowercase().trim()
        for (word in wakeWords) {
            if (lower.contains(word)) {
                Log.d(tag, "Wake word detected: '$word' in '$text'")
                onWakeWordDetected()
                return true
            }
        }
        return false
    }
}
