package com.getmaya.android.automation

import android.content.Context
import android.content.Intent
import android.hardware.camera2.CameraManager
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.telephony.SmsManager
import android.util.Log

object DeviceController {
    private const val TAG = "DeviceController"

    fun setTorch(context: Context, enable: Boolean): String {
        return try {
            val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
            val cameraId = cameraManager.cameraIdList[0]
            cameraManager.setTorchMode(cameraId, enable)
            "Flashlight turned ${if (enable) "ON" else "OFF"}"
        } catch (e: Exception) {
            "Failed to toggle flashlight: ${e.message}"
        }
    }

    fun setVolume(context: Context, percent: Int): String {
        return try {
            val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
            val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
            val target = ((percent.coerceIn(0, 100) / 100.0) * maxVolume).toInt()
            audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, target, AudioManager.FLAG_SHOW_UI)
            "Media volume set to $percent%"
        } catch (e: Exception) {
            "Failed to set volume: ${e.message}"
        }
    }

    fun makeCall(context: Context, number: String): String {
        return try {
            val intent = Intent(Intent.ACTION_CALL, Uri.parse("tel:${Uri.encode(number)}")).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            "Calling $number..."
        } catch (e: Exception) {
            // Fallback to DIAL
            try {
                val dialIntent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:${Uri.encode(number)}")).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(dialIntent)
                "Opened dialer for $number"
            } catch (ex: Exception) {
                "Failed to initiate call: ${ex.message}"
            }
        }
    }

    fun sendSms(context: Context, number: String, text: String): String {
        return try {
            val smsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                context.getSystemService(SmsManager::class.java)
            } else {
                @Suppress("DEPRECATION")
                SmsManager.getDefault()
            }
            smsManager.sendTextMessage(number, null, text, null, null)
            "SMS sent to $number"
        } catch (e: Exception) {
            "Failed to send SMS: ${e.message}"
        }
    }

    fun openApp(context: Context, appNameOrPackage: String): String {
        val pm = context.packageManager
        // Check exact package
        var launchIntent = pm.getLaunchIntentForPackage(appNameOrPackage)
        if (launchIntent == null) {
            // Find by label
            val apps = pm.getInstalledApplications(0)
            for (app in apps) {
                val label = pm.getApplicationLabel(app).toString()
                if (label.contains(appNameOrPackage, ignoreCase = true)) {
                    launchIntent = pm.getLaunchIntentForPackage(app.packageName)
                    break
                }
            }
        }
        return if (launchIntent != null) {
            launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(launchIntent)
            "Opened $appNameOrPackage"
        } else {
            "App '$appNameOrPackage' not found"
        }
    }

    fun sendWhatsApp(context: Context, phoneOrName: String, message: String): String {
        return try {
            val cleanPhone = phoneOrName.filter { it.isDigit() }
            val uri = if (cleanPhone.length >= 7) {
                Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encode(message)}")
            } else {
                Uri.parse("https://api.whatsapp.com/send?text=${Uri.encode(message)}")
            }
            val intent = Intent(Intent.ACTION_VIEW, uri).apply {
                setPackage("com.whatsapp")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            "WhatsApp launched with message"
        } catch (e: Exception) {
            "WhatsApp not available: ${e.message}"
        }
    }

    fun playYouTube(context: Context, query: String): String {
        return try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/results?search_query=${Uri.encode(query)}")).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            "Playing on YouTube: $query"
        } catch (e: Exception) {
            "Failed to open YouTube: ${e.message}"
        }
    }
}
