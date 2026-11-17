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
 * Captures microphone audio in background with low latency and computes sound amplitude.
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
    private var isRecording = false
    private var recordingJob: Job? = null

    @SuppressLint("MissingPermission")
    fun startListening(scope: CoroutineScope) {
        if (isRecording) return

        val minBufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, audioFormat)
        val bufferSize = maxOf(minBufferSize, 2048)

        try {
            audioRecord = AudioRecord(
                MediaRecorder.AudioSource.VOICE_RECOGNITION,
                sampleRate,
                channelConfig,
                audioFormat,
                bufferSize
            )

            if (audioRecord?.state != AudioRecord.STATE_INITIALIZED) {
                Log.e(tag, "AudioRecord could not be initialized")
                return
            }

            audioRecord?.startRecording()
            isRecording = true

            recordingJob = scope.launch(Dispatchers.IO) {
                val buffer = ByteArray(bufferSize)
                while (isRecording && isActive) {
                    val bytesRead = audioRecord?.read(buffer, 0, buffer.size) ?: -1
                    if (bytesRead > 0) {
                        // Calculate RMS amplitude for UI soundwave
                        val amplitude = calculateRMS(buffer, bytesRead)
                        withContext(Dispatchers.Main) {
                            onAmplitudeChanged(amplitude)
                        }
                        onAudioBuffer(buffer, bytesRead)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(tag, "Error starting AudioRecord: ${e.message}", e)
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
            Log.e(tag, "Error stopping AudioRecord: ${e.message}", e)
        }
        audioRecord = null
    }

    private fun calculateRMS(buffer: ByteArray, bytesRead: Int): Float {
        var sum = 0.0
        val numSamples = bytesRead / 2
        for (i in 0 until numSamples) {
            val sample = (buffer[i * 2 + 1].toInt() shl 8) or (buffer[i * 2].toInt() and 0xFF)
            sum += sample * sample
        }
        val rms = sqrt(sum / numSamples)
        // Normalize between 0.0 and 1.0
        return (rms / 32768.0).toFloat().coerceIn(0f, 1f)
    }

    fun isListening(): Boolean = isRecording
}
