package com.auravoice.assistant.data

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * Represents a learned fact or preference about the user.
 * This is the core of on-device continuous training / memory.
 */
@Entity(tableName = "user_memories")
data class MemoryEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val category: String, // e.g., "PROFILE", "PREFERENCE", "HABIT", "RELATION", "NOTE"
    val fact: String,     // e.g., "User's name is Rasel", "Loves gaming on ROG Phone 7"
    val confidence: Float = 1.0f,
    val timestamp: Long = System.currentTimeMillis()
)
