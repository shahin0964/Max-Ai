package com.getmaya.android.audio

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlin.math.sqrt

enum class AssistantState {
    IDLE,
    LISTENING,
    THINKING,
    SPEAKING
}

class AudioPipelineManager(private val context: Context) {

    private val _state = MutableStateFlow(AssistantState.IDLE)
    val state = _state.asStateFlow()

    private val _audioAmplitude = MutableStateFlow(0f)
    val audioAmplitude = _audioAmplitude.asStateFlow()

    private var recordJob: Job? = null
    private var audioRecord: AudioRecord? = null

    private val sampleRate = 16000
    private val bufferSize = AudioRecord.getMinBufferSize(
        sampleRate,
        AudioFormat.CHANNEL_IN_MONO,
        AudioFormat.ENCODING_PCM_16BIT
    ).coerceAtLeast(2048)

    fun startListening(onSpeechRecognized: (String) -> Unit) {
        if (_state.value == AssistantState.LISTENING) return
        _state.value = AssistantState.LISTENING

        recordJob?.cancel()
        recordJob = CoroutineScope(Dispatchers.IO).launch {
            try {
                audioRecord = AudioRecord(
                    MediaRecorder.AudioSource.VOICE_RECOGNITION,
                    sampleRate,
                    AudioFormat.CHANNEL_IN_MONO,
                    AudioFormat.ENCODING_PCM_16BIT,
                    bufferSize
                )
                audioRecord?.startRecording()
                val buffer = ShortArray(1024)

                while (isActive && _state.value == AssistantState.LISTENING) {
                    val read = audioRecord?.read(buffer, 0, buffer.size) ?: 0
                    if (read > 0) {
                        // Calculate RMS amplitude for visualizer
                        var sum = 0.0
                        for (i in 0 until read) {
                            sum += buffer[i] * buffer[i]
                        }
                        val rms = sqrt(sum / read).toFloat()
                        val normalized = (rms / 32767f).coerceIn(0f, 1f)
                        _audioAmplitude.value = normalized
                    }
                }
            } catch (e: Exception) {
                Log.e("AudioPipeline", "Error in AudioRecord", e)
            } finally {
                stopRecording()
            }
        }
    }

    fun stopListening() {
        _state.value = AssistantState.IDLE
        recordJob?.cancel()
        stopRecording()
    }

    fun setThinking() {
        _state.value = AssistantState.THINKING
    }

    fun setSpeaking() {
        _state.value = AssistantState.SPEAKING
    }

    fun setIdle() {
        _state.value = AssistantState.IDLE
    }

    private fun stopRecording() {
        try {
            audioRecord?.stop()
            audioRecord?.release()
        } catch (_: Exception) {}
        audioRecord = null
    }
}
