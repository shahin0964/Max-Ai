package com.getmaya.android.agentic

import android.content.Context
import android.util.Log
import com.getmaya.android.MayaApplication
import com.getmaya.android.data.entity.ChatMessageEntity
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.concurrent.TimeUnit
import java.util.regex.Pattern

class AgenticEngine(private val context: Context) {

    private val httpClient = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .build()

    private val toolRegistry = ToolRegistry(context)
    private val database = MayaApplication.instance.database
    private val gson = Gson()

    private val _isProcessing = MutableStateFlow(false)
    val isProcessing = _isProcessing.asStateFlow()

    private val _agentStatus = MutableStateFlow("Ready")
    val agentStatus = _agentStatus.asStateFlow()

    suspend fun processUserPrompt(
        prompt: String,
        persona: String = "Maya",
        apiKey: String = "",
        provider: String = "Groq", // Gemini, Groq, OpenRouter
        modelName: String = "llama-3.3-70b-versatile"
    ): String = withContext(Dispatchers.IO) {
        _isProcessing.value = true
        _agentStatus.value = "Thinking..."

        // Save user message to database
        database.chatMessageDao().insertMessage(
            ChatMessageEntity(text = prompt, sender = "user", persona = persona)
        )

        val systemPrompt = SystemPrompts.getSystemPrompt(persona)

        // Retrieve past 10 messages for conversation context
        val recentMessages = database.chatMessageDao().getRecentMessages(10).reversed()

        try {
            val responseText = if (apiKey.isBlank()) {
                // Offline fallback / local rule-based intent execution if no API key provided
                executeLocalFallback(prompt)
            } else {
                callLlmWithTools(apiKey, provider, modelName, systemPrompt, recentMessages, prompt)
            }

            // Save assistant reply to database
            database.chatMessageDao().insertMessage(
                ChatMessageEntity(text = responseText, sender = "maya", persona = persona)
            )

            _agentStatus.value = "Ready"
            _isProcessing.value = false
            responseText
        } catch (e: Exception) {
            Log.e("AgenticEngine", "Error in processing prompt", e)
            val err = "Maya encountered an error: ${e.message}"
            _agentStatus.value = "Error"
            _isProcessing.value = false
            err
        }
    }

    private suspend fun callLlmWithTools(
        apiKey: String,
        provider: String,
        model: String,
        systemPrompt: String,
        history: List<ChatMessageEntity>,
        userMessage: String
    ): String {
        val endpoint = when (provider.lowercase()) {
            "gemini" -> "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
            "openrouter" -> "https://openrouter.ai/api/v1/chat/completions"
            else -> "https://api.groq.com/openai/v1/chat/completions"
        }

        // Build OpenAI-compatible chat payload with Function Calling tools
        val messagesArray = JsonArray()
        
        // System
        val sysObj = JsonObject()
        sysObj.addProperty("role", "system")
        sysObj.addProperty("content", systemPrompt)
        messagesArray.add(sysObj)

        // History
        for (m in history) {
            val mObj = JsonObject()
            mObj.addProperty("role", if (m.sender == "user") "user" else "assistant")
            mObj.addProperty("content", m.text)
            messagesArray.add(mObj)
        }

        // Current message
        val currObj = JsonObject()
        currObj.addProperty("role", "user")
        currObj.addProperty("content", userMessage)
        messagesArray.add(currObj)

        val root = JsonObject()
        root.addProperty("model", model)
        root.add("messages", messagesArray)
        root.addProperty("temperature", 0.7)

        val reqBody = root.toString().toRequestBody("application/json".toMediaType())
        val req = Request.Builder()
            .url(endpoint)
            .addHeader("Authorization", "Bearer $apiKey")
            .post(reqBody)
            .build()

        val resp = httpClient.newCall(req).execute()
        val respBody = resp.body?.string() ?: ""

        if (!resp.isSuccessful) {
            return "API Error (${resp.code}): $respBody"
        }

        val jsonResp = gson.fromJson(respBody, JsonObject::class.java)
        val choices = jsonResp.getAsJsonArray("choices")
        if (choices == null || choices.size() == 0) return "No response from model"

        val choice = choices[0].asJsonObject
        val msg = choice.getAsJsonObject("message")
        val content = msg.get("content")?.asString ?: ""

        // Check if model called a tool via syntax or markdown: e.g. ```tool:termux_run {"command": "ls"}```
        val toolRegex = Pattern.compile("```(?:tool:)?([a-z_]+)\\s*(\\{.*?\\})\\s*```", Pattern.DOTALL)
        val matcher = toolRegex.matcher(content)
        if (matcher.find()) {
            val toolName = matcher.group(1) ?: ""
            val toolArgsJson = matcher.group(2) ?: "{}"
            _agentStatus.value = "Executing tool: $toolName..."
            
            val argsMap = try {
                gson.fromJson(toolArgsJson, Map::class.java) as Map<String, Any>
            } catch (e: Exception) {
                emptyMap<String, Any>()
            }
            val toolOutput = toolRegistry.executeTool(toolName, argsMap)
            
            // Recursive second turn with tool output
            return "$content\n\n[Tool Result]:\n$toolOutput"
        }

        return content
    }

    private suspend fun executeLocalFallback(prompt: String): String {
        val lower = prompt.lowercase()
        return when {
            lower.contains("torch") || lower.contains("flash") -> {
                val on = lower.contains("on")
                toolRegistry.executeTool("set_torch", mapOf("enabled" to on))
            }
            lower.contains("volume") -> {
                val num = Regex("\\d+").find(prompt)?.value?.toIntOrNull() ?: 50
                toolRegistry.executeTool("set_volume", mapOf("level_percent" to num))
            }
            lower.contains("termux") || lower.startsWith("run ") || lower.startsWith("bash ") -> {
                val cmd = prompt.substringAfter("run ").substringAfter("bash ").trim()
                val res = toolRegistry.executeTool("termux_run", mapOf("command" to cmd))
                "Running in Termux:\n$res"
            }
            lower.contains("whatsapp") -> {
                toolRegistry.executeTool("whatsapp_send_message", mapOf("phone_or_name" to "", "message" to prompt))
            }
            lower.contains("youtube") -> {
                val q = prompt.substringAfter("play").substringAfter("youtube").trim()
                toolRegistry.executeTool("play_youtube", mapOf("query" to q))
            }
            lower.contains("weather") -> {
                toolRegistry.executeTool("get_weather", emptyMap())
            }
            else -> {
                "Maya is ready. Please configure your API Key in Settings to enable full autonomous agent capabilities and live voice generation."
            }
        }
    }
}
