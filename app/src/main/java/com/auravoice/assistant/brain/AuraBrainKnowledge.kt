package com.auravoice.assistant.brain

import android.content.Context
import java.text.SimpleDateFormat
import java.util.*
import java.util.regex.Pattern

/**
 * AuraBrainKnowledge:
 * Deep offline training corpus and cognitive dialogue engine for Aura Voice AI (Jarvis v3.2).
 * Covers conversational intelligence, math solving, memory recall, humor, empathy,
 * and comprehensive device control without any internet dependency.
 */
object AuraBrainKnowledge {

    private val bengaliDigits = charArrayOf('০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯')
    private val englishDigits = charArrayOf('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')

    fun toBengaliNumber(num: Long): String {
        val str = num.toString()
        val sb = StringBuilder()
        for (ch in str) {
            if (ch in '0'..'9') {
                sb.append(bengaliDigits[ch - '0'])
            } else {
                sb.append(ch)
            }
        }
        return sb.toString()
    }

    /**
     * Resolves Current Time in spoken Bengali or English.
     */
    fun getCurrentTimeSpeech(isBengali: Boolean): String {
        val cal = Calendar.getInstance()
        val hour = cal.get(Calendar.HOUR)
        val hour12 = if (hour == 0) 12 else hour
        val minute = cal.get(Calendar.MINUTE)
        val amPm = if (cal.get(Calendar.AM_PM) == Calendar.AM) "সকাল" else if (cal.get(Calendar.HOUR_OF_DAY) < 17) "দুপুর" else if (cal.get(Calendar.HOUR_OF_DAY) < 20) "সন্ধ্যা" else "রাত"

        return if (isBengali) {
            val minStr = if (minute == 0) "ঠিক" else "${toBengaliNumber(minute.toLong())} মিনিট"
            if (minute == 0) {
                "এখন $amPm ${toBengaliNumber(hour12.toLong())}টা বাজে।"
            } else {
                "এখন $amPm ${toBengaliNumber(hour12.toLong())}টা বেজে $minStr।"
            }
        } else {
            val df = SimpleDateFormat("h:mm a", Locale.ENGLISH)
            "The current time is ${df.format(Date())}."
        }
    }

    /**
     * Resolves Current Date & Day in spoken Bengali or English.
     */
    fun getCurrentDateSpeech(isBengali: Boolean): String {
        val cal = Calendar.getInstance()
        val dayOfWeekBn = when (cal.get(Calendar.DAY_OF_WEEK)) {
            Calendar.SATURDAY -> "শনিবার"
            Calendar.SUNDAY -> "রবিবার"
            Calendar.MONDAY -> "সোমবার"
            Calendar.TUESDAY -> "মঙ্গলবার"
            Calendar.WEDNESDAY -> "বুধবার"
            Calendar.THURSDAY -> "বৃহস্পতিবার"
            Calendar.FRIDAY -> "শুক্রবার"
            else -> ""
        }

        val monthBn = when (cal.get(Calendar.MONTH)) {
            Calendar.JANUARY -> "জানুয়ারি"
            Calendar.FEBRUARY -> "ফেব্রুয়ারি"
            Calendar.MARCH -> "মার্চ"
            Calendar.APRIL -> "এপ্রিল"
            Calendar.MAY -> "মে"
            Calendar.JUNE -> "জুন"
            Calendar.JULY -> "জুলাই"
            Calendar.AUGUST -> "আগস্ট"
            Calendar.SEPTEMBER -> "সেপ্টেম্বর"
            Calendar.OCTOBER -> "অক্টোবর"
            Calendar.NOVEMBER -> "নভেম্বর"
            Calendar.DECEMBER -> "ডিসেম্বর"
            else -> ""
        }

        val day = toBengaliNumber(cal.get(Calendar.DAY_OF_MONTH).toLong())
        val year = toBengaliNumber(cal.get(Calendar.YEAR).toLong())

        return if (isBengali) {
            "আজ $dayOfWeekBn, $day $monthBn $year সাল।"
        } else {
            val df = SimpleDateFormat("EEEE, MMMM d, yyyy", Locale.ENGLISH)
            "Today is ${df.format(Date())}."
        }
    }

