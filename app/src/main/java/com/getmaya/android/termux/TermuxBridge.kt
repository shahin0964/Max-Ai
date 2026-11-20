package com.getmaya.android.termux

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import java.io.BufferedReader
import java.io.InputStreamReader

object TermuxBridge {
    private const val TAG = "TermuxBridge"
    const val ACTION_RUN_COMMAND = "com.termux.RUN_COMMAND"
    const val EXTRA_RUN_COMMAND_PATH = "com.termux.RUN_COMMAND_PATH"
    const val EXTRA_RUN_COMMAND_ARGUMENTS = "com.termux.RUN_COMMAND_ARGUMENTS"
    const val EXTRA_RUN_COMMAND_WORKDIR = "com.termux.RUN_COMMAND_WORKDIR"
    const val EXTRA_RUN_COMMAND_BACKGROUND = "com.termux.RUN_COMMAND_BACKGROUND"
    const val EXTRA_PENDING_INTENT = "com.termux.RUN_COMMAND_RESULT_INTENT"

    private val _commandOutputs = MutableSharedFlow<Pair<String, String>>(replay = 10)
    val commandOutputs = _commandOutputs.asSharedFlow()

    suspend fun executeCommand(context: Context, command: String): String {
        Log.d(TAG, "Executing Termux command: $command")
        
        // Try direct process exec first if running inside Termux environment
        try {
            val process = Runtime.getRuntime().exec(arrayOf("sh", "-c", command))
            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val errorReader = BufferedReader(InputStreamReader(process.errorStream))
            val output = StringBuilder()
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                output.append(line).append("\n")
            }
            while (errorReader.readLine().also { line = it } != null) {
                output.append(line).append("\n")
            }
            process.waitFor()
            val res = output.toString().trim()
            if (res.isNotEmpty()) {
                _commandOutputs.emit(Pair(command, res))
                return res
            }
        } catch (e: Exception) {
            Log.w(TAG, "Direct exec failed, falling back to Termux Intent bridge: ${e.message}")
        }

        // Send Intent to Termux RUN_COMMAND service
        return try {
            val intent = Intent(ACTION_RUN_COMMAND).apply {
                setPackage("com.termux")
                putExtra(EXTRA_RUN_COMMAND_PATH, "/data/data/com.termux/files/usr/bin/bash")
                putExtra(EXTRA_RUN_COMMAND_ARGUMENTS, arrayOf("-c", command))
                putExtra(EXTRA_RUN_COMMAND_WORKDIR, "/data/data/com.termux/files/home")
                putExtra(EXTRA_RUN_COMMAND_BACKGROUND, true)

                val resultIntent = Intent(context, TermuxResultReceiver::class.java).apply {
                    action = "com.getmaya.android.termux.RESULT"
                    putExtra("original_command", command)
                }
                val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
                val pendingIntent = PendingIntent.getBroadcast(context, command.hashCode(), resultIntent, flags)
                putExtra(EXTRA_PENDING_INTENT, pendingIntent)
            }
            context.startService(intent)
            _commandOutputs.emit(Pair(command, "Command sent to Termux"))
            "Dispatched command to Termux: $command"
        } catch (e: Exception) {
            Log.e(TAG, "Failed to dispatch command to Termux", e)
            "Error executing Termux command: ${e.message}"
        }
    }

    suspend fun onResultReceived(command: String, stdout: String, stderr: String, exitCode: Int) {
        val full = if (exitCode == 0) stdout else "Exit $exitCode\n$stderr\n$stdout"
        _commandOutputs.emit(Pair(command, full))
    }
}
