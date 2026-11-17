package com.auravoice.assistant.data

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface ChatMessageDao {
    @Query("SELECT * FROM chat_history ORDER BY timestamp ASC")
    fun getAllMessages(): Flow<List<ChatMessageEntity>>

    @Query("SELECT * FROM chat_history ORDER BY timestamp DESC LIMIT :limit")
    suspend fun getRecentMessages(limit: Int = 10): List<ChatMessageEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMessage(message: ChatMessageEntity): Long

    @Query("DELETE FROM chat_history")
    suspend fun clearHistory()
}
