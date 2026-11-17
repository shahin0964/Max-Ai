package com.auravoice.assistant.audio

import android.content.Context
import android.content.SharedPreferences
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.speech.tts.Voice
import android.util.Log
import com.auravoice.assistant.util.AppLogger
import java.util.Locale

enum class VoicePersona(val displayName: String, val pitch: Float, val speed: Float) {
    JARVIS("জার্ভিস (পুরুষ কন্ঠ)", 0.88f, 1.05f),
    AURA("অরা (নারী কন্ঠ)", 1.05f, 1.00f)
}

/**
 * TextToSpeechEngine:
 * Local offline voice synthesis engine.
 * Ensures consistent persona (male or female), natural pacing,
 * and eliminates monotone robotic artifacts by cleaning text and modulating pitch.
 */
class TextToSpeechEngine(
    private val context: Context,
    private val onSpeechStarted: () -> Unit,
    private val onSpeechFinished: () -> Unit
) {
    private val tag = "TextToSpeechEngine"
    private var tts: TextToSpeech? = null
    private var isInitialized = false

    private val prefs: SharedPreferences = context.getSharedPreferences("aura_voice_prefs", Context.MODE_PRIVATE)
    private val bengaliLocale = Locale("bn", "BD")
    private val englishLocale = Locale.US

    private var currentPersona: VoicePersona = VoicePersona.JARVIS

    init {
        val savedPersonaName = prefs.getString("voice_persona", VoicePersona.JARVIS.name)
        currentPersona = try {
            VoicePersona.valueOf(savedPersonaName ?: VoicePersona.JARVIS.name)
        } catch (e: Exception) {
            VoicePersona.JARVIS
        }

        tts = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                isInitialized = true
                applyPersonaSettings()
                tts?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                    override fun onStart(utteranceId: String?) {
                        onSpeechStarted()
                    }

                    override fun onDone(utteranceId: String?) {
                        onSpeechFinished()
                    }

                    override fun onError(utteranceId: String?) {
                        onSpeechFinished()
                    }
                })
                AppLogger.i(tag, "TTS initialized successfully with persona: ${currentPersona.name}")
            } else {
                AppLogger.e(tag, "TTS initialization failed with status: $status")
            }
        }
    }

    fun setPersona(persona: VoicePersona) {
        currentPersona = persona
        prefs.edit().putString("voice_persona", persona.name).apply()
        applyPersonaSettings()
        AppLogger.i(tag, "Switched voice persona to: ${persona.name}")
    }

    fun getCurrentPersona(): VoicePersona = currentPersona

    private fun applyPersonaSettings() {
        if (!isInitialized) return
        try {
            tts?.setPitch(currentPersona.pitch)
            tts?.setSpeechRate(currentPersona.speed)
            selectBestVoiceForLocale(if (hasBengaliSupport()) bengaliLocale else englishLocale)
        } catch (e: Exception) {
            AppLogger.w(tag, "Failed applying persona settings: ${e.message}")
        }
    }

    private fun hasBengaliSupport(): Boolean {
        val res = tts?.isLanguageAvailable(bengaliLocale)
        return res != TextToSpeech.LANG_MISSING_DATA && res != TextToSpeech.LANG_NOT_SUPPORTED
    }

    private fun selectBestVoiceForLocale(locale: Locale) {
        try {
            val voices = tts?.voices ?: return
            val matchingVoices = voices.filter { it.locale.language == locale.language }
            if (matchingVoices.isNotEmpty()) {
                val selectedVoice = if (currentPersona == VoicePersona.JARVIS) {
                    matchingVoices.firstOrNull { voice ->
                        val name = voice.name.lowercase(Locale.ROOT)
                        name.contains("male") || name.contains("man") || name.contains("m-") ||
                                (!name.contains("female") && !name.contains("f-"))
                    } ?: matchingVoices.first()
                } else {
                    matchingVoices.firstOrNull { voice ->
                        val name = voice.name.lowercase(Locale.ROOT)
                        name.contains("female") || name.contains("woman") || name.contains("f-")
                    } ?: matchingVoices.first()
                }

                tts?.voice = selectedVoice
                AppLogger.d(tag, "Selected voice: ${selectedVoice.name} for persona ${currentPersona.name}")
            }
        } catch (e: Exception) {
            AppLogger.w(tag, "Error selecting voice: ${e.message}")
        }
    }

    /**
     * Speaks the given text using auto-detected language and consistent persona.
     */
    fun speak(rawText: String) {
        if (!isInitialized || rawText.isBlank()) return

        val cleanText = cleanTextForSpeech(rawText)
        if (cleanText.isBlank()) return

        // Auto-detect language
        val hasBengali = cleanText.matches(Regex(".*[\\p{InBengali}].*"))
        val targetLocale = if (hasBengali && hasBengaliSupport()) bengaliLocale else englishLocale

        try {
            tts?.setLanguage(targetLocale)
            selectBestVoiceForLocale(targetLocale)
            // Re-apply consistent pitch & rate so language switch never causes voice jumps
            tts?.setPitch(currentPersona.pitch)
            tts?.setSpeechRate(currentPersona.speed)

            val utteranceId = "aura_voice_${System.currentTimeMillis()}"
            tts?.speak(cleanText, TextToSpeech.QUEUE_FLUSH, null, utteranceId)
        } catch (e: Exception) {
            AppLogger.e(tag, "Error during TTS speak", e)
        }
    }

    /**
     * Cleans text to eliminate robotic glitch reading of symbols, quotes, and markdown.
     */
    private fun cleanTextForSpeech(raw: String): String {
        var text = raw
        // Remove URLs
        text = text.replace(Regex("https?://\\S+"), "")
        // Remove markdown formatting
        text = text.replace(Regex("[#*_~`>]"), "")
        // Remove system tags
        text = text.replace(Regex("\\[.*?\\]"), "")
        text = text.replace(Regex("//\\s*\\w+"), "")
        // Remove emojis and special icons
        text = text.replace(Regex("[\\p{So}\\p{Cn}]"), "")
        // Clean bullet points
        text = text.replace(Regex("^[-*•]\\s*", RegexOption.MULTILINE), "")
        // Clean multiple punctuation that causes robotic stutter
        text = text.replace(Regex("[.!?]{2,}"), ".")
        text = text.replace(Regex("[\"“”']"), "")
        // Replace multiple spaces
        return text.replace(Regex("\\s+"), " ").trim()
    }

    fun stop() {
        tts?.stop()
    }

    fun shutdown() {
        tts?.stop()
        tts?.shutdown()
        tts = null
    }
}
