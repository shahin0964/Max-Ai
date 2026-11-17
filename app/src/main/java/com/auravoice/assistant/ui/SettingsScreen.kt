package com.auravoice.assistant.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material.icons.filled.RecordVoiceOver
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.VolumeUp
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.auravoice.assistant.audio.VoicePersona
import com.auravoice.assistant.ui.theme.*

@Composable
fun SettingsScreen(
    currentPersona: VoicePersona = VoicePersona.JARVIS,
    onPersonaChange: (VoicePersona) -> Unit = {}
) {
    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground)
            .padding(16.dp)
            .verticalScroll(scrollState)
    ) {
        Text(
            text = "Settings & Hardware",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            color = TextPrimary
        )
        Text(
            text = "Offline Model, Voice & Engine Configuration",
            style = MaterialTheme.typography.bodyMedium,
            color = TextSecondary
        )

        Spacer(modifier = Modifier.height(16.dp))

        // 1. Voice Persona & Synthesis Locking Card
        SettingsSectionCard(
            title = "কন্ঠ ও পার্সোনালিটি নির্বাচন (Voice Lock)",
            icon = Icons.Default.RecordVoiceOver,
            subtitle = "ছেলে ও মেয়ে কন্ঠ স্থির রাখুন (Never switches unexpectedly)"
        ) {
            Text(
                text = "অরার কন্ঠ নির্বাচন করুন। এটি একবার সিলেক্ট করলে কখনোই একা একা ছেলে বা মেয়েতে পরিবর্তিত হবে না এবং রোবটিক আওয়াজ মুক্ত থাকবে:",
                color = TextSecondary,
                fontSize = 12.sp,
                lineHeight = 18.sp
            )

            Spacer(modifier = Modifier.height(10.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                // Jarvis Option (Male)
                val isJarvisSelected = currentPersona == VoicePersona.JARVIS
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(10.dp))
                        .background(if (isJarvisSelected) NeonCyan.copy(alpha = 0.15f) else SurfaceDark)
                        .border(
                            width = if (isJarvisSelected) 1.5.dp else 1.dp,
                            color = if (isJarvisSelected) NeonCyan else Color(0xFF262A40),
                            shape = RoundedCornerShape(10.dp)
                        )
                        .clickable { onPersonaChange(VoicePersona.JARVIS) }
                        .padding(12.dp)
                ) {
                    Column {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            RadioButton(
                                selected = isJarvisSelected,
                                onClick = { onPersonaChange(VoicePersona.JARVIS) },
                                colors = RadioButtonDefaults.colors(selectedColor = NeonCyan)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = "JARVIS",
                                color = if (isJarvisSelected) NeonCyan else TextPrimary,
                                fontWeight = FontWeight.Bold,
                                fontSize = 13.sp,
                                fontFamily = FontFamily.Monospace
                            )
                        }
                        Text(
                            text = "পুরুষ কন্ঠ • গভীর ও নিখুঁত স্পিচ",
                            color = TextMuted,
                            fontSize = 10.sp,
                            modifier = Modifier.padding(start = 6.dp)
                        )
                    }
                }

                // Aura Option (Female)
                val isAuraSelected = currentPersona == VoicePersona.AURA
                Box(
                    modifier = Modifier
                        .weight(1f)
                        .clip(RoundedCornerShape(10.dp))
                        .background(if (isAuraSelected) NeonPink.copy(alpha = 0.15f) else SurfaceDark)
                        .border(
                            width = if (isAuraSelected) 1.5.dp else 1.dp,
                            color = if (isAuraSelected) NeonPink else Color(0xFF262A40),
                            shape = RoundedCornerShape(10.dp)
                        )
                        .clickable { onPersonaChange(VoicePersona.AURA) }
                        .padding(12.dp)
                ) {
                    Column {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            RadioButton(
                                selected = isAuraSelected,
                                onClick = { onPersonaChange(VoicePersona.AURA) },
                                colors = RadioButtonDefaults.colors(selectedColor = NeonPink)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = "AURA",
                                color = if (isAuraSelected) NeonPink else TextPrimary,
                                fontWeight = FontWeight.Bold,
                                fontSize = 13.sp,
                                fontFamily = FontFamily.Monospace
                            )
                        }
                        Text(
                            text = "নারী কন্ঠ • মিষ্টি ও সাবলীল সুর",
                            color = TextMuted,
                            fontSize = 10.sp,
                            modifier = Modifier.padding(start = 6.dp)
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // 2. Device Specs
        SettingsSectionCard(
            title = "Device Specs & Compute",
            icon = Icons.Default.Memory,
            subtitle = "Optimized for Snapdragon 8 Gen 2"
        ) {
            SettingRow(label = "Target Phone", value = "Asus ROG 7")
            SettingRow(label = "RAM Capacity", value = "12 GB LPDDR5X")
            SettingRow(label = "Storage", value = "256 GB UFS 4.0")
            SettingRow(label = "LLM Engine", value = "Cognitive Intent + llama.cpp")
        }

        Spacer(modifier = Modifier.height(12.dp))

        // 3. AI Brain
        SettingsSectionCard(
            title = "AI Brain (Model Details)",
            icon = Icons.Default.Info,
            subtitle = "100% Offline Local Inference"
        ) {
            SettingRow(label = "Cognitive Training", value = "Bengali & English Multi-Domain Intent Engine")
            SettingRow(label = "Default Model", value = "Qwen 2.5 3B / Llama 3.2 3B (GGUF)")
            SettingRow(label = "Quantization", value = "Q4_K_M (4-bit)")
            SettingRow(label = "Context Window", value = "4096 tokens")
            SettingRow(label = "API Keys", value = "None (Zero cloud dependancy)")
        }

        Spacer(modifier = Modifier.height(12.dp))

        // 4. Voice & Wake Word
        SettingsSectionCard(
            title = "Voice & Wake Word",
            icon = Icons.Default.VolumeUp,
            subtitle = "Speech Recognition & Synthesis"
        ) {
            SettingRow(label = "Wake Word", value = "\"Hey Aura\" / \"অরা\"")
            SettingRow(label = "STT Languages", value = "Bengali (bn-BD) & English")
            SettingRow(label = "Active Persona", value = currentPersona.displayName)
            SettingRow(label = "Pause Tolerance", value = "4.5 seconds (Unclipped sentences)")
        }

        Spacer(modifier = Modifier.height(12.dp))

        // 5. ROG 7 Background Settings
        SettingsSectionCard(
            title = "ROG 7 Background Settings",
            icon = Icons.Default.Security,
            subtitle = "Ensure continuous always-listening"
        ) {
            Text(
                text = "অরা সবসময় ব্যাকগ্রাউন্ডে সক্রিয় রাখার জন্য ASUS Mobile Manager / Armoury Crate এ গিয়ে \"Auto-start Manager\" চালু রাখুন এবং Battery Optimization \"Unrestricted\" সেট করুন।",
                color = TextSecondary,
                fontSize = 13.sp,
                lineHeight = 20.sp,
                modifier = Modifier.padding(vertical = 4.dp)
            )
        }

        Spacer(modifier = Modifier.height(24.dp))
    }
}

@Composable
fun SettingsSectionCard(
    title: String,
    icon: ImageVector,
    subtitle: String,
    content: @Composable ColumnScope.() -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp)),
        colors = CardDefaults.cardColors(containerColor = SurfaceCard)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(imageVector = icon, contentDescription = title, tint = NeonCyan)
                Spacer(modifier = Modifier.width(10.dp))
                Column {
                    Text(
                        text = title,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = TextPrimary
                    )
                    Text(
                        text = subtitle,
                        style = MaterialTheme.typography.bodyMedium,
                        fontSize = 12.sp,
                        color = TextMuted
                    )
                }
            }
            Spacer(modifier = Modifier.height(12.dp))
            content()
        }
    }
}

@Composable
fun SettingRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 6.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(text = label, color = TextSecondary, fontSize = 13.sp)
        Text(text = value, color = TextPrimary, fontWeight = FontWeight.Medium, fontSize = 13.sp)
    }
}
