package com.max.ai

import android.content.Context
import android.content.Intent
import android.hardware.camera2.CameraManager
import android.media.AudioManager
import android.media.MediaPlayer
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.max.ai/audio"
    private var mediaPlayer: MediaPlayer? = null
    private var tts: TextToSpeech? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize TextToSpeech
        tts = TextToSpeech(applicationContext) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts?.language = Locale.US
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "playVoiceSample" -> {
                    val voice = call.argument<String>("voice") ?: "Maya"
                    playVoiceSample(voice, result)
                }
                "speakText" -> {
                    val text = call.argument<String>("text") ?: ""
                    val pitch = call.argument<Double>("pitch") ?: 1.0
                    val rate = call.argument<Double>("rate") ?: 1.0
                    tts?.setPitch(pitch.toFloat())
                    tts?.setSpeechRate(rate.toFloat())
                    tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "max_ai_speech")
                    result.success(true)
                }
                "setTorch" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    try {
                        val cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
                        val cameraId = cameraManager.cameraIdList[0]
                        cameraManager.setTorchMode(cameraId, enabled)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "setVolume" -> {
                    val percent = call.argument<Int>("percent") ?: 50
                    try {
                        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                        val maxVol = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
                        val targetVol = (percent * maxVol) / 100
                        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, targetVol, 0)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playVoiceSample(voice: String, result: MethodChannel.Result) {
        try {
            mediaPlayer?.release()
            mediaPlayer = null

            val assetName = when (voice.lowercase()) {
                "friday" -> "voices/friday_Aoede.ogg"
                "venom" -> "voices/venom_Fenrir.ogg"
                else -> "voices/maya_Aoede.ogg"
            }

            val afd = assets.openFd(assetName)
            mediaPlayer = MediaPlayer().apply {
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                prepare()
                start()
                setOnCompletionListener {
                    it.release()
                    mediaPlayer = null
                }
            }
            result.success(true)
        } catch (e: Exception) {
            // Fallback to native TextToSpeech if file is busy or not found
            when (voice.lowercase()) {
                "friday" -> {
                    tts?.setPitch(1.25f)
                    tts?.setSpeechRate(1.15f)
                    tts?.speak("Friday online. Tactical systems ready for command.", TextToSpeech.QUEUE_FLUSH, null, null)
                }
                "venom" -> {
                    tts?.setPitch(0.55f)
                    tts?.setSpeechRate(0.85f)
                    tts?.speak("We are Venom. Ready to execute your orders.", TextToSpeech.QUEUE_FLUSH, null, null)
                }
                else -> {
                    tts?.setPitch(1.05f)
                    tts?.setSpeechRate(1.0f)
                    tts?.speak("Hello! I am Maya, your personal AI assistant. How can I help you?", TextToSpeech.QUEUE_FLUSH, null, null)
                }
            }
            result.success(true)
        }
    }

    override fun onDestroy() {
        mediaPlayer?.release()
        tts?.shutdown()
        super.onDestroy()
    }
}
