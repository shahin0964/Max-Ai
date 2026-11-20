package com.getmaya.android.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.getmaya.android.audio.AssistantState
import com.getmaya.android.ui.components.VoiceOrb
import com.getmaya.android.ui.theme.*

@Composable
fun VoiceHomeScreen(
    state: AssistantState,
    amplitude: Float,
    selectedPersona: String,
    onPersonaSelected: (String) -> Unit,
    onMicClicked: () -> Unit,
    onQuickPrompt: (String) -> Unit,
    transcription: String = ""
) {
    val quickPrompts = listOf(
        QuickPrompt("🚀 Check Termux", "Run uname -a in Termux", Icons.Default.Terminal),
        QuickPrompt("☀️ Weather Today", "What is the weather today?", Icons.Default.WbSunny),
        QuickPrompt("🔦 Flashlight ON", "Turn on the flashlight", Icons.Default.FlashlightOn),
        QuickPrompt("🎵 Play Music", "Play relaxing music on YouTube", Icons.Default.PlayCircle),
        QuickPrompt("💬 WhatsApp", "Send a WhatsApp message", Icons.Default.Chat)
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MayaBackground)
            .padding(horizontal = 20.dp, vertical = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        // Top Header
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                Box(
                    modifier = Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(TerminalGreen)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = "VOICE GUARDIAN ACTIVE",
                    color = TerminalGreen,
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.5.sp
                )
            }
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = "Listening for \"Hey Maya\"",
                color = MayaTextSecondary,
                fontSize = 13.sp
            )
            Spacer(modifier = Modifier.height(14.dp))

            // Persona Selector
            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                listOf("Maya", "Friday", "Venom").forEach { persona ->
                    val isSel = persona.equals(selectedPersona, ignoreCase = true)
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(16.dp))
                            .background(if (isSel) MayaPrimary else MayaSurfaceElevated)
                            .clickable { onPersonaSelected(persona) }
                            .padding(horizontal = 14.dp, vertical = 6.dp)
                    ) {
                        Text(
                            text = persona,
                            color = if (isSel) Color.White else MayaTextSecondary,
                            fontSize = 12.5.sp,
                            fontWeight = FontWeight.SemiBold
                        )
                    }
                }
            }
        }

        // Center Voice Orb
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(vertical = 16.dp)
        ) {
            VoiceOrb(
                state = state,
                amplitude = amplitude,
                size = 220.dp
            )

            Spacer(modifier = Modifier.height(20.dp))

            Text(
                text = when (state) {
                    AssistantState.LISTENING -> "Maya is listening..."
                    AssistantState.THINKING -> "Reasoning & Executing Tools..."
                    AssistantState.SPEAKING -> "Maya is speaking..."
                    AssistantState.IDLE -> "Tap mic or say 'Hey Maya'"
                },
                color = if (state == AssistantState.LISTENING) MayaAccentCyan else MayaTextPrimary,
                fontSize = 17.sp,
                fontWeight = FontWeight.SemiBold,
                textAlign = TextAlign.Center
            )

            if (transcription.isNotBlank()) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "\"$transcription\"",
                    color = MayaAccentCyan,
                    fontSize = 14.sp,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(horizontal = 16.dp)
                )
            }
        }

        // Bottom Section: Quick suggestions & Big Mic button
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.fillMaxWidth()
        ) {
            LazyRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(quickPrompts) { item ->
                    Card(
                        modifier = Modifier.clickable { onQuickPrompt(item.prompt) },
                        colors = CardDefaults.cardColors(containerColor = MayaSurfaceElevated),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(item.icon, contentDescription = null, tint = MayaAccentCyan, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(item.title, color = MayaTextPrimary, fontSize = 12.5.sp, fontWeight = FontWeight.Medium)
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Main Trigger Button
            IconButton(
                onClick = onMicClicked,
                modifier = Modifier
                    .size(72.dp)
                    .clip(CircleShape)
                    .background(if (state == AssistantState.LISTENING) MayaAccentPink else MayaPrimary)
            ) {
                Icon(
                    imageVector = if (state == AssistantState.LISTENING) Icons.Default.Stop else Icons.Default.Mic,
                    contentDescription = "Voice Trigger",
                    tint = Color.White,
                    modifier = Modifier.size(36.dp)
                )
            }
        }
    }
}

data class QuickPrompt(
    val title: String,
    val prompt: String,
    val icon: ImageVector
)
