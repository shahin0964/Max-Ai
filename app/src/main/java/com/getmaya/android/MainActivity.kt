package com.getmaya.android

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import com.getmaya.android.agentic.AgenticEngine
import com.getmaya.android.audio.AssistantState
import com.getmaya.android.audio.AudioPipelineManager
import com.getmaya.android.audio.PocketTtsManager
import com.getmaya.android.automation.DeviceController
import com.getmaya.android.automation.MayaAccessibilityService
import com.getmaya.android.core.MayaForegroundService
import com.getmaya.android.termux.TermuxBridge
import com.getmaya.android.ui.screens.*
import com.getmaya.android.ui.theme.*
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private lateinit var audioPipeline: AudioPipelineManager
    private lateinit var ttsManager: PocketTtsManager
    private lateinit var agenticEngine: AgenticEngine

    private val requestPermissionsLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { _ -> }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        audioPipeline = AudioPipelineManager(this)
        ttsManager = PocketTtsManager(this)
        agenticEngine = AgenticEngine(this)

        checkAndRequestPermissions()
        startForegroundCoreService()

        setContent {
            MayaTheme {
                MayaAppRoot(
                    audioPipeline = audioPipeline,
                    ttsManager = ttsManager,
                    agenticEngine = agenticEngine,
                    onExecuteTermuxCommand = { cmd ->
                        lifecycleScope.launch {
                            TermuxBridge.executeCommand(this@MainActivity, cmd)
                        }
                    },
                    onToggleTorch = { on ->
                        DeviceController.setTorch(this@MainActivity, on)
                    },
                    onSetVolume = { vol ->
                        DeviceController.setVolume(this@MainActivity, vol)
                    },
                    onReadScreen = {
                        val text = MayaAccessibilityService.instance?.extractScreenText() ?: "Accessibility not enabled"
                        lifecycleScope.launch {
                            agenticEngine.processUserPrompt("Screen Text: $text", "Maya")
                        }
                    }
                )
            }
        }
    }

    private fun checkAndRequestPermissions() {
        val permissions = mutableListOf(
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.CAMERA
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions.add(Manifest.permission.POST_NOTIFICATIONS)
        }
        val needed = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (needed.isNotEmpty()) {
            requestPermissionsLauncher.launch(needed.toTypedArray())
        }
    }

    private fun startForegroundCoreService() {
        val intent = Intent(this, MayaForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        audioPipeline.stopListening()
        ttsManager.destroy()
    }
}

enum class Screen {
    VOICE,
    CHAT,
    TERMINAL_REEL,
    TOOLS,
    SETTINGS
}

