package com.auravoice.assistant.audio

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log

/**
 * SpeechToTextEngine:
 * Offline speech recognizer supporting continuous listening,
 * Bengali and English voice input.
 */
class SpeechToTextEngine(
    private val context: Context,
    private val onPartialResult: (String) -> Unit,
    private val onFinalResult: (String) -> Unit,
    private val onError: (Int) -> Unit
) {
    private val tag = "SpeechToTextEngine"
    private var speechRecognizer: SpeechRecognizer? = null
    private var recognizerIntent: Intent? = null
    private var isListening = false

    init {
        setupRecognizer()
    }

    private fun setupRecognizer() {
        if (!SpeechRecognizer.isRecognitionAvailable(context)) {
            Log.e(tag, "Speech recognition not available on this device")
            return
        }

        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context)
        recognizerIntent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, context.packageName)
            // Enable offline preference
            putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
            // Support both Bengali and English
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, "bn-BD")
            putExtra("android.speech.extra.EXTRA_ADDITIONAL_LANGUAGES", arrayOf("en-US", "bn-IN"))
        }

        speechRecognizer?.setRecognitionListener(object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {
                Log.d(tag, "Ready for speech")
            }

            override fun onBeginningOfSpeech() {
                Log.d(tag, "Beginning of speech")
            }

            override fun onRmsChanged(rmsdB: Float) {}
            override fun onBufferReceived(buffer: ByteArray?) {}

            override fun onEndOfSpeech() {
                Log.d(tag, "End of speech")
            }

            override fun onError(error: Int) {
                Log.d(tag, "Speech recognition error: $error")
                onError(error)
                // If recognizer had a pause or no speech, restart if intended to be always listening
                if (isListening) {
                    restartListening()
                }
            }

            override fun onResults(results: Bundle?) {
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (!matches.isNullOrEmpty()) {
                    val text = matches[0]
                    Log.d(tag, "Final recognition result: $text")
                    onFinalResult(text)
                }
                if (isListening) {
                    restartListening()
                }
            }

            override fun onPartialResults(partialResults: Bundle?) {
                val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (!matches.isNullOrEmpty()) {
                    onPartialResult(matches[0])
                }
            }

            override fun onEvent(eventType: Int, params: Bundle?) {}
        })
    }

    fun startListening() {
        if (isListening) return
        isListening = true
        try {
            speechRecognizer?.startListening(recognizerIntent)
            Log.d(tag, "Started speech recognition")
        } catch (e: Exception) {
            Log.e(tag, "Error starting speech recognition: ${e.message}", e)
        }
    }

    private fun restartListening() {
        try {
            speechRecognizer?.cancel()
            speechRecognizer?.startListening(recognizerIntent)
        } catch (e: Exception) {
            Log.e(tag, "Error restarting speech recognition: ${e.message}")
        }
    }

    fun stopListening() {
        isListening = false
        try {
            speechRecognizer?.stopListening()
            speechRecognizer?.cancel()
        } catch (e: Exception) {
            Log.e(tag, "Error stopping speech recognition: ${e.message}")
        }
    }

    fun destroy() {
        stopListening()
        speechRecognizer?.destroy()
        speechRecognizer = null
    }
}
