package com.getmaya.android.agentic

import android.content.Context
import android.util.Log
import com.getmaya.android.automation.MayaAccessibilityService
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.delay

class MacroRunner(private val context: Context) {

    data class MacroStep(
        val action: String, // tap_text, tap_coordinates, wait, key_event, swipe
        val target: String? = null,
        val x: Float? = null,
        val y: Float? = null,
        val durationMs: Long = 500
    )

    data class MacroFile(
        val version: Int = 1,
        val macros: Map<String, List<MacroStep>> = emptyMap()
    )

    suspend fun runMacro(macroName: String): String {
        val a11y = MayaAccessibilityService.instance ?: return "Error: Accessibility Service is not enabled"
        
        // Load builtin macros from assets
        val macrosMap = loadBuiltinMacros()
        val steps = macrosMap[macroName] ?: return "Macro '$macroName' not found"

        Log.d("MacroRunner", "Running macro: $macroName with ${steps.size} steps")
        for (step in steps) {
            when (step.action) {
                "tap_text" -> {
                    step.target?.let { a11y.findAndClick(it) }
                }
                "tap_coordinates" -> {
                    if (step.x != null && step.y != null) {
                        a11y.clickAt(step.x, step.y)
                    }
                }
                "swipe" -> {
                    step.target?.let { a11y.swipe(it) }
                }
                "wait" -> {
                    delay(step.durationMs)
                }
            }
            delay(step.durationMs)
        }
        return "Macro '$macroName' executed successfully"
    }

    private fun loadBuiltinMacros(): Map<String, List<MacroStep>> {
        return try {
            val json = context.assets.open("macros/builtin_macros.json").bufferedReader().use { it.readText() }
            val type = object : TypeToken<MacroFile>() {}.type
            val file: MacroFile = Gson().fromJson(json, type)
            file.macros
        } catch (e: Exception) {
            Log.e("MacroRunner", "Failed to parse builtin macros", e)
            emptyMap()
        }
    }
}
