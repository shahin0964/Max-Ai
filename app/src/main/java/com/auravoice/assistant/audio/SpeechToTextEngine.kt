package com.auravoice.assistant.audio

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.util.Log

/**
 * Robust SpeechToTextEngine:
 * Prevents rapid disconnect loops, handles silence timeouts gracefully,
 * and maintains continuous voice activation without crashing or disconnect beeps.
 */
class SpeechToTextEngine(
    private val context: Context,
    private val onPartialResultCallback: (String) -> Unit,
    private val onFinalResultCallback: (String) -> Unit,
    private val onErrorCallback: (Int) -> Unit
) {
    private val tag = "SpeechToTextEngine"
    private var speechRecognizer: SpeechRecognizer? = null
    private var recognizerIntent: Intent? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    @Volatile
    private var isListeningEnabled = false
    @Volatile
    private var isCurrentlyRecognizing = false
    private var consecutiveErrors = 0
    private var lastRestartTime = 0L

    init {
        mainHandler.post {
            initRecognizerOnMainThread()
        }
    }

    private fun initRecognizerOnMainThread() {
        try {
            if (!SpeechRecognizer.isRecognitionAvailable(context)) {
                Log.w(tag, "Speech recognition not natively available")
                return
            }

            destroyRecognizer()

            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context).apply {
                setRecognitionListener(createListener())
            }

            recognizerIntent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, context.packageName)
                putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
                putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 4500L)
                putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 3500L)
                putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, 2500L)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, "bn-BD")
                putExtra("android.speech.extra.EXTRA_ADDITIONAL_LANGUAGES", arrayOf("en-US", "bn-IN"))
            }

            Log.d(tag, "SpeechRecognizer initialized successfully on main thread")
        } catch (e: Exception) {
            Log.e(tag, "Failed to init SpeechRecognizer: ${e.message}", e)
        }
    }

    private fun createListener(): RecognitionListener {
        return object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {
                isCurrentlyRecognizing = true
                consecutiveErrors = 0
                Log.d(tag, "STT Ready for speech")
            }

            override fun onBeginningOfSpeech() {
                Log.d(tag, "STT Detected speech beginning")
            }

            override fun onRmsChanged(rmsdB: Float) {}
            override fun onBufferReceived(buffer: ByteArray?) {}

            override fun onEndOfSpeech() {
                isCurrentlyRecognizing = false
                Log.d(tag, "STT End of speech")
            }

            override fun onError(error: Int) {
                isCurrentlyRecognizing = false
                consecutiveErrors++
                Log.w(tag, "STT Error code: $error, count: $consecutiveErrors")
                onErrorCallback(error)

                // Prevent rapid crash loop or disconnect spam
                scheduleRestart(error)
            }

            override fun onResults(results: Bundle?) {
                isCurrentlyRecognizing = false
                consecutiveErrors = 0
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (!matches.isNullOrEmpty()) {
                    val text = matches[0].trim()
                    if (text.isNotBlank()) {
                        Log.d(tag, "STT Final Result: $text")
                        onFinalResultCallback(text)
                    }
                }

                if (isListeningEnabled) {
                    scheduleRestart(0)
                }
            }

            override fun onPartialResults(partialResults: Bundle?) {
                val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (!matches.isNullOrEmpty()) {
                    val partial = matches[0].trim()
                    if (partial.isNotBlank()) {
                        onPartialResultCallback(partial)
                    }
                }
            }

            override fun onEvent(eventType: Int, params: Bundle?) {}
        }
    }

    fun startListening() {
        isListeningEnabled = true
        mainHandler.post {
            executeStartListening()
        }
    }

    private fun executeStartListening() {
        if (!isListeningEnabled || isCurrentlyRecognizing) return

        val now = System.currentTimeMillis()
        if (now - lastRestartTime < 600) {
            // Debounce too frequent restarts to avoid ERROR_RECOGNIZER_BUSY
            scheduleRestart(0, delay = 600)
            return
        }
        lastRestartTime = now

        try {
            if (speechRecognizer == null) {
                initRecognizerOnMainThread()
            }
            speechRecognizer?.cancel()
            recognizerIntent?.let { intent ->
                speechRecognizer?.startListening(intent)
                isCurrentlyRecognizing = true
                Log.d(tag, "STT started listening")
            }
        } catch (e: Exception) {
            Log.e(tag, "Error starting speech recognition: ${e.message}", e)
            isCurrentlyRecognizing = false
            scheduleRestart(9, delay = 1200)
        }
    }

    private fun scheduleRestart(errorCode: Int, delay: Long = 0) {
        if (!isListeningEnabled) return

        // Calculate smart backoff delay based on error type
        val actualDelay = when {
            delay > 0 -> delay
            errorCode == SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> 1000L
            errorCode == SpeechRecognizer.ERROR_NO_MATCH -> 400L
            errorCode == SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> 400L
            consecutiveErrors > 5 -> 2500L
            else -> 500L
        }

        mainHandler.removeCallbacksAndMessages(null)
        mainHandler.postDelayed({
            if (isListeningEnabled) {
                executeStartListening()
            }
        }, actualDelay)
    }

    fun stopListening() {
        isListeningEnabled = false
        isCurrentlyRecognizing = false
        mainHandler.removeCallbacksAndMessages(null)
        mainHandler.post {
            try {
                speechRecognizer?.stopListening()
                speechRecognizer?.cancel()
            } catch (e: Exception) {
                Log.w(tag, "Error stopping recognizer: ${e.message}")
            }
        }
    }

    private fun destroyRecognizer() {
        try {
            speechRecognizer?.destroy()
        } catch (e: Exception) {
            Log.w(tag, "Error destroying recognizer: ${e.message}")
        }
        speechRecognizer = null
        isCurrentlyRecognizing = false
    }

    fun destroy() {
        stopListening()
        mainHandler.post {
            destroyRecognizer()
        }
    }
}
