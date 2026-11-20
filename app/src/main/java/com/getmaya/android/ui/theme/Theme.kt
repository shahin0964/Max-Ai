package com.getmaya.android.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val DarkColorScheme = darkColorScheme(
    primary = MayaPrimary,
    onPrimary = Color.White,
    primaryContainer = MayaPrimaryDark,
    onPrimaryContainer = Color.White,
    secondary = MayaAccentCyan,
    onSecondary = Color.Black,
    background = MayaBackground,
    onBackground = MayaTextPrimary,
    surface = MayaSurface,
    onSurface = MayaTextPrimary,
    surfaceVariant = MayaSurfaceElevated,
    onSurfaceVariant = MayaTextSecondary,
    outline = MayaBorder
)

@Composable
fun MayaTheme(
    darkTheme: Boolean = true,
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        typography = MayaTypography,
        content = content
    )
}
