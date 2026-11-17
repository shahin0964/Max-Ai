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

    private val binder = LocalBinder()
    private val serviceScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    private var wakeLock: PowerManager.WakeLock? = null
    private val channelId = "aura_voice_assistant_channel"
    private val notificationId = 101

    // Core Engines
    private lateinit var database: AppDatabase
    private lateinit var memoryManager: MemoryManager
    private lateinit var llamaEngine: LlamaEngine
    private lateinit var wakeWordDetector: WakeWordDetector
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
        createNotificationChannel()
        acquireWakeLock()
        initEngines()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = buildNotification(getString(R.string.notification_listening))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                notificationId,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
            )
        } else {
            startForeground(notificationId, notification)
        }

        startListeningCycle()
        return START_STICKY
    }

    private fun initEngines() {
        database = AppDatabase.getDatabase(this)
        memoryManager = MemoryManager(database)
        llamaEngine = LlamaEngine(this)

        wakeWordDetector = WakeWordDetector {
            // Wake word detected! Switch to active listening
            onWakeWordTriggered()
        }

        ttsEngine = TextToSpeechEngine(
            context = this,
            onSpeechStarted = {
                _currentState.value = AssistantState.SPEAKING
                updateNotification(getString(R.string.notification_speaking))
            },
            onSpeechFinished = {
                _currentState.value = AssistantState.IDLE
                updateNotification(getString(R.string.notification_listening))
                startListeningCycle()
            }
        )

        sttEngine = SpeechToTextEngine(
            context = this,
            onPartialResult = { partial ->
                _currentTranscript.value = partial
            },
            onFinalResult = { finalQuery ->
                _currentTranscript.value = finalQuery
                processUserQuery(finalQuery)
            },
            onError = { _ ->
                if (_currentState.value == AssistantState.LISTENING) {
                    _currentState.value = AssistantState.IDLE
                }
            }
        )

        audioRecordManager = AudioRecordManager(
            onAmplitudeChanged = { amp ->
                _amplitude.value = amp
            },
            onAudioBuffer = { _, _ ->
                // Feed buffer to keyword spotting if using raw audio
            }
        )
    }

    private fun startListeningCycle() {
        _currentState.value = AssistantState.LISTENING
        audioRecordManager?.startListening(serviceScope)
        sttEngine?.startListening()
    }

    private fun onWakeWordTriggered() {
        _currentState.value = AssistantState.LISTENING
        ttsEngine?.speak("বলুন, শুনছি...")
    }

    fun processUserQuery(query: String) {
        val cleanQuery = query.trim()
        if (cleanQuery.isBlank()) return

        serviceScope.launch {
            _currentState.value = AssistantState.THINKING
            updateNotification(getString(R.string.notification_thinking))

            // 1. Save user message to local history
            database.chatMessageDao().insertMessage(
                ChatMessageEntity(sender = "user", text = cleanQuery)
            )

            // 2. Build Context-Aware System Prompt with Learned Memories
            val systemPrompt = memoryManager.buildSystemPrompt(cleanQuery)

            // 3. Local LLM Generation (Offline, No API key)
            val response = llamaEngine.generateResponse(systemPrompt, cleanQuery)
            _currentResponse.value = response

            // 4. Save response to local history
            database.chatMessageDao().insertMessage(
                ChatMessageEntity(sender = "assistant", text = response)
            )

            // 5. Continuous Learning: Automatically extract and learn new facts
            memoryManager.learnFromConversation(cleanQuery, response)

            // 6. Speak response via Offline TTS
            _currentState.value = AssistantState.SPEAKING
            ttsEngine?.speak(response)
        }
    }

    private fun acquireWakeLock() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "AuraVoice::AssistantWakeLock"
        ).apply {
            acquire(10 * 60 * 60 * 1000L) // 10 hours max
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
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun updateNotification(statusText: String) {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(notificationId, buildNotification(statusText))
    }

    override fun onDestroy() {
        super.onDestroy()
        audioRecordManager?.stopListening()
        sttEngine?.destroy()
        ttsEngine?.shutdown()
        wakeLock?.let {
            if (it.isHeld) it.release()
        }
        serviceScope.cancel()
    }
}
