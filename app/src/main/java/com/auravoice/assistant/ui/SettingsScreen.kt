package com.auravoice.assistant.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Memory
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.VolumeUp
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.auravoice.assistant.ui.theme.*

@Composable
fun SettingsScreen() {
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
            text = "Offline Model & Engine Configuration",
            style = MaterialTheme.typography.bodyMedium,
            color = TextSecondary
        )

        Spacer(modifier = Modifier.height(16.dp))

        SettingsSectionCard(
            title = "Device Specs & Compute",
            icon = Icons.Default.Memory,
            subtitle = "Optimized for Snapdragon 8 Gen 2"
        ) {
            SettingRow(label = "Target Phone", value = "Asus ROG 7")
            SettingRow(label = "RAM Capacity", value = "12 GB LPDDR5X")
            SettingRow(label = "Storage", value = "256 GB UFS 4.0")
            SettingRow(label = "LLM Engine", value = "llama.cpp on Adreno 740")
        }

        Spacer(modifier = Modifier.height(12.dp))

        SettingsSectionCard(
            title = "AI Brain (Model Details)",
            icon = Icons.Default.Info,
            subtitle = "100% Offline Local Inference"
        ) {
            SettingRow(label = "Default Model", value = "Qwen 2.5 3B / Llama 3.2 3B")
            SettingRow(label = "Quantization", value = "Q4_K_M (4-bit)")
            SettingRow(label = "Context Window", value = "4096 tokens")
            SettingRow(label = "API Keys", value = "None (Zero cloud dependancy)")
        }

        Spacer(modifier = Modifier.height(12.dp))

        SettingsSectionCard(
            title = "Voice & Wake Word",
            icon = Icons.Default.VolumeUp,
            subtitle = "Speech Recognition & Synthesis"
        ) {
            SettingRow(label = "Wake Word", value = "\"Hey Aura\" / \"অরা\"")
            SettingRow(label = "STT Languages", value = "Bengali (bn-BD) & English")
            SettingRow(label = "TTS Engine", value = "Offline Neural Engine")
        }

        Spacer(modifier = Modifier.height(12.dp))

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
