package com.auravoice.assistant.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Badge
import androidx.compose.material.icons.filled.Check
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
import com.auravoice.assistant.audio.AssistantIdentityManager
import com.auravoice.assistant.audio.VoicePersona
import com.auravoice.assistant.ui.theme.*

@Composable
fun SettingsScreen(
    currentPersona: VoicePersona = VoicePersona.JARVIS,
    onPersonaChange: (VoicePersona) -> Unit = {},
    identityManager: AssistantIdentityManager? = null
) {
    val scrollState = rememberScrollState()

    val currentIdentity = remember { identityManager?.getIdentity() }
    var assistantName by remember { mutableStateOf(currentIdentity?.assistantName ?: "Aura") }
    var wakeWord by remember { mutableStateOf(currentIdentity?.primaryWakeWord ?: "Hey Aura") }
    var userCallsign by remember { mutableStateOf(currentIdentity?.userCallsign ?: "স্যার") }
    var isSaved by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground)
            .padding(16.dp)
            .verticalScroll(scrollState)
    ) {
        Text(
            text = "Settings & Identity",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            color = TextPrimary
        )
        Text(
            text = "অ্যাসিস্ট্যান্টের নাম, ওয়েক-ওয়ার্ড ও ব্রেন কাস্টমাইজেশন",
            style = MaterialTheme.typography.bodyMedium,
            color = TextSecondary
        )

        Spacer(modifier = Modifier.height(16.dp))

        // 1. Assistant Identity & Custom Wake Word Customization Card
        SettingsSectionCard(
            title = "অ্যাসিস্ট্যান্ট নাম ও ওয়েক-ওয়ার্ড (Wake Word)",
            icon = Icons.Default.Badge,
            subtitle = "নিজের পছন্দমতো নাম ও ওয়েক-ওয়ার্ড সেট করুন"
        ) {
            Text(
                text = "আপনি যেকোনো নাম (যেমন জার্ভিস, ম্যাক্স, অরা) ও ওয়েক-ওয়ার্ড দিতে পারেন। অরা সাথে সাথে সেই নামে সাড়া দেবে:",
                color = TextSecondary,
                fontSize = 12.sp,
                lineHeight = 18.sp
            )

            Spacer(modifier = Modifier.height(10.dp))

            // Preset Quick Selection Chips
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                FilterChip(
                    selected = assistantName == "Jarvis",
                    onClick = {
                        assistantName = "Jarvis"
                        wakeWord = "Hey Jarvis"
                        onPersonaChange(VoicePersona.JARVIS)
                        isSaved = false
                    },
                    label = { Text("Jarvis (জার্ভিস)", fontSize = 11.sp) },
                    colors = FilterChipDefaults.filterChipColors(selectedContainerColor = NeonCyan.copy(alpha = 0.2f))
                )
                FilterChip(
                    selected = assistantName == "Aura",
                    onClick = {
                        assistantName = "Aura"
                        wakeWord = "Hey Aura"
                        onPersonaChange(VoicePersona.AURA)
                        isSaved = false
                    },
                    label = { Text("Aura (অরা)", fontSize = 11.sp) },
                    colors = FilterChipDefaults.filterChipColors(selectedContainerColor = NeonPink.copy(alpha = 0.2f))
                )
                FilterChip(
                    selected = assistantName == "Max",
                    onClick = {
                        assistantName = "Max"
                        wakeWord = "Hey Max"
                        onPersonaChange(VoicePersona.JARVIS)
                        isSaved = false
                    },
                    label = { Text("Max (ম্যাক্স)", fontSize = 11.sp) },
                    colors = FilterChipDefaults.filterChipColors(selectedContainerColor = NeonCyan.copy(alpha = 0.2f))
                )
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Field 1: Assistant Name
            OutlinedTextField(
                value = assistantName,
                onValueChange = {
                    assistantName = it
                    isSaved = false
                },
                label = { Text("অ্যাসিস্ট্যান্টের নাম (Assistant Name)", fontSize = 12.sp) },
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = NeonCyan,
                    unfocusedBorderColor = Color(0xFF262A40),
                    focusedTextColor = TextPrimary,
                    unfocusedTextColor = TextPrimary
                )
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Field 2: Custom Wake Word
            OutlinedTextField(
                value = wakeWord,
                onValueChange = {
                    wakeWord = it
                    isSaved = false
                },
                label = { Text("কাস্টম ওয়েক-ওয়ার্ড (Custom Wake Word)", fontSize = 12.sp) },
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = NeonCyan,
                    unfocusedBorderColor = Color(0xFF262A40),
                    focusedTextColor = TextPrimary,
                    unfocusedTextColor = TextPrimary
                )
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Field 3: User Callsign
            OutlinedTextField(
                value = userCallsign,
                onValueChange = {
                    userCallsign = it
                    isSaved = false
                },
                label = { Text("আপনাকে ডাকার সম্বোধন (User Callsign / Name)", fontSize = 12.sp) },
                singleLine = true,
                modifier = Modifier.fillMaxWidth(),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = NeonCyan,
                    unfocusedBorderColor = Color(0xFF262A40),
                    focusedTextColor = TextPrimary,
                    unfocusedTextColor = TextPrimary
                )
            )

            Spacer(modifier = Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (isSaved) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Check, contentDescription = "Saved", tint = NeonGreen, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("নাম ও ওয়েক-ওয়ার্ড সেভ হয়েছে!", color = NeonGreen, fontSize = 12.sp)
                    }
                } else {
                    Spacer(modifier = Modifier.width(1.dp))
                }

                Button(
                    onClick = {
                        identityManager?.updateIdentity(
                            name = assistantName,
                            wakeWord = wakeWord,
                            userCallsign = userCallsign
                        )
                        isSaved = true
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = NeonCyan, contentColor = DarkBackground),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Text("সেভ করুন (Save)", fontWeight = FontWeight.Bold)
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        // 2. Voice Persona Locking Card
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

        // 3. Autonomous Web Intelligence Card
        SettingsSectionCard(
            title = "অটোনোমাস ওয়েব ইন্টেলিজেন্স (Web Research)",
            icon = Icons.Default.Info,
            subtitle = "অনলাইনে লাইভ অনুসন্ধান ও অটো-মেমোরি সংরক্ষণ"
        ) {
            SettingRow(label = "লাইভ ইন্টারনেট সার্চ", value = "সক্রিয় (Wikipedia + DDG)")
            SettingRow(label = "অটো-মেমোরি সেভ", value = "সক্রিয় (অফলাইনেও মনে রাখবে)")
            SettingRow(label = "অফলাইন অ্যালার্ট", value = "ইন্টারনেট না থাকলে সাথে সাথে জানাবে")
        }

        Spacer(modifier = Modifier.height(12.dp))

        // 4. Device Specs
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
