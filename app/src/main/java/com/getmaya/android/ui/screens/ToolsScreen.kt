package com.getmaya.android.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.getmaya.android.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ToolsScreen(
    onToggleTorch: (Boolean) -> Unit,
    onSetVolume: (Int) -> Unit,
    onRunMacro: (String) -> Unit,
    onReadScreen: () -> Unit,
    onOpenTerminal: () -> Unit
) {
    var torchOn by remember { mutableStateOf(false) }
    var volumeSlider by remember { mutableStateOf(0.7f) }
    var screenTextResult by remember { mutableStateOf("") }

    val builtinMacros = remember {
        listOf(
            "open_whatsapp_chat" to "Open WhatsApp chat and focus input",
            "open_youtube_trending" to "Open YouTube and scroll to trending",
            "termux_check_system" to "Run system diagnostics in Termux",
            "toggle_wifi_settings" to "Launch Wi-Fi configuration screen",
            "silence_phone" to "Set media & notification volume to zero"
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Tools & Automations", color = MayaTextPrimary, fontWeight = FontWeight.Bold) },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = MayaSurface)
            )
        },
        containerColor = MayaBackground
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Hardware Quick Toggles
            item {
                Text("Device Hardware", color = MayaAccentCyan, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    DeviceTile(
                        title = "Flashlight",
                        subtitle = if (torchOn) "ON" else "OFF",
                        icon = if (torchOn) Icons.Default.FlashlightOn else Icons.Default.FlashlightOff,
                        isActive = torchOn,
                        onClick = {
                            torchOn = !torchOn
                            onToggleTorch(torchOn)
                        },
                        modifier = Modifier.weight(1f)
                    )

                    DeviceTile(
                        title = "Terminal",
                        subtitle = "Termux Bridge",
                        icon = Icons.Default.Terminal,
                        isActive = true,
                        activeColor = TerminalGreen,
                        onClick = onOpenTerminal,
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            // Volume Slider
            item {
                Card(
                    colors = CardDefaults.cardColors(containerColor = MayaSurface),
                    shape = RoundedCornerShape(14.dp)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("Media Volume", color = MayaTextPrimary, fontWeight = FontWeight.SemiBold)
                            Text("${(volumeSlider * 100).toInt()}%", color = MayaAccentCyan, fontWeight = FontWeight.Bold)
                        }
                        Slider(
                            value = volumeSlider,
                            onValueChange = {
                                volumeSlider = it
                                onSetVolume((it * 100).toInt())
                            },
                            colors = SliderDefaults.colors(
                                thumbColor = MayaAccentCyan,
                                activeTrackColor = MayaAccentCyan,
                                inactiveTrackColor = MayaSurfaceElevated
                            )
                        )
                    }
                }
            }

            // Screen Automation
            item {
                Text("Screen Perception", color = MayaAccentCyan, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                Spacer(modifier = Modifier.height(8.dp))
                Card(
                    colors = CardDefaults.cardColors(containerColor = MayaSurface),
                    shape = RoundedCornerShape(14.dp)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text("Accessibility Node Inspection", color = MayaTextPrimary, fontWeight = FontWeight.SemiBold)
                        Text(
                            "Maya reads all text elements visible on any active app on your phone.",
                            color = MayaTextSecondary,
                            fontSize = 12.5.sp,
                            modifier = Modifier.padding(vertical = 4.dp)
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Button(
                            onClick = onReadScreen,
                            colors = ButtonDefaults.buttonColors(containerColor = MayaPrimary),
                            shape = RoundedCornerShape(8.dp)
                        ) {
                            Icon(Icons.Default.Visibility, contentDescription = null, modifier = Modifier.size(18.dp))
                            Spacer(modifier = Modifier.width(8.dp))
                            Text("Inspect Active Screen")
                        }
                    }
                }
            }

            // Builtin Macros
            item {
                Text("Automation Macros", color = MayaAccentCyan, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                Spacer(modifier = Modifier.height(8.dp))
            }

            items(builtinMacros) { (name, desc) ->
                Card(
                    colors = CardDefaults.cardColors(containerColor = MayaSurfaceElevated),
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(14.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(name, color = MayaTextPrimary, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                            Text(desc, color = MayaTextSecondary, fontSize = 12.sp)
                        }
                        IconButton(
                            onClick = { onRunMacro(name) },
                            modifier = Modifier
                                .clip(RoundedCornerShape(8.dp))
                                .background(MayaPrimary.copy(alpha = 0.2f))
                        ) {
                            Icon(Icons.Default.PlayArrow, contentDescription = "Run", tint = MayaAccentCyan)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun DeviceTile(
    title: String,
    subtitle: String,
    icon: ImageVector,
    isActive: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    activeColor: Color = MayaPrimary
) {
    Card(
        modifier = modifier.clickable { onClick() },
        colors = CardDefaults.cardColors(
            containerColor = if (isActive) activeColor.copy(alpha = 0.15f) else MayaSurface
        ),
        shape = RoundedCornerShape(14.dp),
        border = if (isActive) CardDefaults.outlinedCardBorder().copy(brush = androidx.compose.ui.graphics.SolidColor(activeColor)) else null
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = title,
                tint = if (isActive) activeColor else MayaTextSecondary,
                modifier = Modifier.size(28.dp)
            )
            Column {
                Text(title, color = MayaTextPrimary, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                Text(subtitle, color = if (isActive) activeColor else MayaTextSecondary, fontSize = 12.sp)
            }
        }
    }
}
