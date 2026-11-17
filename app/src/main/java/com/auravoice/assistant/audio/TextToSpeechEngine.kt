package com.auravoice.assistant.audio

import android.content.Context
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import java.util.Locale

/**
 * TextToSpeechEngine:
 * Local offline voice synthesis engine supporting natural Bengali and English.
 */
class TextToSpeechEngine(
    private val context: Context,
    private val onSpeechStarted: () -> Unit,
    private val onSpeechFinished: () -> Unit
) {
    private val tag = "TextToSpeechEngine"
    private var tts: TextToSpeech? = null
    private var isInitialized = false

    private val bengaliLocale = Locale("bn", "BD")
    private val englishLocale = Locale.US

    init {
        tts = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                isInitialized = true
                tts?.setSpeechRate(1.0f)
                tts?.setPitch(1.0f)
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
                Log.d(tag, "TTS initialized successfully")
            } else {
                Log.e(tag, "TTS initialization failed with status: $status")
            }
        }
    }

    /**
     * Speaks the given text using auto-detected language (Bengali or English).
     */
    fun speak(text: String) {
        if (!isInitialized || text.isBlank()) return

        // Auto-detect script: if Bengali characters exist, use Bengali locale
        val hasBengali = text.matches(Regex(".*[\\p{InBengali}].*"))
        val targetLocale = if (hasBengali) bengaliLocale else englishLocale

        val langResult = tts?.setLanguage(targetLocale)
        if (langResult == TextToSpeech.LANG_MISSING_DATA || langResult == TextToSpeech.LANG_NOT_SUPPORTED) {
            // Fallback to default locale if Bengali offline pack not installed yet
            tts?.setLanguage(englishLocale)
        }

        val utteranceId = "aura_voice_${System.currentTimeMillis()}"
        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, utteranceId)
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
