package com.auravoice.assistant.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.PowerSettingsNew
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.auravoice.assistant.data.ChatMessageEntity
import com.auravoice.assistant.service.AssistantState
import com.auravoice.assistant.ui.components.ChatBubble
import com.auravoice.assistant.ui.components.GlowingMicOrb
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
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Top Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = "Max AI",
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(8.dp)
                            .clip(RoundedCornerShape(4.dp))
                            .background(if (isServiceRunning) NeonGreen else Color.Gray)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = if (isServiceRunning) "100% Offline Active • ROG 7" else "Service Inactive",
                        style = MaterialTheme.typography.bodyMedium,
                        color = if (isServiceRunning) NeonGreen else TextMuted
                    )
                }
            }

            IconButton(
                onClick = onToggleService,
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(if (isServiceRunning) NeonPurple.copy(alpha = 0.2f) else SurfaceCard)
            ) {
                Icon(
                    imageVector = Icons.Default.PowerSettingsNew,
                    contentDescription = "Toggle Service",
                    tint = if (isServiceRunning) NeonCyan else TextMuted
                )
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // Glowing Orb Center
        GlowingMicOrb(
            state = state,
            amplitude = amplitude,
            onClick = onManualVoiceClick,
            modifier = Modifier.padding(vertical = 12.dp)
        )

        // Status text below orb
        val statusText = when (state) {
            AssistantState.LISTENING -> "শুনছি... কথা বলুন (" + (if (transcript.isBlank()) "\"Hey Aura\" বলুন" else transcript) + ")"
            AssistantState.THINKING -> "অরা চিন্তা করছে (Local 3B Brain)..."
            AssistantState.SPEAKING -> "কথা বলছে..."
            AssistantState.IDLE -> if (isServiceRunning) "বলুন: \"Hey Aura\" বা ট্যাপ করুন" else "সার্ভিস বন্ধ আছে"
        }

        Text(
            text = statusText,
            color = when (state) {
                AssistantState.LISTENING -> NeonCyan
                AssistantState.THINKING -> NeonPurple
                AssistantState.SPEAKING -> NeonGreen
                AssistantState.IDLE -> TextSecondary
            },
            fontWeight = FontWeight.Medium,
            fontSize = 15.sp,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 6.dp)
        )

        Spacer(modifier = Modifier.height(8.dp))

        // Quick Suggestion Chips
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 4.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            SuggestionChip(
                onClick = { onSamplePromptClick("আমার নাম রাসেল, মনে রাখবা") },
                label = { Text("নাম শেখাও", fontSize = 12.sp, color = TextPrimary) },
                colors = SuggestionChipDefaults.suggestionChipColors(containerColor = SurfaceCard)
            )
            SuggestionChip(
                onClick = { onSamplePromptClick("আমার ফোন সম্পর্কে কিছু বলো") },
                label = { Text("আমার ফোন?", fontSize = 12.sp, color = TextPrimary) },
                colors = SuggestionChipDefaults.suggestionChipColors(containerColor = SurfaceCard)
            )
            SuggestionChip(
                onClick = { onSamplePromptClick("তুমি কে?") },
                label = { Text("তুমি কে?", fontSize = 12.sp, color = TextPrimary) },
                colors = SuggestionChipDefaults.suggestionChipColors(containerColor = SurfaceCard)
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Live Chat History / Transcripts
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .clip(RoundedCornerShape(16.dp))
                .background(SurfaceDark)
                .padding(12.dp)
        ) {
            if (chatHistory.isEmpty()) {
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "কোনো পূর্ববর্তী কথোপকথন নেই।\nকথা বলা শুরু করুন, অরা ধীরে ধীরে আপনার সম্পর্কে শিখবে।",
                        color = TextMuted,
                        textAlign = TextAlign.Center,
                        fontSize = 13.sp
                    )
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
