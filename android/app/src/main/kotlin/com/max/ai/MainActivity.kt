package com.max.ai

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.max.ai/system"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    val batteryLevel = getBatteryPercentage()
                    result.success(batteryLevel)
                }
                "getMemoryInfo" -> {
                    val memInfo = getMemoryUsage()
                    result.success(memInfo)
                }
                "getDeviceInfo" -> {
                    val deviceData = mapOf(
                        "model" to Build.MODEL,
                        "brand" to Build.MANUFACTURER,
                        "androidVersion" to Build.VERSION.RELEASE,
                        "sdkInt" to Build.VERSION.SDK_INT,
                        "board" to Build.BOARD
                    )
                    result.success(deviceData)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getBatteryPercentage(): Int {
        val intent: Intent? = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level: Int = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale: Int = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        return if (level >= 0 && scale > 0) {
            (level * 100 / scale)
        } else {
            -1
        }
    }

    private fun getMemoryUsage(): Map<String, Long> {
        val actManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        actManager.getMemoryInfo(memInfo)
        return mapOf(
            "totalMemMb" to (memInfo.totalMem / (1024 * 1024)),
            "availMemMb" to (memInfo.availMem / (1024 * 1024)),
            "thresholdMb" to (memInfo.threshold / (1024 * 1024)),
            "isLowMem" to if (memInfo.lowMemory) 1L else 0L
        )
    }
}
