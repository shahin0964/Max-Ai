package com.getmaya.android.data.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "chat_messages")
data class ChatMessageEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val text: String,
    val sender: String, // "user", "maya", "system", "tool"
    val timestamp: Long = System.currentTimeMillis(),
    val persona: String = "Maya", // Maya, Friday, Venom
    val toolCallJson: String? = null,
    val toolResultJson: String? = null
)

@Entity(tableName = "memories")
data class MemoryEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val key: String,
    val content: String,
    val category: String = "general", // user_preference, contact, fact, note
    val timestamp: Long = System.currentTimeMillis()
)

@Entity(tableName = "macros")
data class MacroEntity(
    @PrimaryKey
    val name: String,
    val description: String,
    val stepsJson: String,
    val isBuiltin: Boolean = false
)
