package com.auravoice.assistant.data

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface MemoryDao {
    @Query("SELECT * FROM user_memories ORDER BY timestamp DESC")
    fun getAllMemories(): Flow<List<MemoryEntity>>

    @Query("SELECT * FROM user_memories ORDER BY timestamp DESC LIMIT :limit")
    suspend fun getRecentMemories(limit: Int = 20): List<MemoryEntity>

    @Query("SELECT * FROM user_memories WHERE fact LIKE '%' || :query || '%' ORDER BY timestamp DESC")
    suspend fun searchMemories(query: String): List<MemoryEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMemory(memory: MemoryEntity): Long

    @Delete
    suspend fun deleteMemory(memory: MemoryEntity)

    @Query("DELETE FROM user_memories")
    suspend fun clearAllMemories()
}
