package com.auravoice.assistant.data

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Stores local conversation history between user and Aura.
 */
@Entity(tableName = "chat_history")
data class ChatMessageEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val sender: String, // "user" or "assistant"
    val text: String,
    val timestamp: Long = System.currentTimeMillis()
)
