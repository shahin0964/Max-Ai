package com.auravoice.assistant.network

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import com.auravoice.assistant.util.AppLogger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import java.util.regex.Pattern

data class ResearchResult(
    val isSuccess: Boolean,
    val summary: String,
    val topic: String,
    val isOnline: Boolean
)

/**
 * OnlineResearchEngine:
 * Autonomous web intelligence and search engine.
 * Searches the web live when internet is connected, extracts key knowledge,
 * and gracefully reports when offline.
 */
class OnlineResearchEngine(private val context: Context) {

    private val tag = "OnlineResearchEngine"

    /**
     * Checks if the device has an active internet connection.
     */
    fun isInternetAvailable(): Boolean {
        return try {
            val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
                ?: return false
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val activeNetwork = cm.activeNetwork ?: return false
                val capabilities = cm.getNetworkCapabilities(activeNetwork) ?: return false
                capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) &&
                        capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
            } else {
                @Suppress("DEPRECATION")
                val netInfo = cm.activeNetworkInfo
                netInfo != null && netInfo.isConnected
            }
        } catch (e: Exception) {
            AppLogger.w(tag, "Network check exception: ${e.message}")
            false
        }
    }

    /**
     * Searches online across Wikipedia and DuckDuckGo and returns a synthesized spoken answer.
     */
    suspend fun researchTopic(rawQuery: String): ResearchResult = withContext(Dispatchers.IO) {
        val topic = cleanSearchQuery(rawQuery)
        AppLogger.i(tag, "Initiating web research for topic: '$topic'")

        if (!isInternetAvailable()) {
            AppLogger.w(tag, "No internet connection detected for search query: '$topic'")
            return@withContext ResearchResult(
                isSuccess = false,
                summary = "দুঃখিত, বর্তমানে কোনো ইন্টারনেট সংযোগ পাওয়া যায়নি। ইন্টারনেট সংযোগ চালু থাকলে আমি অনলাইনে বিস্তারিত খুঁজে বের করতে পারতাম।",
                topic = topic,
                isOnline = false
            )
        }

        // 1. Try Bengali Wikipedia if query has Bengali characters
        val hasBengali = topic.matches(Regex(".*[\\p{InBengali}].*"))
        if (hasBengali) {
            val bnWiki = fetchWikipediaSummary(topic, "bn")
            if (!bnWiki.isNullOrBlank()) {
                return@withContext ResearchResult(
                    isSuccess = true,
                    summary = bnWiki,
                    topic = topic,
                    isOnline = true
                )
            }
        }

        // 2. Try English Wikipedia
        val enWiki = fetchWikipediaSummary(topic, "en")
        if (!enWiki.isNullOrBlank()) {
            return@withContext ResearchResult(
                isSuccess = true,
                summary = enWiki,
                topic = topic,
                isOnline = true
            )
        }

        // 3. Try DuckDuckGo Instant Answer API
        val ddgAnswer = fetchDuckDuckGoInstantAnswer(topic)
        if (!ddgAnswer.isNullOrBlank()) {
            return@withContext ResearchResult(
                isSuccess = true,
                summary = ddgAnswer,
                topic = topic,
                isOnline = true
            )
        }

        // 4. Try DuckDuckGo HTML Search Snippet
        val ddgSnippet = fetchDuckDuckGoHtmlSnippet(topic)
        if (!ddgSnippet.isNullOrBlank()) {
            return@withContext ResearchResult(
                isSuccess = true,
                summary = ddgSnippet,
                topic = topic,
                isOnline = true
            )
        }

        // Fallback when online but no specific snippet found
        ResearchResult(
            isSuccess = true,
            summary = "আমি অনলাইনে \"$topic\" সম্পর্কে অনুসন্ধান করেছি, তবে সুনির্দিষ্ট কোনো সারসংক্ষেপ পাওয়া যায়নি। আপনি কি ভিন্নভাবে অনুসন্ধান করতে চান?",
            topic = topic,
            isOnline = true
        )
    }

    private fun cleanSearchQuery(raw: String): String {
        var str = raw.trim()
        val removeKeywords = listOf(
            "খুঁজে বের করো", "খুজে বের করো", "বের করো", "খোঁজ করো", "খোজ করো",
            "সার্চ করো", "সার্চ কর", "ইন্টারনেটে খোঁজো", "নেটে খোঁজো", "অনলাইনে খোঁজো",
            "search for", "search about", "find out about", "find out", "who is", "what is",
            "সম্পর্কে জানাও", "সম্পর্কে বলো", "সম্পর্কে কি জানো", "সম্পর্কে কি জানিস",
            "কি", "কী"
        )
        for (kw in removeKeywords) {
            str = str.replace(Regex("(?i)$kw"), " ").trim()
        }
        return str.replace(Regex("\\s+"), " ").trimEnd('?', '.', '!', ',')
    }

    private fun fetchWikipediaSummary(title: String, lang: String): String? {
        return try {
            val encoded = URLEncoder.encode(title.replace(" ", "_"), "UTF-8")
            val url = URL("https://$lang.wikipedia.org/api/rest_v1/page/summary/$encoded")
            val conn = (url.openConnection() as HttpURLConnection).apply {
                connectTimeout = 4000
                readTimeout = 4000
                requestMethod = "GET"
                setRequestProperty("User-Agent", "AuraVoiceAI/3.2 (Android; Mobile)")
            }

            if (conn.responseCode == 200) {
                val response = conn.inputStream.bufferedReader().use { it.readText() }
                val json = JSONObject(response)
                val extract = json.optString("extract", "")
                if (extract.isNotBlank() && extract.length > 20) {
                    cleanSpokenSummary(extract)
                } else null
            } else null
        } catch (e: Exception) {
            AppLogger.d(tag, "Wiki $lang search failed: ${e.message}")
            null
        }
    }

    private fun fetchDuckDuckGoInstantAnswer(query: String): String? {
        return try {
            val encoded = URLEncoder.encode(query, "UTF-8")
            val url = URL("https://api.duckduckgo.com/?q=$encoded&format=json&no_html=1&skip_disambig=1")
            val conn = (url.openConnection() as HttpURLConnection).apply {
                connectTimeout = 4000
                readTimeout = 4000
                requestMethod = "GET"
                setRequestProperty("User-Agent", "AuraVoiceAI/3.2 (Android; Mobile)")
            }

            if (conn.responseCode == 200) {
                val response = conn.inputStream.bufferedReader().use { it.readText() }
                val json = JSONObject(response)
                val abstractText = json.optString("AbstractText", "")
                val answer = json.optString("Answer", "")
                val definition = json.optString("Definition", "")

                val candidate = when {
                    abstractText.isNotBlank() -> abstractText
                    answer.isNotBlank() -> answer
                    definition.isNotBlank() -> definition
                    else -> ""
                }
                if (candidate.isNotBlank() && candidate.length > 20) {
                    cleanSpokenSummary(candidate)
                } else null
            } else null
        } catch (e: Exception) {
            AppLogger.d(tag, "DDG API failed: ${e.message}")
            null
        }
    }

    private fun fetchDuckDuckGoHtmlSnippet(query: String): String? {
        return try {
            val encoded = URLEncoder.encode(query, "UTF-8")
            val url = URL("https://html.duckduckgo.com/html/?q=$encoded")
            val conn = (url.openConnection() as HttpURLConnection).apply {
                connectTimeout = 4500
                readTimeout = 4500
                requestMethod = "GET"
                setRequestProperty("User-Agent", "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36")
            }

            if (conn.responseCode == 200) {
                val html = conn.inputStream.bufferedReader().use { it.readText() }
                // Pattern for class="result__snippet"
                val pattern = Pattern.compile("class=\"result__snippet\"[^>]*>(.*?)</a>", Pattern.DOTALL)
                val matcher = pattern.matcher(html)
                if (matcher.find()) {
                    var snippet = matcher.group(1) ?: ""
                    // Strip HTML tags & entities
                    snippet = snippet.replace(Regex("<[^>]+>"), "")
                    snippet = snippet.replace("&quot;", "\"")
                        .replace("&#39;", "'")
                        .replace("&amp;", "&")
                        .replace("&lt;", "<")
                        .replace("&gt;", ">")
                    if (snippet.isNotBlank() && snippet.length > 25) {
                        cleanSpokenSummary(snippet)
                    } else null
                } else null
            } else null
        } catch (e: Exception) {
            AppLogger.d(tag, "DDG HTML snippet failed: ${e.message}")
            null
        }
    }

    private fun cleanSpokenSummary(text: String): String {
        // Limit to 2-3 sentences max for spoken audio clarity
        val sentences = text.split(Regex("(?<=[.!?।])\\s+"))
        val trimmedSentences = sentences.take(2).joinToString(" ").trim()
        return trimmedSentences.replace(Regex("\\s+"), " ")
    }
}
