package com.auravoice.assistant.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.auravoice.assistant.data.MemoryEntity
import com.auravoice.assistant.ui.theme.*

@Composable
fun MemoryViewerScreen(
    memories: List<MemoryEntity>,
    onDeleteMemory: (MemoryEntity) -> Unit,
    onClearAllMemories: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(DarkBackground)
            .padding(16.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = "Aura Memory",
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )
                Text(
                    text = "কথা শুনে অর্জিত তথ্য (${memories.size} টি স্মৃতি)",
                    style = MaterialTheme.typography.bodyMedium,
                    color = NeonCyan
                )
            }

            if (memories.isNotEmpty()) {
                IconButton(onClick = onClearAllMemories) {
                    Icon(
                        imageVector = Icons.Default.Delete,
                        contentDescription = "Clear All",
                        tint = NeonPink
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        if (memories.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(32.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        imageVector = Icons.Default.Psychology,
                        contentDescription = "Memory",
                        tint = TextMuted,
                        modifier = Modifier.size(64.dp)
                    )
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        text = "এখনো কোনো মেমোরি শেখেনি।\n\nআপনি যখন কথা বলবেন, যেমন:\n\"আমার নাম রাসেল\"\n\"আমি গেম খেলতে পছন্দ করি\"\n\"মনে রাখবা কাল সকালে মিটিং আছে\"\n\nঅরা স্বয়ংক্রিয়ভাবে এগুলো শিখে এখানে মনে রাখবে।",
                        color = TextSecondary,
                        textAlign = TextAlign.Center,
                        fontSize = 14.sp,
                        lineHeight = 22.sp
                    )
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(memories, key = { it.id }) { memory ->
                    MemoryItemCard(memory = memory, onDelete = { onDeleteMemory(memory) })
                }
            }
        }
    }
}

@Composable
fun MemoryItemCard(
    memory: MemoryEntity,
    onDelete: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp)),
        colors = CardDefaults.cardColors(containerColor = SurfaceCard)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(4.dp))
                        .background(NeonPurple.copy(alpha = 0.2f))
                        .padding(horizontal = 6.dp, vertical = 2.dp)
                ) {
                    Text(
                        text = memory.category,
                        color = NeonCyan,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = memory.fact,
                    color = TextPrimary,
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Medium
                )
            }

            IconButton(onClick = onDelete) {
                Icon(
                    imageVector = Icons.Default.Delete,
                    contentDescription = "Delete memory",
                    tint = TextMuted,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}
