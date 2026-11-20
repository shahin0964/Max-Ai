package com.getmaya.android.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Save
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.getmaya.android.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    currentApiKey: String,
    currentProvider: String,
    currentModel: String,
    onSaveSettings: (apiKey: String, provider: String, model: String) -> Unit,
    onBack: () -> Unit
) {
    var apiKey by remember { mutableStateOf(currentApiKey) }
    var selectedProvider by remember { mutableStateOf(currentProvider) }
    var selectedModel by remember { mutableStateOf(currentModel) }
    var wakeWordEnabled by remember { mutableStateOf(true) }
    var voiceGuardianEnabled by remember { mutableStateOf(true) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings & Neural Engines", color = MayaTextPrimary, fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = MayaTextPrimary)
                    }
                },
                actions = {
                    IconButton(onClick = { onSaveSettings(apiKey, selectedProvider, selectedModel) }) {
                        Icon(Icons.Default.Save, contentDescription = "Save", tint = MayaAccentCyan)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = MayaSurface)
            )
        },
        containerColor = MayaBackground
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Section: LLM Model Configuration
            Card(
                colors = CardDefaults.cardColors(containerColor = MayaSurface),
                shape = RoundedCornerShape(12.dp)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("LLM Intelligence Provider", fontWeight = FontWeight.Bold, color = MayaTextPrimary, fontSize = 16.sp)
                    Spacer(modifier = Modifier.height(10.dp))

                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        listOf("Groq", "Gemini", "OpenRouter").forEach { provider ->
                            val isSel = provider.equals(selectedProvider, ignoreCase = true)
                            FilterChip(
                                selected = isSel,
                                onClick = {
                                    selectedProvider = provider
                                    selectedModel = when (provider) {
                                        "Gemini" -> "gemini-2.5-flash"
                                        "OpenRouter" -> "meta-llama/llama-3.3-70b-instruct"
                                        else -> "llama-3.3-70b-versatile"
                                    }
                                },
                                label = { Text(provider) }
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    Text("API Key", color = MayaTextSecondary, fontSize = 13.sp)
                    Spacer(modifier = Modifier.height(4.dp))
                    TextField(
                        value = apiKey,
                        onValueChange = { apiKey = it },
                        placeholder = { Text("gsk_... or AIzaSy...", color = MayaTextSecondary) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(8.dp)),
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = MayaSurfaceElevated,
                            unfocusedContainerColor = MayaSurfaceElevated,
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        ),
                        singleLine = true
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    Text("Active Model", color = MayaTextSecondary, fontSize = 13.sp)
                    Spacer(modifier = Modifier.height(4.dp))
                    TextField(
                        value = selectedModel,
                        onValueChange = { selectedModel = it },
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(8.dp)),
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = MayaSurfaceElevated,
                            unfocusedContainerColor = MayaSurfaceElevated,
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        ),
                        singleLine = true
                    )
                }
            }

            // Section: Voice & Speech Gate
            Card(
                colors = CardDefaults.cardColors(containerColor = MayaSurface),
                shape = RoundedCornerShape(12.dp)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Voice & Acoustic Pipeline", fontWeight = FontWeight.Bold, color = MayaTextPrimary, fontSize = 16.sp)
                    Spacer(modifier = Modifier.height(12.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text("Wake Word Detection", color = MayaTextPrimary, fontSize = 14.5.sp)
                            Text("\"Hey Maya\", \"Hello Maya\" (TFLite)", color = MayaTextSecondary, fontSize = 12.sp)
                        }
                        Switch(checked = wakeWordEnabled, onCheckedChange = { wakeWordEnabled = it })
                    }

                    HorizontalDivider(modifier = Modifier.padding(vertical = 12.dp), color = MayaBorder)

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text("Voice Guardian (Speaker Lock)", color = MayaTextPrimary, fontSize = 14.5.sp)
                            Text("Silero VAD + ReDimNet2 Speaker Recognition", color = MayaTextSecondary, fontSize = 12.sp)
                        }
                        Switch(checked = voiceGuardianEnabled, onCheckedChange = { voiceGuardianEnabled = it })
                    }
                }
            }

            // Section: System & Automation Bridges
            Card(
                colors = CardDefaults.cardColors(containerColor = MayaSurface),
                shape = RoundedCornerShape(12.dp)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Automation Bridges", fontWeight = FontWeight.Bold, color = MayaTextPrimary, fontSize = 16.sp)
                    Spacer(modifier = Modifier.height(10.dp))
                    Text("• Termux RUN_COMMAND Bridge: Active", color = TerminalGreen, fontSize = 13.sp)
                    Text("• Accessibility Screen Control: Supported", color = MayaAccentCyan, fontSize = 13.sp)
                    Text("• WhatsApp & Notification Bridge: Integrated", color = MayaAccentCyan, fontSize = 13.sp)
                }
            }
        }
    }
}
