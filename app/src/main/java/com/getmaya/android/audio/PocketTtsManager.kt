package com.getmaya.android.audio

import android.content.Context
import android.media.MediaPlayer
import android.speech.tts.TextToSpeech
import android.util.Log
import java.io.File
import java.util.Locale

class PocketTtsManager(private val context: Context) : TextToSpeech.OnInitListener {

    private var tts: TextToSpeech? = null
    private var isTtsReady = false
    private var mediaPlayer: MediaPlayer? = null

    init {
        tts = TextToSpeech(context, this)
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            tts?.language = Locale.US
            isTtsReady = true
            Log.d("PocketTtsManager", "TTS engine initialized successfully")
        }
    }

    fun speak(text: String, persona: String = "Maya", onDone: () -> Unit = {}) {
        // Check if there is an asset voice snippet for greeting
        val voicePrefix = persona.lowercase()
        try {
            // If offline greeting matches available ogg samples
            val oggName = "voices/${voicePrefix}_Aoede.ogg"
            val afd = context.assets.openFd(oggName)
            mediaPlayer?.release()
            mediaPlayer = MediaPlayer().apply {
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                prepare()
                setOnCompletionListener {
                    it.release()
                    onDone()
                }
                start()
            }
            return
        } catch (e: Exception) {
            // Fall back to standard TTS
        }

        if (isTtsReady) {
            tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "maya_speech_${System.currentTimeMillis()}")
        }
    }

    fun stop() {
        try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
            tts?.stop()
        } catch (_: Exception) {}
    }

    fun destroy() {
        stop()
        tts?.shutdown()
    }
}
