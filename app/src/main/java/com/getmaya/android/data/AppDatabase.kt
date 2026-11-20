package com.getmaya.android.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.getmaya.android.data.dao.ChatMessageDao
import com.getmaya.android.data.dao.MacroDao
import com.getmaya.android.data.dao.MemoryDao
import com.getmaya.android.data.entity.ChatMessageEntity
import com.getmaya.android.data.entity.MacroEntity
import com.getmaya.android.data.entity.MemoryEntity

@Database(
    entities = [ChatMessageEntity::class, MemoryEntity::class, MacroEntity::class],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun chatMessageDao(): ChatMessageDao
    abstract fun memoryDao(): MemoryDao
    abstract fun macroDao(): MacroDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "maya_database.db"
                ).fallbackToDestructiveMigration().build()
                INSTANCE = instance
                instance
            }
        }
    }
}
