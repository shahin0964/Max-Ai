package com.getmaya.android.agentic

import android.content.Context
import com.getmaya.android.MayaApplication
import com.getmaya.android.automation.DeviceController
import com.getmaya.android.automation.MayaAccessibilityService
import com.getmaya.android.automation.MayaNotificationListener
import com.getmaya.android.data.entity.MemoryEntity
import com.getmaya.android.termux.TermuxBridge
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.net.URLEncoder

class ToolRegistry(private val context: Context) {

    private val httpClient = OkHttpClient()
    private val macroRunner = MacroRunner(context)
    private val database = MayaApplication.instance.database

    suspend fun executeTool(name: String, args: Map<String, Any>): String = withContext(Dispatchers.IO) {
        try {
            when (name) {
                "termux_run" -> {
                    val cmd = args["command"]?.toString() ?: return@withContext "Error: missing command argument"
                    TermuxBridge.executeCommand(context, cmd)
                }
                "whatsapp_send_message" -> {
                    val to = args["phone_or_name"]?.toString() ?: ""
                    val msg = args["message"]?.toString() ?: ""
                    DeviceController.sendWhatsApp(context, to, msg)
                }
                "whatsapp_read_chat" -> {
                    val sender = args["sender_name"]?.toString() ?: "whatsapp"
                    val items = MayaNotificationListener.getLatestFor(sender)
                    if (items.isEmpty()) "No recent messages found for $sender"
                    else items.joinToString("\n") { "[${it.sender}]: ${it.content}" }
                }
                "make_call" -> {
                    val num = args["contact_or_number"]?.toString() ?: return@withContext "Missing number"
                    DeviceController.makeCall(context, num)
                }
                "send_sms" -> {
                    val num = args["phone_number"]?.toString() ?: return@withContext "Missing number"
                    val msg = args["message"]?.toString() ?: ""
                    DeviceController.sendSms(context, num, msg)
                }
                "set_torch" -> {
                    val enabled = args["enabled"]?.toString()?.toBoolean() ?: true
                    DeviceController.setTorch(context, enabled)
                }
                "set_volume" -> {
                    val level = args["level_percent"]?.toString()?.toIntOrNull() ?: 50
                    DeviceController.setVolume(context, level)
                }
                "open_app" -> {
                    val app = args["app_name"]?.toString() ?: return@withContext "Missing app name"
                    DeviceController.openApp(context, app)
                }
                "tap_text" -> {
                    val text = args["text"]?.toString() ?: return@withContext "Missing text"
                    val a11y = MayaAccessibilityService.instance
                    if (a11y != null) {
                        val ok = a11y.findAndClick(text)
                        if (ok) "Tapped '$text'" else "Text '$text' not found or not clickable"
                    } else "Accessibility Service not enabled"
                }
                "tap_coordinates" -> {
                    val x = args["x"]?.toString()?.toFloatOrNull() ?: 0f
                    val y = args["y"]?.toString()?.toFloatOrNull() ?: 0f
                    val a11y = MayaAccessibilityService.instance
                    if (a11y != null) {
                        val ok = a11y.clickAt(x, y)
                        if (ok) "Clicked at ($x, $y)" else "Failed to click at coordinates"
                    } else "Accessibility Service not enabled"
                }
                "swipe_screen" -> {
                    val dir = args["direction"]?.toString() ?: "up"
                    val a11y = MayaAccessibilityService.instance
                    if (a11y != null) {
                        val ok = a11y.swipe(dir)
                        if (ok) "Swiped $dir" else "Failed to swipe"
                    } else "Accessibility Service not enabled"
                }
                "read_screen_text" -> {
                    val a11y = MayaAccessibilityService.instance
                    a11y?.extractScreenText() ?: "Accessibility Service not enabled"
                }
                "play_youtube" -> {
                    val q = args["query"]?.toString() ?: ""
                    DeviceController.playYouTube(context, q)
                }
                "get_weather" -> {
                    // Open-Meteo default Dhaka / general location
                    val url = "https://api.open-meteo.com/v1/forecast?latitude=23.8103&longitude=90.4125&current_weather=true"
                    val req = Request.Builder().url(url).build()
                    val resp = httpClient.newCall(req).execute()
                    val body = resp.body?.string() ?: "{}"
                    val json = JSONObject(body)
                    val current = json.optJSONObject("current_weather")
                    if (current != null) {
                        "Temperature: ${current.optDouble("temperature")}°C, WindSpeed: ${current.optDouble("windspeed")} km/h"
                    } else "Weather data unavailable"
                }
                "web_search" -> {
                    val q = args["query"]?.toString() ?: ""
                    val encoded = URLEncoder.encode(q, "UTF-8")
                    val url = "https://api.duckduckgo.com/?q=$encoded&format=json&no_html=1"
                    val req = Request.Builder().url(url).build()
                    val resp = httpClient.newCall(req).execute()
                    val body = resp.body?.string() ?: "{}"
                    val json = JSONObject(body)
                    val abstract = json.optString("AbstractText", "")
                    if (abstract.isNotBlank()) abstract
                    else "Search completed for '$q'. Detailed results viewable in browser."
                }
                "recall_memory" -> {
                    val q = args["query"]?.toString() ?: ""
                    val memories = database.memoryDao().searchMemories(q)
                    if (memories.isEmpty()) "No memories found for query '$q'"
                    else memories.joinToString("\n") { "• [${it.key}]: ${it.content}" }
                }
                "save_memory" -> {
                    val key = args["key"]?.toString() ?: "general"
                    val content = args["content"]?.toString() ?: ""
                    database.memoryDao().insertMemory(MemoryEntity(key = key, content = content))
                    "Saved to memory: [$key] $content"
                }
                "run_macro" -> {
                    val name = args["macro_name"]?.toString() ?: ""
                    macroRunner.runMacro(name)
                }
                else -> "Unknown tool: $name"
            }
        } catch (e: Exception) {
            "Tool error ($name): ${e.message}"
        }
    }
}
