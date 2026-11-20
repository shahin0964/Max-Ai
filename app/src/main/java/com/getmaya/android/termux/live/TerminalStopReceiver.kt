package com.getmaya.android.termux.live

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class TerminalStopReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        // Stop current running command or terminal session
    }
}
