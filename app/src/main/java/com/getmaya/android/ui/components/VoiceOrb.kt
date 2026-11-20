package com.getmaya.android.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.getmaya.android.audio.AssistantState
import com.getmaya.android.ui.theme.MayaAccentCyan
import com.getmaya.android.ui.theme.MayaAccentPink
import com.getmaya.android.ui.theme.MayaPrimary
import kotlin.math.sin

@Composable
fun VoiceOrb(
    state: AssistantState,
    amplitude: Float,
    modifier: Modifier = Modifier,
    size: Dp = 160.dp
) {
    val infiniteTransition = rememberInfiniteTransition(label = "orb")
    val pulse by infiniteTransition.animateFloat(
        initialValue = 0.85f,
        targetValue = 1.15f,
        animationSpec = infiniteRepeatable(
            animation = tween(1400, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulse"
    )

    val rotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(4000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "rotation"
    )

    val (coreColor, glowColor) = when (state) {
        AssistantState.LISTENING -> Pair(MayaAccentCyan, Color(0x6600E5FF))
        AssistantState.THINKING -> Pair(MayaPrimary, Color(0x667C4DFF))
        AssistantState.SPEAKING -> Pair(MayaAccentPink, Color(0x66FF4081))
        AssistantState.IDLE -> Pair(Color(0xFF5C6BC0), Color(0x335C6BC0))
    }

    Box(
        modifier = modifier.size(size),
        contentAlignment = Alignment.Center
    ) {
        Canvas(modifier = Modifier.size(size)) {
            val center = Offset(size.toPx() / 2, size.toPx() / 2)
            val baseRadius = (size.toPx() / 3) * (if (state == AssistantState.LISTENING) (pulse + amplitude * 1.5f) else pulse)

            // Outer Aura
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(glowColor, Color.Transparent),
                    center = center,
                    radius = baseRadius * 1.6f
                ),
                radius = baseRadius * 1.6f,
                center = center
            )

            // Neural Ring Waves
            val waveCount = 8
            for (i in 0 until waveCount) {
                val angle = Math.toRadians((rotation + i * (360f / waveCount)).toDouble())
                val offsetDist = baseRadius * (1f + 0.15f * sin(angle * 2).toFloat())
                val waveX = center.x + (offsetDist * kotlin.math.cos(angle)).toFloat()
                val waveY = center.y + (offsetDist * kotlin.math.sin(angle)).toFloat()
                drawCircle(
                    color = coreColor.copy(alpha = 0.4f),
                    radius = 4.dp.toPx(),
                    center = Offset(waveX, waveY)
                )
            }

            // Central Core
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(Color.White, coreColor),
                    center = center,
                    radius = baseRadius
                ),
                radius = baseRadius,
                center = center
            )
        }
    }
}
