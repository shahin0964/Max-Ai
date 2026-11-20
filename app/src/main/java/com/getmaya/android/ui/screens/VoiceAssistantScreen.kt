package com.getmaya.android.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Stop
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.getmaya.android.audio.AssistantState
import com.getmaya.android.ui.components.VoiceOrb
import com.getmaya.android.ui.theme.*

@Composable
fun VoiceAssistantScreen(
    state: AssistantState,
    amplitude: Float,
    transcribedText: String,
    assistantReply: String,
    persona: String,
    onStopVoice: () -> Unit,
    onDismiss: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xE60A0C14))
            .padding(24.dp)
    ) {
        // Dismiss Button
        IconButton(
            onClick = onDismiss,
            modifier = Modifier
                .align(Alignment.TopEnd)
                .clip(CircleShape)
                .background(MayaSurfaceElevated)
        ) {
            Icon(Icons.Default.Close, contentDescription = "Close", tint = MayaTextSecondary)
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(vertical = 40.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // Header
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = persona.uppercase(),
                    color = MayaAccentCyan,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 2.sp
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = when (state) {
                        AssistantState.LISTENING -> "Listening to your voice..."
                        AssistantState.THINKING -> "Reasoning & Executing Tools..."
                        AssistantState.SPEAKING -> "Speaking..."
                        AssistantState.IDLE -> "Standby"
                    },
                    color = MayaTextPrimary,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Medium
                )
            }

            // Central Glowing Voice Orb
            VoiceOrb(
                state = state,
                amplitude = amplitude,
                size = 200.dp
            )

            // Transcription & Output
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.fillMaxWidth()
            ) {
                if (transcribedText.isNotBlank()) {
                    Text(
                        text = "\"$transcribedText\"",
                        color = MayaTextPrimary,
                        fontSize = 16.sp,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(horizontal = 20.dp)
                    )
                }

                if (assistantReply.isNotBlank()) {
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = assistantReply,
                        color = MayaAccentCyan,
                        fontSize = 15.sp,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(horizontal = 20.dp)
                    )
                }

                Spacer(modifier = Modifier.height(30.dp))

                // Stop / Action Button
                IconButton(
                    onClick = onStopVoice,
                    modifier = Modifier
                        .size(64.dp)
                        .clip(CircleShape)
                        .background(if (state == AssistantState.LISTENING) MayaAccentPink else MayaPrimary)
                ) {
                    Icon(
                        imageVector = if (state == AssistantState.LISTENING) Icons.Default.Stop else Icons.Default.Mic,
                        contentDescription = "Control Voice",
                        tint = Color.White,
                        modifier = Modifier.size(32.dp)
                    )
                }
            }
        }
    }
}
