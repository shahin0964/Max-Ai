package com.auravoice.assistant.service

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.hardware.camera2.CameraManager
import android.os.BatteryManager
import android.os.Build
import android.provider.Settings
import com.auravoice.assistant.util.AppLogger
import java.util.Locale

/**
 * DeviceController:
 * Gives Aura Voice AI full control over installed apps and phone hardware.
 */
class DeviceController(private val context: Context) {

    private val tag = "DeviceController"
    private var isTorchOn = false

    /**
     * Finds and launches any app installed on the device by name (Bengali or English).
     */
    fun openAppByName(appNameQuery: String): Pair<Boolean, String> {
        val query = appNameQuery.trim().lowercase(Locale.ROOT)
        AppLogger.i(tag, "Attempting to open app matching query: '$query'")

        // Known direct package shortcuts for instant launching
        val packageShortcuts = mapOf(
            "youtube" to "com.google.android.youtube",
            "ইউটিউব" to "com.google.android.youtube",
            "whatsapp" to "com.whatsapp",
            "হোয়াটসঅ্যাপ" to "com.whatsapp",
            "facebook" to "com.facebook.katana",
            "ফেসবুক" to "com.facebook.katana",
            "chrome" to "com.android.chrome",
            "ক্রোম" to "com.android.chrome",
            "camera" to "camera",
            "ক্যামেরা" to "camera",
            "settings" to "settings",
            "সেটিংস" to "settings",
            "gallery" to "gallery",
            "গ্যালারি" to "gallery",
            "termux" to "com.termux",
            "টারমাক্স" to "com.termux",
            "play store" to "com.android.vending",
            "প্লে স্টোর" to "com.android.vending",
            "telegram" to "org.telegram.messenger",
            "টেলিগ্রাম" to "org.telegram.messenger"
        )

        // 1. Check direct shortcuts
        for ((key, pkg) in packageShortcuts) {
            if (query.contains(key)) {
                if (pkg == "camera") {
                    return launchCameraIntent()
                } else if (pkg == "settings") {
                    return launchSettingsIntent()
                } else {
                    val launched = launchPackage(pkg)
                    if (launched) {
                        return Pair(true, "$key ওপেন করা হচ্ছে...")
                    }
                }
            }
        }

        // 2. Scan all installed applications on the device dynamically
        try {
            val pm = context.packageManager
            val packages = pm.getInstalledApplications(PackageManager.GET_META_DATA)
            for (app in packages) {
                val label = pm.getApplicationLabel(app).toString().lowercase(Locale.ROOT)
                if (query.contains(label) || label.contains(query)) {
                    val intent = pm.getLaunchIntentForPackage(app.packageName)
                    if (intent != null) {
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        context.startActivity(intent)
                        AppLogger.i(tag, "Successfully launched app: ${app.packageName} ($label)")
                        return Pair(true, "$label অ্যাপটি চালু করা হচ্ছে...")
                    }
                }
            }
        } catch (e: Exception) {
            AppLogger.e(tag, "Error searching installed apps", e)
        }

        return Pair(false, "অ্যাপটি খুঁজে পাওয়া যায়নি।")
    }

    private fun launchPackage(packageName: String): Boolean {
        return try {
            val intent = context.packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            AppLogger.e(tag, "Failed to launch package: $packageName", e)
            false
        }
    }

    private fun launchCameraIntent(): Pair<Boolean, String> {
        return try {
            val intent = Intent("android.media.action.IMAGE_CAPTURE").apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            Pair(true, "ক্যামেরা চালু করা হচ্ছে...")
        } catch (e: Exception) {
            Pair(false, "ক্যামেরা ওপেন করা সম্ভব হয়নি।")
        }
    }

    private fun launchSettingsIntent(): Pair<Boolean, String> {
        return try {
            val intent = Intent(Settings.ACTION_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            Pair(true, "ফোন সেটিংস ওপেন করা হচ্ছে...")
        } catch (e: Exception) {
            Pair(false, "সেটিংস ওপেন করা সম্ভব হয়নি।")
        }
    }

    /**
     * Controls device torch / flashlight.
     */
    fun toggleTorch(enable: Boolean): String {
        return try {
            val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
            val cameraId = cameraManager.cameraIdList[0]
            cameraManager.setTorchMode(cameraId, enable)
            isTorchOn = enable
            if (enable) "ফ্ল্যাশলাইট জ্বালানো হয়েছে।" else "ফ্ল্যাশলাইট বন্ধ করা হয়েছে।"
        } catch (e: Exception) {
            AppLogger.e(tag, "Error toggling flashlight", e)
            "ফ্ল্যাশলাইট পরিবর্তন করা সম্ভব হয়নি: ${e.message}"
        }
    }

    /**
     * Fetches current battery level and charging status.
     */
    fun getBatteryStatus(): String {
        return try {
            val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            val level = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
            val isCharging = batteryManager.isCharging
            val chargeStatus = if (isCharging) "চার্জ হচ্ছে ⚡" else "ডিসচার্জ হচ্ছে"
            "আপনার ফোনের ব্যাটারি লেভেল $level% ($chargeStatus)।"
        } catch (e: Exception) {
            "ব্যাটারি তথ্য পড়তে সমস্যা হয়েছে।"
        }
    }
}
