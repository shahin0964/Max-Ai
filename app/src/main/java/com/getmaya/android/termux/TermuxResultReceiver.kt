package com.getmaya.android.termux

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class TermuxResultReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val command = intent.getStringExtra("original_command") ?: "unknown"
        val stdout = intent.getStringExtra("stdout") ?: ""
        val stderr = intent.getStringExtra("stderr") ?: ""
        val exitCode = intent.getIntExtra("exitCode", 0)

        Log.d("TermuxResultReceiver", "Command finished: $command -> code: $exitCode")

        CoroutineScope(Dispatchers.IO).launch {
            TermuxBridge.onResultReceived(command, stdout, stderr, exitCode)
        }
    }
}
