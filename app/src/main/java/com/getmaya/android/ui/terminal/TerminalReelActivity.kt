package com.getmaya.android.ui.terminal

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.getmaya.android.termux.TermuxBridge
import com.getmaya.android.ui.screens.TerminalReelScreen
import com.getmaya.android.ui.theme.MayaTheme
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class TerminalReelActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MayaTheme {
                TerminalReelScreen(
                    outputs = listOf("Ready" to "Terminal Reel Active"),
                    onExecuteCommand = { cmd ->
                        CoroutineScope(Dispatchers.IO).launch {
                            TermuxBridge.executeCommand(this@TerminalReelActivity, cmd)
                        }
                    },
                    onBack = { finish() }
                )
            }
        }
    }
}