    /**
     * Solves basic verbal math queries: addition, subtraction, multiplication, division, percentages.
     */
    fun solveMath(query: String): String? {
        val normalized = query.lowercase(Locale.ROOT)
            .replace("যোগ", "+")
            .replace("বিয়োগ", "-")
            .replace("গুন", "*")
            .replace("গুণ", "*")
            .replace("পূরণ", "*")
            .replace("ভাগ", "/")
            .replace("শতাংশ", "%")
            .replace("পারসেন্ট", "%")

        // Convert Bengali digits to English for evaluation
        val sb = StringBuilder()
        for (ch in normalized) {
            val idx = bengaliDigits.indexOf(ch)
            if (idx != -1) sb.append(englishDigits[idx]) else sb.append(ch)
        }
        val clean = sb.toString()

        // 1. Percentage: "X এর Y %" or "Y % of X"
        val pctPattern = Pattern.compile("(\\d+)\\s*(?:এর|of)?\\s*(\\d+)\\s*%")
        val pctMatcher = pctPattern.matcher(clean)
        if (pctMatcher.find()) {
            val base = pctMatcher.group(1)?.toDoubleOrNull() ?: 0.0
            val pct = pctMatcher.group(2)?.toDoubleOrNull() ?: 0.0
            val ans = (base * pct) / 100.0
            val ansStr = if (ans % 1.0 == 0.0) ans.toLong().toString() else String.format(Locale.US, "%.2f", ans)
            return "$base এর $pct শতাংশ হলো $ansStr।"
        }

        // 2. Arithmetic: a + b, a - b, a * b, a / b
        val mathPattern = Pattern.compile("(\\d+(?:\\.\\d+)?)\\s*([+\\-*/])\\s*(\\d+(?:\\.\\d+)?)")
        val matcher = mathPattern.matcher(clean)
        if (matcher.find()) {
            val a = matcher.group(1)?.toDoubleOrNull() ?: return null
            val op = matcher.group(2) ?: return null
            val b = matcher.group(3)?.toDoubleOrNull() ?: return null

            val result = when (op) {
                "+" -> a + b
                "-" -> a - b
                "*" -> a * b
                "/" -> if (b != 0.0) a / b else Double.NaN
                else -> return null
            }

            if (result.isNaN()) {
                return "শূন্য দিয়ে ভাগ করা সম্ভব নয়।"
            }

            val resStr = if (result % 1.0 == 0.0) result.toLong().toString() else String.format(Locale.US, "%.2f", result)
            val opName = when (op) {
                "+" -> "যোগফল"
                "-" -> "বিয়োগফল"
                "*" -> "গুণফল"
                "/" -> "ভাগফল"
                else -> "ফলাফল"
            }
            return "$opName হলো $resStr।"
        }

        return null
    }

    /**
     * Curated witty Bengali & English jokes for natural humor.
     */
    val bengaliJokes = listOf(
        "শিক্ষক ছাত্রকে বললেন: বলো তো পৃথিবী কেন ঘোরে? ছাত্র বলল: স্যার, পৃথিবীর তো পা নেই, তাই হেঁটে যেতে না পেরে ঘুরতে থাকে!",
        "ডাক্তার বললেন: আপনার রোগীকে প্রতিদিন সকালে একটা করে দৌড় দিতে বলবেন। রোগী বললেন: ডাক্তারবাবু, আমি তো অলরেডি ডেলিভারি বয়, সারাদিন দৌড়েই কাটাই!",
        "এক বন্ধু আরেক বন্ধুকে বলল: দোস্ত, তোর মোবাইল তো অনেক দামি, এটার স্পেশাল ফিচার কী? বন্ধু বলল: চার্জ শেষ হলে এটা দিয়ে দারুণভাবে কাগজ চাপা দেওয়া যায়!",
        "কম্পিউটার আর মানুষের মধ্যে পার্থক্য কী জানেন? কম্পিউটার ভুল করলে নিজে স্বীকার করে হ্যাং হয়ে যায়, আর মানুষ হ্যাং হয়ে অন্যদের ওপর রাগ দেখায়!"
    )

    /**
     * Curated Bengali riddles (ধাঁধা).
     */
    val bengaliRiddles = listOf(
        "বলুন তো: যা আছে কিন্তু দেখা যায় না, যা ভাঙলে শব্দ হয় না? উত্তর হলো: বিশ্বাস ও মন!",
        "বলুন তো: কাঁচের ঘরে বাস করে, আলো ছাড়া বাঁচে না? উত্তর হলো: বৈদ্যুতিক বাল্ব!",
        "বলুন তো: জল খেলে মরে যায়, বাতাস পেলে বেঁচে থাকে? উত্তর হলো: আগুন!"
    )

    /**
     * Pre-trained conversational knowledge map covering high-frequency human inquiries.
     */
    val knowledgeDialogues = mapOf(
        "bangladesh_capital" to "বাংলাদেশের রাজধানী ঢাকা, যা বুড়িগঙ্গা নদীর তীরে অবস্থিত একটি প্রাচীন ও প্রাণবন্ত মেগাসিটি।",
        "national_poet" to "বাংলাদেশের জাতীয় কবি কাজী নজরুল ইসলাম, যিনি আমাদের বিদ্রোহী কবি হিসেবে বিশ্বজুড়ে পরিচিত।",
        "independence_day" to "বাংলাদেশের স্বাধীনতা দিবস ২৬শে মার্চ এবং বিজয় দিবস ১৬ই ডিসেম্বর।",
        "snapdragon_specs" to "Snapdragon 8 Gen 2 হলো কোয়ালকমের ৪-ন্যানোমিটার ফ্ল্যাগশিপ প্রসেসর। এতে রয়েছে Cortex-X3 প্রাইম কোর এবং অত্যন্ত দ্রুতগতির Adreno 740 GPU ও Hexagon NPU, যা অফলাইন এআই চালানোর জন্য সেরা!",
        "what_is_ai" to "এআই বা কৃত্রিম বুদ্ধিমত্তা হলো কম্পিউটারের চিন্তা করা, শেখা এবং সিদ্ধান্ত নেওয়ার ক্ষমতা। আমি যেমন অফলাইনে আপনার ডিভাইসে থেকেই সব বুঝে কাজ করছি!",
        "what_is_linux" to "লিনাক্স হলো একটি অত্যন্ত শক্তিশালী এবং নিরাপদ ওপেন-সোর্স অপারেটিং সিস্টেম কার্নেল। আপনার অ্যান্ড্রয়েড ফোনটিও এই লিনাক্স কার্নেলের ওপর ভিত্তি করে চলে।"
    )
}
