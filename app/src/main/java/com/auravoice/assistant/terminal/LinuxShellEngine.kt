package com.auravoice.assistant.terminal

import com.auravoice.assistant.util.AppLogger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.BufferedReader
import java.io.InputStreamReader

data class ShellOutput(
    val command: String,
    val output: String,
    val exitCode: Int,
    val timestamp: Long = System.currentTimeMillis()
)

/**
 * LinuxShellEngine:
 * Embedded local Linux/Android shell runner capable of executing terminal commands.
 */
class LinuxShellEngine {

    private val tag = "LinuxShellEngine"

    suspend fun executeCommand(commandStr: String): ShellOutput = withContext(Dispatchers.IO) {
        val cleanCmd = commandStr.trim()
        if (cleanCmd.isBlank()) {
            return@withContext ShellOutput(cleanCmd, "", 0)
        }

        AppLogger.i(tag, "Executing terminal command: '$cleanCmd'")

        try {
            // Execute via /system/bin/sh
            val process = ProcessBuilder("sh", "-c", cleanCmd)
                .redirectErrorStream(true)
                .start()

            val reader = BufferedReader(InputStreamReader(process.inputStream))
            val outputBuilder = StringBuilder()
            var line: String?

            while (reader.readLine().also { line = it } != null) {
                outputBuilder.append(line).append("\n")
            }

            val exitCode = process.waitFor()
            val resultText = outputBuilder.toString().trimEnd()

            ShellOutput(cleanCmd, resultText, exitCode)
        } catch (e: Exception) {
            AppLogger.e(tag, "Command execution failed: ${e.message}", e)
            ShellOutput(cleanCmd, "Error: ${e.message}", -1)
        }
    }
}
