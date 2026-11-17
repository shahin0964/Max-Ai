package com.auravoice.assistant

import android.Manifest
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Chat
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Terminal
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import com.auravoice.assistant.brain.ModelLoadManager
import com.auravoice.assistant.data.AppDatabase
import com.auravoice.assistant.data.ChatMessageEntity
import com.auravoice.assistant.service.AssistantState
import com.auravoice.assistant.service.VoiceAssistantForegroundService
import com.auravoice.assistant.terminal.LinuxShellEngine
import com.auravoice.assistant.ui.ChatScreen
import com.auravoice.assistant.ui.MemoryViewerScreen
import com.auravoice.assistant.ui.SettingsScreen
import com.auravoice.assistant.ui.TerminalScreen
import com.auravoice.assistant.ui.VoiceAssistantScreen
import com.auravoice.assistant.ui.theme.*
import com.auravoice.assistant.util.AppLogger
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private val tag = "MainActivity"
    private var assistantService: VoiceAssistantForegroundService? = null
    private var isBound = false
    private val modelLoadManager by lazy { ModelLoadManager(this) }
    private val shellEngine by lazy { LinuxShellEngine() }

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            AppLogger.i(tag, "ServiceConnection: Connected to VoiceAssistantForegroundService")
            val binder = service as VoiceAssistantForegroundService.LocalBinder
            assistantService = binder.getService()
            isBound = true
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            AppLogger.w(tag, "ServiceConnection: Disconnected from service")
            assistantService = null
            isBound = false
        }
    }

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val recordAudioGranted = permissions[Manifest.permission.RECORD_AUDIO] ?: false
        AppLogger.i(tag, "Permission result: RECORD_AUDIO granted = $recordAudioGranted")
        if (recordAudioGranted) {
            startAssistantService()
        } else {
            Toast.makeText(this, "Microphone permission needed for Voice AI", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        AppLogger.i(tag, "MainActivity onCreate started")

        try {
            val app = application as AuraApplication
            val database = app.database
            AppLogger.i(tag, "Database initialized successfully")

            // Initialize visible on-device 3B SLM neural engine
            modelLoadManager.initializeModel(lifecycleScope)

            setContent {
                AuraVoiceTheme {
                    var selectedTab by remember { mutableIntStateOf(0) }

                    val assistantState by assistantService?.currentState?.collectAsState()
                        ?: remember { mutableStateOf(AssistantState.IDLE) }
                    val amplitude by assistantService?.amplitude?.collectAsState()
                        ?: remember { mutableFloatStateOf(0f) }
                    val transcript by assistantService?.currentTranscript?.collectAsState()
                        ?: remember { mutableStateOf("") }
                    val response by assistantService?.currentResponse?.collectAsState()
                        ?: remember { mutableStateOf("") }
                    val modelInfo by modelLoadManager.modelInfo.collectAsState()

                    val chatHistory by database.chatMessageDao().getAllMessages().collectAsState(initial = emptyList())
                    val memories by database.memoryDao().getAllMemories().collectAsState(initial = emptyList())

                    Scaffold(
                        bottomBar = {
                            NavigationBar(containerColor = SurfaceDark) {
                                NavigationBarItem(
                                    selected = selectedTab == 0,
                                    onClick = { selectedTab = 0 },
                                    icon = { Icon(Icons.Default.Mic, contentDescription = "Core") },
                                    label = { Text("Core", fontSize = 11.sp, fontFamily = FontFamily.Monospace) },
                                    colors = NavigationBarItemDefaults.colors(
                                        selectedIconColor = NeonCyan,
                                        selectedTextColor = NeonCyan,
                                        unselectedIconColor = TextMuted,
                                        unselectedTextColor = TextMuted,
                                        indicatorColor = SurfaceCard
                                    )
                                )
                                NavigationBarItem(
                                    selected = selectedTab == 1,
                                    onClick = { selectedTab = 1 },
                                    icon = { Icon(Icons.Default.Chat, contentDescription = "Chat") },
                                    label = { Text("Chat", fontSize = 11.sp, fontFamily = FontFamily.Monospace) },
                                    colors = NavigationBarItemDefaults.colors(
                                        selectedIconColor = NeonCyan,
                                        selectedTextColor = NeonCyan,
                                        unselectedIconColor = TextMuted,
                                        unselectedTextColor = TextMuted,
                                        indicatorColor = SurfaceCard
                                    )
                                )
                                NavigationBarItem(
                                    selected = selectedTab == 2,
                                    onClick = { selectedTab = 2 },
                                    icon = { Icon(Icons.Default.Terminal, contentDescription = "Linux") },
                                    label = { Text("Linux", fontSize = 11.sp, fontFamily = FontFamily.Monospace) },
                                    colors = NavigationBarItemDefaults.colors(
                                        selectedIconColor = NeonGreen,
                                        selectedTextColor = NeonGreen,
                                        unselectedIconColor = TextMuted,
                                        unselectedTextColor = TextMuted,
                                        indicatorColor = SurfaceCard
                                    )
                                )
                                NavigationBarItem(
                                    selected = selectedTab == 3,
                                    onClick = { selectedTab = 3 },
                                    icon = { Icon(Icons.Default.Psychology, contentDescription = "Memory") },
                                    label = { Text("Memory", fontSize = 11.sp, fontFamily = FontFamily.Monospace) },
                                    colors = NavigationBarItemDefaults.colors(
                                        selectedIconColor = NeonCyan,
                                        selectedTextColor = NeonCyan,
                                        unselectedIconColor = TextMuted,
                                        unselectedTextColor = TextMuted,
                                        indicatorColor = SurfaceCard
                                    )
                                )
                                NavigationBarItem(
                                    selected = selectedTab == 4,
                                    onClick = { selectedTab = 4 },
                                    icon = { Icon(Icons.Default.Settings, contentDescription = "System") },
                                    label = { Text("System", fontSize = 11.sp, fontFamily = FontFamily.Monospace) },
                                    colors = NavigationBarItemDefaults.colors(
                                        selectedIconColor = NeonCyan,
                                        selectedTextColor = NeonCyan,
                                        unselectedIconColor = TextMuted,
                                        unselectedTextColor = TextMuted,
                                        indicatorColor = SurfaceCard
                                    )
                                )
                            }
                        }
                    ) { innerPadding ->
                        Box(modifier = Modifier.padding(innerPadding)) {
                            when (selectedTab) {
                                0 -> VoiceAssistantScreen(
                                    state = assistantState,
                                    amplitude = amplitude,
                                    transcript = transcript,
                                    response = response,
                                    chatHistory = chatHistory,
                                    isServiceRunning = isBound,
                                    modelInfo = modelInfo,
                                    onToggleService = {
                                        if (isBound) {
                                            stopAssistantService()
                                        } else {
                                            checkPermissionsAndStart()
                                        }
                                    },
                                    onManualVoiceClick = {
                                        if (!isBound) {
                                            checkPermissionsAndStart()
                                        } else {
                                            assistantService?.startListeningCycle()
                                        }
                                    },
                                    onSamplePromptClick = { prompt ->
                                        if (!isBound) {
                                            checkPermissionsAndStart()
                                        }
                                        assistantService?.processUserQuery(prompt)
                                    }
                                )
                                1 -> ChatScreen(
                                    chatHistory = chatHistory,
                                    onSendMessage = { query ->
                                        if (!isBound) {
                                            checkPermissionsAndStart()
                                        }
                                        assistantService?.processUserQuery(query)
                                    },
                                    onVoiceClick = {
                                        selectedTab = 0
                                        if (!isBound) {
                                            checkPermissionsAndStart()
                                        } else {
                                            assistantService?.startListeningCycle()
                                        }
                                    }
                                )
                                2 -> TerminalScreen(
                                    shellEngine = shellEngine
                                )
                                3 -> MemoryViewerScreen(
                                    memories = memories,
                                    onDeleteMemory = { memory ->
                                        lifecycleScope.launch {
                                            database.memoryDao().deleteMemory(memory)
                                        }
                                    },
                                    onClearAllMemories = {
                                        lifecycleScope.launch {
                                            database.memoryDao().clearAllMemories()
                                        }
                                    }
                                )
                                4 -> SettingsScreen()
                            }
                        }
                    }
                }
            }

            AppLogger.i(tag, "MainActivity setContent completed")

            // Check permissions safely without throwing
            checkPermissionsAndStart()

        } catch (t: Throwable) {
            AppLogger.e(tag, "Fatal error inside MainActivity onCreate", t)
            renderCrashFallback(t)
        }
    }

    private fun renderCrashFallback(t: Throwable) {
        setContent {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(DarkBackground)
                    .padding(24.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "AURA CORE RECOVERY MODE",
                        color = NeonPink,
                        fontSize = 18.sp
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = "A diagnostic error occurred during startup:\n${t.message}",
                        color = TextSecondary,
                        fontSize = 13.sp
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        text = "Log written to: /sdcard/Download/aura_app.log",
                        color = NeonCyan,
                        fontSize = 12.sp
                    )
                }
            }
        }
    }

    private fun checkPermissionsAndStart() {
        val permissions = mutableListOf(Manifest.permission.RECORD_AUDIO)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions.add(Manifest.permission.POST_NOTIFICATIONS)
        }

        val missing = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (missing.isNotEmpty()) {
            AppLogger.i(tag, "Requesting missing permissions: $missing")
            permissionLauncher.launch(missing.toTypedArray())
        } else {
            AppLogger.i(tag, "All permissions granted, starting service")
            startAssistantService()
        }
    }

    private fun startAssistantService() {
        try {
            val intent = Intent(this, VoiceAssistantForegroundService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
            AppLogger.i(tag, "startAssistantService executed successfully")
        } catch (e: Exception) {
            AppLogger.e(tag, "Failed to start service: ${e.message}", e)
        }
    }

    private fun stopAssistantService() {
        try {
            if (isBound) {
                unbindService(serviceConnection)
                isBound = false
            }
            val intent = Intent(this, VoiceAssistantForegroundService::class.java)
            stopService(intent)
            AppLogger.i(tag, "stopAssistantService executed")
        } catch (e: Exception) {
            AppLogger.w(tag, "Error stopping service: ${e.message}")
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopAssistantService()
    }
}
