package com.auravoice.assistant

import android.app.Application
import com.auravoice.assistant.data.AppDatabase
import com.auravoice.assistant.util.AppLogger

class AuraApplication : Application() {
    val database by lazy { AppDatabase.getDatabase(this) }

    override fun onCreate() {
        super.onCreate()
        AppLogger.init(this)
        AppLogger.i("AuraApplication", "Application onCreate finished successfully")
    }
}
