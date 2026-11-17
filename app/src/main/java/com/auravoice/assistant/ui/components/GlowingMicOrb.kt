package com.auravoice.assistant.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material.icons.filled.VolumeUp
import androidx.compose.material3.Icon
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.auravoice.assistant.service.AssistantState
import com.auravoice.assistant.ui.theme.*

@Composable
fun GlowingMicOrb(
    state: AssistantState,
    amplitude: Float,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val infiniteTransition = rememberInfiniteTransition(label = "orbPulse")

    // Idle breathing animation
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 0.95f,
        targetValue = 1.05f,
        animationSpec = infiniteRepeatable(
            animation = tween(1500, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulse"
    )

    // Dynamic scale based on state and real-time voice amplitude
    val currentScale = when (state) {
        AssistantState.LISTENING -> (1.0f + amplitude * 0.45f).coerceIn(1.0f, 1.45f)
        AssistantState.THINKING -> pulseScale * 1.08f
        AssistantState.SPEAKING -> (1.05f + amplitude * 0.35f).coerceIn(1.0f, 1.35f)
        AssistantState.IDLE -> pulseScale
    }

    val glowColors = when (state) {
        AssistantState.LISTENING -> listOf(NeonCyan, Color(0xFF00BFFF), Color.Transparent)
        AssistantState.THINKING -> listOf(NeonPurple, NeonPink, Color.Transparent)
        AssistantState.SPEAKING -> listOf(NeonGreen, NeonCyan, Color.Transparent)
        AssistantState.IDLE -> listOf(NeonCyan.copy(alpha = 0.5f), NeonPurple.copy(alpha = 0.3f), Color.Transparent)
    }

    val coreColors = when (state) {
        AssistantState.LISTENING -> listOf(NeonCyan, Color(0xFF0077FF))
        AssistantState.THINKING -> listOf(NeonPurple, NeonPink)
        AssistantState.SPEAKING -> listOf(NeonGreen, Color(0xFF009944))
        AssistantState.IDLE -> listOf(SurfaceCard, Color(0xFF282B40))
    }

    Box(
        contentAlignment = Alignment.Center,
        modifier = modifier
            .size(220.dp)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick
            )
    ) {
        // Outer glowing blur layer
        Box(
            modifier = Modifier
                .size(170.dp)
                .scale(currentScale)
                .clip(CircleShape)
                .background(Brush.radialGradient(glowColors))
                .blur(25.dp)
        )

        // Mid neon aura layer
        Box(
            modifier = Modifier
                .size(130.dp)
                .scale(currentScale)
                .clip(CircleShape)
                .background(Brush.radialGradient(glowColors))
        )

        // Core interactive button
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier
                .size(90.dp)
                .clip(CircleShape)
                .background(Brush.linearGradient(coreColors))
        ) {
            val icon = when (state) {
                AssistantState.LISTENING -> Icons.Default.Mic
                AssistantState.THINKING -> Icons.Default.Psychology
                AssistantState.SPEAKING -> Icons.Default.VolumeUp
                AssistantState.IDLE -> Icons.Default.Mic
            }

            Icon(
                imageVector = icon,
                contentDescription = "Voice Orb",
                tint = TextPrimary,
                modifier = Modifier.size(42.dp)
            )
        }
    }
}
