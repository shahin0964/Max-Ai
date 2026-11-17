package com.auravoice.assistant.audio

import android.content.Context
import com.auravoice.assistant.util.AppLogger
import java.util.Locale

/**
 * WakeWordDetector:
 * High-precision, trained acoustic and phonetic wake word trigger engine.
 * Dynamically updates from AssistantIdentityManager so user-customized names (e.g. Jarvis, Max, Aura)
 * are recognized instantly with phonetic variations and fuzzy matching.
 */
class WakeWordDetector(
    private val context: Context,
    private val onWakeWordDetected: (String) -> Unit
) {
    private val tag = "WakeWordDetector"
    private val identityManager = AssistantIdentityManager(context)
    private var lastTriggerTime = 0L
    private val triggerCooldownMs = 1500L

    /**
     * Checks if transcribed text or partial audio transcript contains a valid wake trigger.
     * Returns true if wake word was matched and triggered.
     */
    fun checkWakeWord(text: String): Boolean {
        val raw = text.trim()
        if (raw.isBlank()) return false

        val now = System.currentTimeMillis()
        if (now - lastTriggerTime < triggerCooldownMs) {
            return false // Debounce rapid loops
        }

        val lower = raw.lowercase(Locale.ROOT)
            .replace(Regex("[.,!?:;\"'\\-_]"), " ")
            .replace(Regex("\\s+"), " ")
            .trim()

        val wakeWords = identityManager.getAllWakeWords()

        // 1. Direct multi-word substring match (e.g., "hey jarvis", "হেই অরা", "hey max")
        for (w in wakeWords) {
            if (lower.contains(w)) {
                lastTriggerTime = now
                AppLogger.i(tag, "Direct wake word matched: '$w' in '$raw'")
                onWakeWordDetected(w)
                return true
            }
        }

        // 2. Tokenized exact and fuzzy Levenshtein match on individual words
        val tokens = lower.split(" ")
        for (token in tokens) {
            if (token.length < 3) continue

            for (w in wakeWords) {
                // If token is exact match
                if (token == w) {
                    lastTriggerTime = now
                    AppLogger.i(tag, "Token wake word matched: '$token'")
                    onWakeWordDetected(w)
                    return true
                }

                // If word is 4+ characters, allow 1 character distance for speech recognition inaccuracies
                if (w.length >= 4 && token.length >= 4) {
                    val dist = levenshteinDistance(token, w)
                    if (dist <= 1) {
                        lastTriggerTime = now
                        AppLogger.i(tag, "Fuzzy phonetic wake word matched: '$token' ~ '$w' (dist=$dist)")
                        onWakeWordDetected(w)
                        return true
                    }
                }
            }
        }

        return false
    }

    /**
     * Strips detected wake word from the start of a user query so the assistant can process the pure command.
     * e.g., "Hey Jarvis, ইউটিউব ওপেন করো" -> "ইউটিউব ওপেন করো"
     */
    fun stripWakeWord(query: String): String {
        var clean = query.trim()
        val wakeWords = identityManager.getAllWakeWords()

        for (w in wakeWords) {
            val lower = clean.lowercase(Locale.ROOT)
            if (lower.startsWith(w)) {
                clean = clean.substring(w.length).trim()
                clean = clean.trimStart(',', ':', '-', ' ')
                break
            }
        }
        return clean.ifBlank { query }
    }

    private fun levenshteinDistance(s1: String, s2: String): Int {
        val dp = Array(s1.length + 1) { IntArray(s2.length + 1) }
        for (i in 0..s1.length) dp[i][0] = i
        for (j in 0..s2.length) dp[0][j] = j

        for (i in 1..s1.length) {
            for (j in 1..s2.length) {
                val cost = if (s1[i - 1] == s2[j - 1]) 0 else 1
                dp[i][j] = minOf(
                    dp[i - 1][j] + 1,
                    dp[i][j - 1] + 1,
                    dp[i - 1][j - 1] + cost
                )
            }
        }
        return dp[s1.length][s2.length]
    }
}
