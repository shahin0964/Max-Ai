package com.getmaya.android.assistant

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.getmaya.android.MainActivity

class MayaAssistActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent = Intent(this, MainActivity::class.java).apply {
            putExtra("EXTRA_VOICE_TRIGGER", true)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        startActivity(intent)
        finish()
    }
}
