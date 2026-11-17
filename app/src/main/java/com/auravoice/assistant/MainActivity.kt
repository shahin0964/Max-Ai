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
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import com.auravoice.assistant.data.ChatMessageEntity
import com.auravoice.assistant.service.AssistantState
import com.auravoice.assistant.service.VoiceAssistantForegroundService
import com.auravoice.assistant.ui.MemoryViewerScreen
import com.auravoice.assistant.ui.SettingsScreen
import com.auravoice.assistant.ui.VoiceAssistantScreen
import com.auravoice.assistant.ui.theme.*
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private var assistantService: VoiceAssistantForegroundService? = null
    private var isBound = false

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            val binder = service as VoiceAssistantForegroundService.LocalBinder
            assistantService = binder.getService()
            isBound = true
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            assistantService = null
            isBound = false
        }
    }

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val recordAudioGranted = permissions[Manifest.permission.RECORD_AUDIO] ?: false
        if (recordAudioGranted) {
            startAssistantService()
        } else {
            Toast.makeText(this, "Microphone permission needed for Aura Voice AI", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Request permissions safely
        checkPermissions()

        val app = application as AuraApplication
        val database = app.database

        setContent {
            AuraVoiceTheme {
                var selectedTab by remember { mutableIntStateOf(0) }

                // Collect service states
                val assistantState by assistantService?.currentState?.collectAsState()
                    ?: remember { mutableStateOf(AssistantState.IDLE) }
                val amplitude by assistantService?.amplitude?.collectAsState()
                    ?: remember { mutableFloatStateOf(0f) }
                val transcript by assistantService?.currentTranscript?.collectAsState()
                    ?: remember { mutableStateOf("") }
                val response by assistantService?.currentResponse?.collectAsState()
                    ?: remember { mutableStateOf("") }

                // Collect database flows safely
                val chatHistory by database.chatMessageDao().getAllMessages().collectAsState(initial = emptyList())
                val memories by database.memoryDao().getAllMemories().collectAsState(initial = emptyList())

                Scaffold(
                    bottomBar = {
                        NavigationBar(containerColor = SurfaceDark) {
                            NavigationBarItem(
                                selected = selectedTab == 0,
                                onClick = { selectedTab = 0 },
                                icon = { Icon(Icons.Default.Mic, contentDescription = "Reactor") },
                                label = { Text("Core") },
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
                                icon = { Icon(Icons.Default.Psychology, contentDescription = "Memory") },
                                label = { Text("Memory") },
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
                                icon = { Icon(Icons.Default.Settings, contentDescription = "Diagnostics") },
                                label = { Text("System") },
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
                                onToggleService = {
                                    if (isBound) {
                                        stopAssistantService()
                                    } else {
                                        startAssistantService()
                                    }
                                },
                                onManualVoiceClick = {
                                    if (!isBound) {
                                        startAssistantService()
                                    } else {
                                        assistantService?.startListeningCycle()
                                    }
                                },
                                onSamplePromptClick = { prompt ->
                                    if (!isBound) {
                                        startAssistantService()
                                    }
                                    assistantService?.processUserQuery(prompt)
                                }
                            )
                            1 -> MemoryViewerScreen(
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
                            2 -> SettingsScreen()
                        }
                    }
                }
            }
        }
    }

    private fun checkPermissions() {
        val permissions = mutableListOf(Manifest.permission.RECORD_AUDIO)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions.add(Manifest.permission.POST_NOTIFICATIONS)
        }

        val missing = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (missing.isNotEmpty()) {
            permissionLauncher.launch(missing.toTypedArray())
        } else {
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
        } catch (e: Exception) {
            Toast.makeText(this, "Service init note: ${e.message}", Toast.LENGTH_SHORT).show()
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
        } catch (e: Exception) {
            // Safe teardown
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopAssistantService()
    }
}
