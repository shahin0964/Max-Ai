package com.auravoice.assistant.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.rotate
import androidx.compose.ui.unit.dp
import com.auravoice.assistant.service.AssistantState
import com.auravoice.assistant.ui.theme.*
import kotlin.math.*

/**
 * Jarvis 3D Holographic Arc Reactor Orb:
 * Features multi-axis rotating 3D gyroscope rings, segmented reactor plates,
 * pulsing plasma energy core, and audio-reactive frequency rays.
 */
@Composable
fun Jarvis3DReactorOrb(
    state: AssistantState,
    amplitude: Float,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val infiniteTransition = rememberInfiniteTransition(label = "jarvisCore")

    // Continuous 3D Gyroscope Rotations
    val outerRotation by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(12000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "outerRing"
    )

    val gyroRotation1 by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(6000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "gyro1"
    )

    val gyroRotation2 by infiniteTransition.animateFloat(
        initialValue = 360f,
        targetValue = 0f,
        animationSpec = infiniteRepeatable(
            animation = tween(8000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "gyro2"
    )

    val corePulse by infiniteTransition.animateFloat(
        initialValue = 0.92f,
        targetValue = 1.08f,
        animationSpec = infiniteRepeatable(
            animation = tween(1400, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "corePulse"
    )

    // Dynamic energy speed and scale based on assistant state and voice amplitude
    val speedMultiplier = when (state) {
        AssistantState.LISTENING -> 2.2f
        AssistantState.THINKING -> 3.5f
        AssistantState.SPEAKING -> 2.5f
        AssistantState.IDLE -> 1.0f
    }

    val dynamicPulse = when (state) {
        AssistantState.LISTENING -> 1.0f + amplitude * 0.55f
        AssistantState.THINKING -> corePulse * 1.15f
        AssistantState.SPEAKING -> 1.05f + amplitude * 0.45f
        AssistantState.IDLE -> corePulse
    }

    val primaryColor = when (state) {
        AssistantState.LISTENING -> NeonCyan
        AssistantState.THINKING -> NeonPurple
        AssistantState.SPEAKING -> Color(0xFF00FFCC)
        AssistantState.IDLE -> NeonCyan
    }

    val secondaryColor = when (state) {
        AssistantState.LISTENING -> Color(0xFF0077FF)
        AssistantState.THINKING -> NeonPink
        AssistantState.SPEAKING -> Color(0xFF00FF66)
        AssistantState.IDLE -> Color(0xFF0055AA)
    }

    Box(
        contentAlignment = Alignment.Center,
        modifier = modifier
            .size(280.dp)
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick
            )
    ) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val center = Offset(size.width / 2f, size.height / 2f)
            val baseRadius = size.minDimension / 2f * 0.88f

            // 1. Draw outer audio-reactive frequency ticks / equalizer rays
            drawEqualizerRays(center, baseRadius, amplitude, state, primaryColor)

            // 2. Draw Outer HUD Degree Ring with rotating tick marks
            drawOuterHudRing(center, baseRadius * 0.92f, outerRotation * speedMultiplier, primaryColor)

            // 3. Draw 3D Gyroscope Ring 1 (Tilted X/Y projection)
            draw3DGyroRing(
                center = center,
                radius = baseRadius * 0.78f,
                angle = gyroRotation1 * speedMultiplier,
                tiltX = 0.45f,
                color = primaryColor.copy(alpha = 0.85f),
                strokeWidth = 3.5f
            )

            // 4. Draw 3D Gyroscope Ring 2 (Opposite counter-tilted projection)
            draw3DGyroRing(
                center = center,
                radius = baseRadius * 0.68f,
                angle = gyroRotation2 * speedMultiplier,
                tiltX = -0.55f,
                color = secondaryColor.copy(alpha = 0.75f),
                strokeWidth = 2.5f
            )

            // 5. Draw Segmented Arc Reactor Core Ring (8 power plates)
            drawSegmentedReactorRing(
                center = center,
                radius = baseRadius * 0.52f,
                rotation = outerRotation * 0.5f * speedMultiplier,
                color = primaryColor
            )

            // 6. Draw Central Pulsing Plasma Core
            drawPlasmaCore(
                center = center,
                radius = baseRadius * 0.36f * dynamicPulse,
                primaryColor = primaryColor,
                secondaryColor = secondaryColor
            )

            // 7. Core Energy Ring & Spark nodes
            drawCircle(
                color = primaryColor,
                radius = baseRadius * 0.36f * dynamicPulse,
                center = center,
                style = Stroke(width = 3f)
            )

            drawCircle(
                color = Color.White,
                radius = baseRadius * 0.12f * dynamicPulse,
                center = center
            )
        }
    }
}

private fun DrawScope.drawOuterHudRing(
    center: Offset,
    radius: Float,
    rotation: Float,
    color: Color
) {
    rotate(rotation, center) {
        // Main circular track
        drawCircle(
            color = color.copy(alpha = 0.35f),
            radius = radius,
            center = center,
            style = Stroke(width = 1.5f)
        )

        // 36 HUD tick marks around the ring
        val totalTicks = 36
        for (i in 0 until totalTicks) {
            val angleDeg = (i * 360f / totalTicks)
            val angleRad = Math.toRadians(angleDeg.toDouble()).toFloat()
            val isMajor = i % 3 == 0
            val tickLength = if (isMajor) 10f else 5f
            val startR = radius - tickLength
            val endR = radius

            val start = Offset(
                center.x + startR * cos(angleRad),
                center.y + startR * sin(angleRad)
            )
            val end = Offset(
                center.x + endR * cos(angleRad),
                center.y + endR * sin(angleRad)
            )

            drawLine(
                color = if (isMajor) color.copy(alpha = 0.9f) else color.copy(alpha = 0.4f),
                start = start,
                end = end,
                strokeWidth = if (isMajor) 2f else 1f
            )
        }
    }
}

private fun DrawScope.draw3DGyroRing(
    center: Offset,
    radius: Float,
    angle: Float,
    tiltX: Float,
    color: Color,
    strokeWidth: Float
) {
    rotate(angle, center) {
        val ovalWidth = radius * 2f
        val ovalHeight = radius * 2f * abs(cos(tiltX))

        drawOval(
            color = color,
            topLeft = Offset(center.x - radius, center.y - (ovalHeight / 2f)),
            size = Size(ovalWidth, ovalHeight),
            style = Stroke(width = strokeWidth)
        )

        // 3D Orbital Energy Nodes
        val nodeAngle1 = Math.toRadians(angle.toDouble()).toFloat()
        val nodeX = center.x + radius * cos(nodeAngle1)
        val nodeY = center.y + (ovalHeight / 2f) * sin(nodeAngle1)
        drawCircle(
            color = Color.White,
            radius = 4f,
            center = Offset(nodeX, nodeY)
        )
    }
}

private fun DrawScope.drawSegmentedReactorRing(
    center: Offset,
    radius: Float,
    rotation: Float,
    color: Color
) {
    rotate(rotation, center) {
        val segments = 8
        val sweepAngle = 360f / segments
        val gapAngle = 10f
        val arcSweep = sweepAngle - gapAngle

        for (i in 0 until segments) {
            val startAngle = i * sweepAngle
            drawArc(
                color = color.copy(alpha = 0.85f),
                startAngle = startAngle,
                sweepAngle = arcSweep,
                useCenter = false,
                topLeft = Offset(center.x - radius, center.y - radius),
                size = Size(radius * 2f, radius * 2f),
                style = Stroke(width = 6f, cap = StrokeCap.Round)
            )
        }
    }
}

private fun DrawScope.drawPlasmaCore(
    center: Offset,
    radius: Float,
    primaryColor: Color,
    secondaryColor: Color
) {
    // Multi-layer radial glow
    val glowBrush = Brush.radialGradient(
        colors = listOf(
            Color.White,
            primaryColor,
            secondaryColor.copy(alpha = 0.6f),
            Color.Transparent
        ),
        center = center,
        radius = radius * 1.6f
    )

    drawCircle(
        brush = glowBrush,
        radius = radius * 1.5f,
        center = center
    )
}

private fun DrawScope.drawEqualizerRays(
    center: Offset,
    baseRadius: Float,
    amplitude: Float,
    state: AssistantState,
    color: Color
) {
    if (state == AssistantState.IDLE && amplitude < 0.05f) return

    val rayCount = 48
    val maxRayLength = 26f + amplitude * 36f

    for (i in 0 until rayCount) {
        val angleDeg = i * (360f / rayCount)
        val angleRad = Math.toRadians(angleDeg.toDouble()).toFloat()
        // Wave pattern
        val waveFactor = sin(i * 0.6f) * 0.5f + 0.5f
        val rayLength = (maxRayLength * waveFactor * (amplitude + 0.2f)).coerceAtLeast(3f)

        val startR = baseRadius + 3f
        val endR = startR + rayLength

        val start = Offset(
            center.x + startR * cos(angleRad),
            center.y + startR * sin(angleRad)
        )
        val end = Offset(
            center.x + endR * cos(angleRad),
            center.y + endR * sin(angleRad)
        )

        drawLine(
            color = color.copy(alpha = 0.6f + amplitude * 0.4f),
            start = start,
            end = end,
            strokeWidth = 2f,
            cap = StrokeCap.Round
        )
    }
}
