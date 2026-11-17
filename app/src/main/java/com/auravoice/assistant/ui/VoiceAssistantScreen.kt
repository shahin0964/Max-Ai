package com.auravoice.assistant.ui

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.PowerSettingsNew
import androidx.compose.material.icons.filled.Terminal
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.auravoice.assistant.data.ChatMessageEntity
import com.auravoice.assistant.service.AssistantState
import com.auravoice.assistant.ui.components.ChatBubble
import com.auravoice.assistant.ui.components.Jarvis3DReactorOrb
import com.auravoice.assistant.ui.theme.*

@Composable
fun VoiceAssistantScreen(
    state: AssistantState,
    amplitude: Float,
    transcript: String,
    response: String,
    chatHistory: List<ChatMessageEntity>,
    isServiceRunning: Boolean,
    onToggleService: () -> Unit,
    onManualVoiceClick: () -> Unit,
    onSamplePromptClick: (String) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground)
            .padding(14.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // 1. Jarvis Top Telemetry HUD
        JarvisTopHud(
            isServiceRunning = isServiceRunning,
            onToggleService = onToggleService
        )

        Spacer(modifier = Modifier.height(10.dp))

        // 2. Center 3D Arc Reactor Hologram
        Jarvis3DReactorOrb(
            state = state,
            amplitude = amplitude,
            onClick = onManualVoiceClick,
            modifier = Modifier.padding(vertical = 4.dp)
        )

        // 3. Futuristic Status Telemetry Readout
        val statusLabel = when (state) {
            AssistantState.LISTENING -> "JARVIS LISTENING // LIVE MIC ACTIVE"
            AssistantState.THINKING -> "NEURAL 3B REASONING // ON-DEVICE"
            AssistantState.SPEAKING -> "VOCAL SYNTHESIZER ACTIVE"
            AssistantState.IDLE -> if (isServiceRunning) "STANDBY // SAY \"HEY AURA\" OR TAP REACTOR" else "CORE INACTIVE // TAP POWER TO START"
        }

        Box(
            modifier = Modifier
                .clip(RoundedCornerShape(8.dp))
                .border(
                    width = 1.dp,
                    color = when (state) {
                        AssistantState.LISTENING -> NeonCyan
                        AssistantState.THINKING -> NeonPurple
                        AssistantState.SPEAKING -> Color(0xFF00FFCC)
                        AssistantState.IDLE -> TextMuted.copy(alpha = 0.4f)
                    },
                    shape = RoundedCornerShape(8.dp)
                )
                .background(SurfaceCard.copy(alpha = 0.7f))
                .padding(horizontal = 14.dp, vertical = 6.dp)
        ) {
            Text(
                text = statusLabel,
                color = when (state) {
                    AssistantState.LISTENING -> NeonCyan
                    AssistantState.THINKING -> NeonPurple
                    AssistantState.SPEAKING -> Color(0xFF00FFCC)
                    AssistantState.IDLE -> TextSecondary
                },
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                fontFamily = FontFamily.Monospace,
                letterSpacing = 1.sp
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Live Transcript Box (when user is speaking)
        if (transcript.isNotBlank()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(10.dp))
                    .background(Color(0xFF0F172A))
                    .border(1.dp, NeonCyan.copy(alpha = 0.5f), RoundedCornerShape(10.dp))
                    .padding(10.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Terminal,
                        contentDescription = "Terminal",
                        tint = NeonCyan,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = transcript,
                        color = TextPrimary,
                        fontSize = 13.sp,
                        fontFamily = FontFamily.Monospace,
                        maxLines = 2
                    )
                }
            }
            Spacer(modifier = Modifier.height(8.dp))
        }

        // 4. Quick Jarvis Action Chips
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 4.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            JarvisActionChip(label = "// WHO_AM_I") {
                onSamplePromptClick("তুমি কে?")
            }
            JarvisActionChip(label = "// LEARN_USER") {
                onSamplePromptClick("আমার নাম রাসেল, মনে রাখবা")
            }
            JarvisActionChip(label = "// PHONE_SPECS") {
                onSamplePromptClick("আমার ফোন সম্পর্কে কিছু বলো")
            }
        }

        Spacer(modifier = Modifier.height(6.dp))

        // 5. Holographic Conversation Log
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .clip(RoundedCornerShape(14.dp))
                .background(SurfaceDark.copy(alpha = 0.85f))
                .border(1.dp, Color(0xFF262A40), RoundedCornerShape(14.dp))
                .padding(10.dp)
        ) {
            if (chatHistory.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "[ AURA NEURAL TERMINAL READY ]",
                            color = NeonCyan.copy(alpha = 0.8f),
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold,
                            fontFamily = FontFamily.Monospace
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = "কথা বলুন বা ওয়েক ওয়ার্ড দিন: \"Hey Aura\" / \"অরা\"\nঅরা আপনার কথা শুনে তার মেমোরি স্বয়ংক্রিয়ভাবে আপডেট করবে।",
                            color = TextMuted,
                            textAlign = TextAlign.Center,
                            fontSize = 12.sp,
                            lineHeight = 18.sp
                        )
                    }
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    reverseLayout = true
                ) {
                    items(chatHistory.reversed()) { message ->
                        ChatBubble(message = message)
                    }
                }
            }
        }
    }
}

@Composable
fun JarvisTopHud(
    isServiceRunning: Boolean,
    onToggleService: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(SurfaceCard.copy(alpha = 0.6f))
            .border(1.dp, Color(0xFF25293E), RoundedCornerShape(12.dp))
            .padding(horizontal = 12.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = "AURA",
                    color = NeonCyan,
                    fontWeight = FontWeight.ExtraBold,
                    fontSize = 18.sp,
                    fontFamily = FontFamily.Monospace,
                    letterSpacing = 2.sp
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = "// JARVIS v3.2",
                    color = TextMuted,
                    fontSize = 11.sp,
                    fontFamily = FontFamily.Monospace
                )
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(6.dp)
                        .clip(RoundedCornerShape(3.dp))
                        .background(if (isServiceRunning) NeonGreen else Color.Gray)
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = if (isServiceRunning) "CORE: ONLINE • ROG 7 (12GB RAM)" else "CORE: STANDBY",
                    fontSize = 10.sp,
                    color = if (isServiceRunning) NeonGreen else TextMuted,
                    fontFamily = FontFamily.Monospace
                )
            }
        }

        IconButton(
            onClick = onToggleService,
            modifier = Modifier
                .size(36.dp)
                .clip(RoundedCornerShape(10.dp))
                .background(
                    if (isServiceRunning) NeonCyan.copy(alpha = 0.15f) else Color(0xFF202336)
                )
        ) {
            Icon(
                imageVector = Icons.Default.PowerSettingsNew,
                contentDescription = "Power",
                tint = if (isServiceRunning) NeonCyan else TextMuted,
                modifier = Modifier.size(20.dp)
            )
        }
    }
}

@Composable
fun RowScope.JarvisActionChip(label: String, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = Modifier.weight(1f).height(32.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = SurfaceCard,
            contentColor = TextPrimary
        ),
        shape = RoundedCornerShape(8.dp),
        contentPadding = PaddingValues(horizontal = 4.dp, vertical = 2.dp)
    ) {
        Text(
            text = label,
            fontSize = 10.sp,
            fontFamily = FontFamily.Monospace,
            fontWeight = FontWeight.SemiBold,
            maxLines = 1
        )
    }
}
