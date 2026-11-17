package com.auravoice.assistant.service

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import com.auravoice.assistant.MainActivity
import com.auravoice.assistant.R
import com.auravoice.assistant.audio.*
import com.auravoice.assistant.brain.LlamaEngine
import com.auravoice.assistant.brain.MemoryManager
import com.auravoice.assistant.data.AppDatabase
import com.auravoice.assistant.data.ChatMessageEntity
import com.auravoice.assistant.util.AppLogger
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

enum class AssistantState {
    IDLE,
    LISTENING,
    THINKING,
    SPEAKING
}

class VoiceAssistantForegroundService : Service() {

    private val tag = "VoiceAssistantService"
    private val binder = LocalBinder()
    private val serviceScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    private var wakeLock: PowerManager.WakeLock? = null
    private val channelId = "aura_voice_assistant_channel"
    private val notificationId = 101

    // Core Engines
    private var database: AppDatabase? = null
    private var memoryManager: MemoryManager? = null
    private var llamaEngine: LlamaEngine? = null
    private var wakeWordDetector: WakeWordDetector? = null
    private var sttEngine: SpeechToTextEngine? = null
    private var ttsEngine: TextToSpeechEngine? = null
    private var audioRecordManager: AudioRecordManager? = null

    // State flows for UI binding
    private val _currentState = MutableStateFlow(AssistantState.IDLE)
    val currentState: StateFlow<AssistantState> = _currentState

    private val _currentTranscript = MutableStateFlow("")
    val currentTranscript: StateFlow<String> = _currentTranscript

    private val _currentResponse = MutableStateFlow("")
    val currentResponse: StateFlow<String> = _currentResponse

    private val _amplitude = MutableStateFlow(0f)
    val amplitude: StateFlow<Float> = _amplitude

    inner class LocalBinder : Binder() {
        fun getService(): VoiceAssistantForegroundService = this@VoiceAssistantForegroundService
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onCreate() {
        super.onCreate()
        AppLogger.i(tag, "Service onCreate called")
        try {
            createNotificationChannel()
            acquireWakeLock()
            initEngines()
        } catch (e: Exception) {
            AppLogger.e(tag, "Error in service onCreate", e)
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        AppLogger.i(tag, "Service onStartCommand called")
        try {
            val notification = buildNotification(getString(R.string.notification_listening))
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    startForeground(
                        notificationId,
                        notification,
                        ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
                    )
                } else {
                    startForeground(notificationId, notification)
                }
                AppLogger.i(tag, "startForeground initialized successfully")
            } catch (e: SecurityException) {
                AppLogger.w(tag, "FGS mic type rejected, falling back to standard FGS: ${e.message}")
                startForeground(notificationId, notification)
            }

            startListeningCycle()
        } catch (e: Exception) {
            AppLogger.e(tag, "Error starting foreground service", e)
        }
        return START_STICKY
    }

    private fun initEngines() {
        try {
            database = AppDatabase.getDatabase(this)
            database?.let { db ->
                memoryManager = MemoryManager(db)
            }
            llamaEngine = LlamaEngine(this)

            wakeWordDetector = WakeWordDetector {
                AppLogger.i(tag, "Wake word trigger activated")
                onWakeWordTriggered()
            }

            ttsEngine = TextToSpeechEngine(
                context = this,
                onSpeechStarted = {
                    AppLogger.d(tag, "TTS started speaking")
                    _currentState.value = AssistantState.SPEAKING
                    updateNotification(getString(R.string.notification_speaking))
                },
                onSpeechFinished = {
                    AppLogger.d(tag, "TTS finished speaking")
                    _currentState.value = AssistantState.IDLE
                    updateNotification(getString(R.string.notification_listening))
                    startListeningCycle()
                }
            )

            sttEngine = SpeechToTextEngine(
                context = this,
                onPartialResult = { partial ->
                    AppLogger.d(tag, "STT partial: $partial")
                    _currentTranscript.value = partial
                },
                onFinalResult = { finalQuery ->
                    AppLogger.i(tag, "STT final: $finalQuery")
                    _currentTranscript.value = finalQuery
                    processUserQuery(finalQuery)
                },
                onError = { errorCode ->
                    AppLogger.w(tag, "STT reported error: $errorCode")
                    if (_currentState.value == AssistantState.LISTENING) {
                        _currentState.value = AssistantState.IDLE
                    }
                }
            )

            audioRecordManager = AudioRecordManager(
                onAmplitudeChanged = { amp ->
                    _amplitude.value = amp
                },
                onAudioBuffer = { _, _ -> }
            )

            AppLogger.i(tag, "All engines initialized successfully")
        } catch (e: Exception) {
            AppLogger.e(tag, "Exception during initEngines", e)
        }
    }

    fun startListeningCycle() {
        try {
            AppLogger.i(tag, "Starting listening cycle")
            _currentState.value = AssistantState.LISTENING
            audioRecordManager?.startListening(serviceScope)
            sttEngine?.startListening()
        } catch (e: Exception) {
            AppLogger.e(tag, "Error starting listening cycle", e)
        }
    }

    private fun onWakeWordTriggered() {
        _currentState.value = AssistantState.LISTENING
        ttsEngine?.speak("বলুন, শুনছি...")
    }

    fun processUserQuery(query: String) {
        val cleanQuery = query.trim()
        if (cleanQuery.isBlank()) return

        serviceScope.launch {
            try {
                AppLogger.i(tag, "Processing query: $cleanQuery")
                _currentState.value = AssistantState.THINKING
                updateNotification(getString(R.string.notification_thinking))

                database?.chatMessageDao()?.insertMessage(
                    ChatMessageEntity(sender = "user", text = cleanQuery)
                )

                val systemPrompt = memoryManager?.buildSystemPrompt(cleanQuery)
                    ?: "You are Aura Voice AI. Answer concisely in Bengali or English."

                val response = llamaEngine?.generateResponse(systemPrompt, cleanQuery)
                    ?: "আমি বুঝতে পেরেছি।"
                _currentResponse.value = response
                AppLogger.i(tag, "Generated response: $response")

                database?.chatMessageDao()?.insertMessage(
                    ChatMessageEntity(sender = "assistant", text = response)
                )

                memoryManager?.learnFromConversation(cleanQuery, response)

                _currentState.value = AssistantState.SPEAKING
                ttsEngine?.speak(response)
            } catch (e: Exception) {
                AppLogger.e(tag, "Error processing query", e)
                _currentState.value = AssistantState.IDLE
            }
        }
    }

    private fun acquireWakeLock() {
        try {
            val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
            wakeLock = powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "AuraVoice::AssistantWakeLock"
            ).apply {
                acquire(10 * 60 * 60 * 1000L)
            }
            AppLogger.i(tag, "WakeLock acquired")
        } catch (e: Exception) {
            AppLogger.w(tag, "Failed to acquire WakeLock: ${e.message}")
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                getString(R.string.channel_name),
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = getString(R.string.channel_description)
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(statusText: String): Notification {
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            this, 0, openIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle(getString(R.string.notification_title))
            .setContentText(statusText)
            .setSmallIcon(R.drawable.ic_aura_stat)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun updateNotification(statusText: String) {
        try {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.notify(notificationId, buildNotification(statusText))
        } catch (e: Exception) {
            AppLogger.w(tag, "Notification update failed: ${e.message}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        AppLogger.i(tag, "Service onDestroy")
        audioRecordManager?.stopListening()
        sttEngine?.destroy()
        ttsEngine?.shutdown()
        wakeLock?.let {
            if (it.isHeld) it.release()
        }
        serviceScope.cancel()
    }
}
