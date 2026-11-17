package com.auravoice.assistant

import android.app.Application
import com.auravoice.assistant.data.AppDatabase

class AuraApplication : Application() {
    val database by lazy { AppDatabase.getDatabase(this) }

    override fun onCreate() {
        super.onCreate()
    }
}
