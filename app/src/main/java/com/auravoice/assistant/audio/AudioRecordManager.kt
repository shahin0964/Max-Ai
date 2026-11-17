package com.auravoice.assistant.audio

import android.annotation.SuppressLint
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.util.Log
import kotlinx.coroutines.*
import kotlin.math.sqrt

/**
 * AudioRecordManager:
 * Continuous, low-overhead mic listener providing real-time audio amplitude
 * for the 3D Arc Reactor Orb without causing audio focus conflicts.
 */
class AudioRecordManager(
    private val onAmplitudeChanged: (Float) -> Unit,
    private val onAudioBuffer: (ByteArray, Int) -> Unit
) {
    private val tag = "AudioRecordManager"
    private val sampleRate = 16000
    private val channelConfig = AudioFormat.CHANNEL_IN_MONO
    private val audioFormat = AudioFormat.ENCODING_PCM_16BIT

    private var audioRecord: AudioRecord? = null
    @Volatile
    private var isRecording = false
    private var recordingJob: Job? = null

    @SuppressLint("MissingPermission")
    fun startListening(scope: CoroutineScope) {
        if (isRecording) return

        try {
            val minBufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)
            val bufferSize = maxOf(minBufferSize, 2048)

            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.VOICE_RECOGNITION,
                sampleRate,
                channelConfig,
                audioFormat,
                bufferSize
            )

            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                Log.w(tag, "AudioRecord could not initialize with VOICE_RECOGNITION, trying DEFAULT")
                audioRecord = AudioRecord(
                    MediaRecorder.AudioSource.DEFAULT,
                    sampleRate,
                    channelConfig,
                    audioFormat,
                    bufferSize
                )
            }

            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                Log.e(tag, "AudioRecord state is not initialized. Mic may be busy.")
                return
            }

            audioRecord?.startRecording()
            isRecording = true

            recordingJob = scope.launch(Dispatchers.IO) {
                val buffer = ByteArray(bufferSize)
                while (isRecording && isActive) {
                    val bytesRead = audioRecord?.read(buffer, 0, buffer.size) ?: -1
                    if (bytesRead > 0) {
                        val amplitude = calculateRMS(buffer, bytesRead)
                        withContext(Dispatchers.Main) {
                            onAmplitudeChanged(amplitude)
                        }
                        onAudioBuffer(buffer, bytesRead)
                    } else if (bytesRead == AudioRecord.ERROR_INVALID_OPERATION) {
                        // Mic temporarily claimed by system, brief delay
                        delay(100)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(tag, "Error in AudioRecordManager startListening: ${e.message}", e)
            isRecording = false
        }
    }

    fun stopListening() {
        isRecording = false
        recordingJob?.cancel()
        recordingJob = null
        try {
            audioRecord?.stop()
            audioRecord?.release()
        } catch (e: Exception) {
            Log.w(tag, "Error stopping AudioRecord: ${e.message}")
        }
        audioRecord = null
    }

    private fun calculateRMS(buffer: ByteArray, bytesRead: Int): Float {
        var sum = 0.0
        val numSamples = bytesRead / 2
        if (numSamples <= 0) return 0f
        for (i in 0 until numSamples) {
            val sample = (buffer[i * 2 + 1].toInt() shl 8) or (buffer[i * 2].toInt() and 0xFF)
            sum += sample * sample
        }
        val rms = sqrt(sum / numSamples)
        return (rms / 32768.0).toFloat().coerceIn(0f, 1f)
    }

    fun isListening(): Boolean = isRecording
}