@Composable
fun MayaAppRoot(
    audioPipeline: AudioPipelineManager,
    ttsManager: PocketTtsManager,
    agenticEngine: AgenticEngine,
    onExecuteTermuxCommand: (String) -> Unit,
    onToggleTorch: (Boolean) -> Unit,
    onSetVolume: (Int) -> Unit,
    onReadScreen: () -> Unit
) {
    val coroutineScope = rememberCoroutineScope()
    var currentScreen by remember { mutableStateOf(Screen.VOICE) }
    var selectedPersona by remember { mutableStateOf("Maya") }

    var apiKey by remember { mutableStateOf("") }
    var provider by remember { mutableStateOf("Groq") }
    var model by remember { mutableStateOf("llama-3.3-70b-versatile") }

    var showVoiceOverlay by remember { mutableStateOf(false) }
    var transcribedVoiceText by remember { mutableStateOf("") }
    var assistantSpeechReply by remember { mutableStateOf("") }

    val assistantState by audioPipeline.state.collectAsState()
    val amplitude by audioPipeline.audioAmplitude.collectAsState()
    val isProcessing by agenticEngine.isProcessing.collectAsState()
    val agentStatus by agenticEngine.agentStatus.collectAsState()

    val messagesFlow = remember {
        MayaApplication.instance.database.chatMessageDao().getAllMessagesFlow()
    }
    val messages by messagesFlow.collectAsState(initial = emptyList())

    var terminalLogs by remember { mutableStateOf(listOf<Pair<String, String>>()) }
    LaunchedEffect(Unit) {
        TermuxBridge.commandOutputs.collect { output ->
            terminalLogs = terminalLogs + output
        }
    }

    Scaffold(
        bottomBar = {
            NavigationBar(
                containerColor = MayaSurface,
                tonalElevation = 8.dp
            ) {
                NavigationBarItem(
                    selected = currentScreen == Screen.VOICE,
                    onClick = { currentScreen = Screen.VOICE },
                    icon = { Icon(Icons.Default.Mic, contentDescription = "Voice") },
                    label = { Text("Voice") },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = MayaAccentCyan,
                        selectedTextColor = MayaAccentCyan,
                        indicatorColor = MayaSurfaceElevated,
                        unselectedIconColor = MayaTextSecondary,
                        unselectedTextColor = MayaTextSecondary
                    )
                )

                NavigationBarItem(
                    selected = currentScreen == Screen.CHAT,
                    onClick = { currentScreen = Screen.CHAT },
                    icon = { Icon(Icons.Default.ChatBubble, contentDescription = "Chat") },
                    label = { Text("Chat") },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = MayaPrimary,
                        selectedTextColor = MayaPrimary,
                        indicatorColor = MayaSurfaceElevated,
                        unselectedIconColor = MayaTextSecondary,
                        unselectedTextColor = MayaTextSecondary
                    )
                )

                NavigationBarItem(
                    selected = currentScreen == Screen.TERMINAL_REEL,
                    onClick = { currentScreen = Screen.TERMINAL_REEL },
                    icon = { Icon(Icons.Default.Terminal, contentDescription = "Terminal") },
                    label = { Text("Termux") },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = TerminalGreen,
                        selectedTextColor = TerminalGreen,
                        indicatorColor = MayaSurfaceElevated,
                        unselectedIconColor = MayaTextSecondary,
                        unselectedTextColor = MayaTextSecondary
                    )
                )

                NavigationBarItem(
                    selected = currentScreen == Screen.TOOLS,
                    onClick = { currentScreen = Screen.TOOLS },
                    icon = { Icon(Icons.Default.Build, contentDescription = "Tools") },
                    label = { Text("Tools") },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = MayaAccentCyan,
                        selectedTextColor = MayaAccentCyan,
                        indicatorColor = MayaSurfaceElevated,
                        unselectedIconColor = MayaTextSecondary,
                        unselectedTextColor = MayaTextSecondary
                    )
                )

                NavigationBarItem(
                    selected = currentScreen == Screen.SETTINGS,
                    onClick = { currentScreen = Screen.SETTINGS },
                    icon = { Icon(Icons.Default.Settings, contentDescription = "Settings") },
                    label = { Text("Settings") },
                    colors = NavigationBarItemDefaults.colors(
                        selectedIconColor = MayaAccentCyan,
                        selectedTextColor = MayaAccentCyan,
                        indicatorColor = MayaSurfaceElevated,
                        unselectedIconColor = MayaTextSecondary,
                        unselectedTextColor = MayaTextSecondary
                    )
                )
            }
        },
        containerColor = MayaBackground
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            when (currentScreen) {
                Screen.VOICE -> {
                    VoiceHomeScreen(
                        state = assistantState,
                        amplitude = amplitude,
                        selectedPersona = selectedPersona,
                        onPersonaSelected = { selectedPersona = it },
                        transcription = transcribedVoiceText,
                        onMicClicked = {
                            if (assistantState == AssistantState.LISTENING) {
                                audioPipeline.stopListening()
                            } else {
                                transcribedVoiceText = ""
                                assistantSpeechReply = ""
                                audioPipeline.startListening { voiceText ->
                                    transcribedVoiceText = voiceText
                                    coroutineScope.launch {
                                        audioPipeline.setThinking()
                                        val reply = agenticEngine.processUserPrompt(
                                            prompt = voiceText,
                                            persona = selectedPersona,
                                            apiKey = apiKey,
                                            provider = provider,
                                            modelName = model
                                        )
                                        assistantSpeechReply = reply
                                        audioPipeline.setSpeaking()
                                        ttsManager.speak(reply, selectedPersona) {
                                            audioPipeline.setIdle()
                                        }
                                    }
                                }
                            }
                        },
                        onQuickPrompt = { prompt ->
                            coroutineScope.launch {
                                agenticEngine.processUserPrompt(
                                    prompt = prompt,
                                    persona = selectedPersona,
                                    apiKey = apiKey,
                                    provider = provider,
                                    modelName = model
                                )
                                currentScreen = Screen.CHAT
                            }
                        }
                    )
                }

                Screen.CHAT -> {
                    ChatScreen(
                        messages = messages,
                        selectedPersona = selectedPersona,
                        onPersonaSelected = { selectedPersona = it },
                        onSendMessage = { text ->
                            coroutineScope.launch {
                                agenticEngine.processUserPrompt(
                                    prompt = text,
                                    persona = selectedPersona,
                                    apiKey = apiKey,
                                    provider = provider,
                                    modelName = model
                                )
                            }
                        },
                        onStartVoice = {
                            showVoiceOverlay = true
                            transcribedVoiceText = ""
                            assistantSpeechReply = ""
                            audioPipeline.startListening { voiceText ->
                                transcribedVoiceText = voiceText
                                coroutineScope.launch {
                                    audioPipeline.setThinking()
                                    val reply = agenticEngine.processUserPrompt(
                                        prompt = voiceText,
                                        persona = selectedPersona,
                                        apiKey = apiKey,
                                        provider = provider,
                                        modelName = model
                                    )
                                    assistantSpeechReply = reply
                                    audioPipeline.setSpeaking()
                                    ttsManager.speak(reply, selectedPersona) {
                                        audioPipeline.setIdle()
                                    }
                                }
                            }
                        },
                        onOpenTerminal = { currentScreen = Screen.TERMINAL_REEL },
                        onOpenSettings = { currentScreen = Screen.SETTINGS },
                        isProcessing = isProcessing,
                        agentStatus = agentStatus
                    )
                }

                Screen.TERMINAL_REEL -> {
                    TerminalReelScreen(
                        outputs = terminalLogs,
                        onExecuteCommand = onExecuteTermuxCommand,
                        onBack = { currentScreen = Screen.VOICE }
                    )
                }

                Screen.TOOLS -> {
                    ToolsScreen(
                        onToggleTorch = onToggleTorch,
                        onSetVolume = onSetVolume,
                        onRunMacro = { macroName ->
                            coroutineScope.launch {
                                agenticEngine.processUserPrompt("run macro $macroName", selectedPersona)
                            }
                        },
                        onReadScreen = onReadScreen,
                        onOpenTerminal = { currentScreen = Screen.TERMINAL_REEL }
                    )
                }

                Screen.SETTINGS -> {
                    SettingsScreen(
                        currentApiKey = apiKey,
                        currentProvider = provider,
                        currentModel = model,
                        onSaveSettings = { key, prov, mod ->
                            apiKey = key
                            provider = prov
                            model = mod
                            currentScreen = Screen.VOICE
                        },
                        onBack = { currentScreen = Screen.VOICE }
                    )
                }
            }

            // Voice Assistant Overlay HUD
            AnimatedVisibility(
                visible = showVoiceOverlay,
                enter = fadeIn() + slideInVertically(initialOffsetY = { it / 2 }),
                exit = fadeOut() + slideOutVertically(targetOffsetY = { it / 2 })
            ) {
                VoiceAssistantScreen(
                    state = assistantState,
                    amplitude = amplitude,
                    transcribedText = transcribedVoiceText,
                    assistantReply = assistantSpeechReply,
                    persona = selectedPersona,
                    onStopVoice = {
                        audioPipeline.stopListening()
                        ttsManager.stop()
                        showVoiceOverlay = false
                    },
                    onDismiss = {
                        audioPipeline.stopListening()
                        ttsManager.stop()
                        showVoiceOverlay = false
                    }
                )
            }
        }
    }
}
