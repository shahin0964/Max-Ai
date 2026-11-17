package com.auravoice.assistant.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Send
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.auravoice.assistant.data.ChatMessageEntity
import com.auravoice.assistant.ui.components.ChatBubble
import com.auravoice.assistant.ui.theme.*
import kotlinx.coroutines.launch

@Composable
fun ChatScreen(
    chatHistory: List<ChatMessageEntity>,
    onSendMessage: (String) -> Unit,
    onVoiceClick: () -> Unit
) {
    var textInput by remember { mutableStateOf("") }
    val listState = rememberLazyListState()
    val coroutineScope = rememberCoroutineScope()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground)
            .padding(horizontal = 14.dp, vertical = 8.dp)
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
                    text = "AURA CONVERSATION MATRIX",
                    color = NeonCyan,
                    fontSize = 15.sp,
                    fontWeight = FontWeight.Bold,
                    fontFamily = FontFamily.Monospace,
                    letterSpacing = 1.sp
                )
                Text(
                    text = "100% Offline Chat & Phone Control",
                    color = TextMuted,
                    fontSize = 11.sp,
                    fontFamily = FontFamily.Monospace
                )
            }
        }

        // Chat Message List
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
                    Text(
                        text = "ম্যাক্স/অরা-কে টেক্সট মেসেজ পাঠান বা আদেশ দিন:\n\n\"ইউটিউব ওপেন করো\"\n\"ফ্ল্যাশলাইট জ্বালাও\"\n\"ব্যাটারি কত?\"\n\"আমার নাম রাসেল, মনে রাখবা\"",
                        color = TextMuted,
                        fontSize = 13.sp,
                        lineHeight = 22.sp,
                        fontFamily = FontFamily.Monospace,
                        textAlign = androidx.compose.ui.text.style.TextAlign.Center
                    )
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    state = listState,
                    reverseLayout = true
                ) {
                    items(chatHistory.reversed()) { message ->
                        ChatBubble(message = message)
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        // Quick Command Suggestions
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 2.dp),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            SuggestionChip(
                onClick = { onSendMessage("ইউটিউব ওপেন করো") },
                label = { Text("Open YouTube", fontSize = 11.sp, color = TextPrimary) },
                colors = SuggestionChipDefaults.suggestionChipColors(containerColor = SurfaceCard)
            )
            SuggestionChip(
                onClick = { onSendMessage("ফ্ল্যাশলাইট জ্বালাও") },
                label = { Text("ফ্ল্যাশলাইট", fontSize = 11.sp, color = TextPrimary) },
                colors = SuggestionChipDefaults.suggestionChipColors(containerColor = SurfaceCard)
            )
            SuggestionChip(
                onClick = { onSendMessage("ব্যাটারি কত?") },
                label = { Text("ব্যাটারি লেভেল", fontSize = 11.sp, color = TextPrimary) },
                colors = SuggestionChipDefaults.suggestionChipColors(containerColor = SurfaceCard)
            )
        }

        Spacer(modifier = Modifier.height(6.dp))

        // Chat Input Box
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(24.dp))
                .background(SurfaceCard)
                .border(1.dp, NeonCyan.copy(alpha = 0.4f), RoundedCornerShape(24.dp))
                .padding(horizontal = 8.dp, vertical = 4.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            TextField(
                value = textInput,
                onValueChange = { textInput = it },
                placeholder = {
                    Text(
                        text = "অরা-কে মেসেজ বা আদেশ লিখুন...",
                        color = TextMuted,
                        fontSize = 13.sp
                    )
                },
                modifier = Modifier
                    .weight(1f)
                    .background(Color.Transparent),
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent,
                    unfocusedContainerColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                    focusedTextColor = TextPrimary,
                    unfocusedTextColor = TextPrimary
                ),
                maxLines = 3
            )

            IconButton(
                onClick = onVoiceClick,
                modifier = Modifier
                    .size(38.dp)
                    .clip(CircleShape)
                    .background(NeonPurple.copy(alpha = 0.2f))
            ) {
                Icon(
                    imageVector = Icons.Default.Mic,
                    contentDescription = "Mic",
                    tint = NeonCyan,
                    modifier = Modifier.size(20.dp)
                )
            }

            Spacer(modifier = Modifier.width(4.dp))

            IconButton(
                onClick = {
                    val msg = textInput.trim()
                    if (msg.isNotBlank()) {
                        onSendMessage(msg)
                        textInput = ""
                        coroutineScope.launch {
                            listState.animateScrollToItem(0)
                        }
                    }
                },
                modifier = Modifier
                    .size(38.dp)
                    .clip(CircleShape)
                    .background(NeonCyan)
            ) {
                Icon(
                    imageVector = Icons.Default.ArrowUpward,
                    contentDescription = "Send",
                    tint = DarkBackground,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}
