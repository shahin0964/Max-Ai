package com.auravoice.assistant.util

import android.content.Context
import android.os.Environment
import android.util.Log
import java.io.File
import java.io.FileWriter
import java.io.PrintWriter
import java.io.StringWriter
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * AppLogger:
 * Real-time logger and crash reporting engine.
 * Writes detailed diagnostics and crash stacktraces directly to /sdcard/Download/aura_app.log
 * so that any issue can be inspected immediately from Termux.
 */
object AppLogger {

    private const val TAG = "AuraVoiceAI"
    private var appContext: Context? = null
    private val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS", Locale.US)

    fun init(context: Context) {
        appContext = context.applicationContext

        // Install Global Uncaught Exception Handler
        val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
        Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
            val stackTrace = StringWriter().also { throwable.printStackTrace(PrintWriter(it)) }.toString()
            val crashLog = """
                =======================================================
                FATAL CRASH DETECTED AT: ${dateFormat.format(Date())}
                Thread: ${thread.name} (id: ${thread.id})
                Exception: ${throwable.javaClass.name}: ${throwable.message}
                Stack Trace:
                $stackTrace
                =======================================================
            """.trimIndent()

            Log.e(TAG, crashLog)
            writeToLogFiles("CRASH", crashLog)

            // Delegate to default handler so OS can terminate or handle cleanly
            defaultHandler?.uncaughtException(thread, throwable)
        }

        i("AppLogger", "=== Aura Voice AI Initialized [Logging Active] ===")
    }

    fun d(tag: String, message: String) {
        Log.d(tag, message)
        writeToLogFiles("DEBUG", "[$tag] $message")
    }

    fun i(tag: String, message: String) {
        Log.i(tag, message)
        writeToLogFiles("INFO", "[$tag] $message")
    }

    fun w(tag: String, message: String) {
        Log.w(tag, message)
        writeToLogFiles("WARN", "[$tag] $message")
    }

    fun e(tag: String, message: String, throwable: Throwable? = null) {
        val details = if (throwable != null) {
            val sw = StringWriter()
            throwable.printStackTrace(PrintWriter(sw))
            "$message\n$sw"
        } else {
            message
        }
        Log.e(tag, details)
        writeToLogFiles("ERROR", "[$tag] $details")
    }

    @Synchronized
    private fun writeToLogFiles(level: String, text: String) {
        val timestamp = dateFormat.format(Date())
        val formattedLine = "[$timestamp] [$level] $text\n"

        // 1. Write to /sdcard/Download/aura_app.log for direct inspection
        try {
            val downloadDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (downloadDir != null && (downloadDir.exists() || downloadDir.mkdirs())) {
                val logFile = File(downloadDir, "aura_app.log")
                FileWriter(logFile, true).use { writer ->
                    writer.write(formattedLine)
                }
            }
        } catch (ignored: Exception) {
            // Fallback
        }

        // 2. Also write to internal filesDir as backup
        try {
            appContext?.let { ctx ->
                val internalLog = File(ctx.filesDir, "aura_internal.log")
                FileWriter(internalLog, true).use { writer ->
                    writer.write(formattedLine)
                }
            }
        } catch (ignored: Exception) {}
    }
}
