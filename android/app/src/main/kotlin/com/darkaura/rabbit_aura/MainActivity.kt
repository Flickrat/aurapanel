package com.darkaura.rabbit_aura

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.roundToInt

class MainActivity : FlutterActivity() {
    private val channelName = "com.darkaura.rabbit/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "getDeviceInfo") {
                    result.success(collectDeviceInfo())
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun collectDeviceInfo(): Map<String, Any> {
        val am = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        am.getMemoryInfo(memInfo)

        val statFs = StatFs(Environment.getDataDirectory().path)
        val batteryIntent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level = batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, 0) ?: 0
        val scale = (batteryIntent?.getIntExtra(BatteryManager.EXTRA_SCALE, 100) ?: 100).coerceAtLeast(1)
        val batteryPct = (level * 100) / scale
        val status = batteryIntent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val health = batteryIntent?.getIntExtra(BatteryManager.EXTRA_HEALTH, -1) ?: -1
        val voltageMv = batteryIntent?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, 0) ?: 0
        val tempTenths = batteryIntent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 300) ?: 300

        val manufacturer = Build.MANUFACTURER?.takeIf { it.isNotEmpty() }
            ?.replaceFirstChar { it.uppercase() } ?: "Unknown"

        val chipset = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && Build.SOC_MODEL != "unknown") {
            "${Build.SOC_MANUFACTURER} ${Build.SOC_MODEL}".trim()
        } else {
            Build.HARDWARE
        }

        val refreshRate = try {
            @Suppress("DEPRECATION")
            val wm = getSystemService(Context.WINDOW_SERVICE) as WindowManager
            @Suppress("DEPRECATION")
            wm.defaultDisplay.mode.refreshRate.roundToInt()
        } catch (_: Exception) {
            60
        }

        return mapOf(
            "model" to Build.MODEL,
            "brand" to manufacturer,
            "osVersion" to "${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})",
            "chipset" to chipset,
            "cores" to Runtime.getRuntime().availableProcessors(),
            "abi" to (Build.SUPPORTED_ABIS.firstOrNull() ?: "unknown"),
            "ramTotalBytes" to memInfo.totalMem,
            "ramAvailBytes" to memInfo.availMem,
            "storageTotalBytes" to statFs.totalBytes,
            "storageAvailBytes" to statFs.availableBytes,
            "batteryLevel" to batteryPct,
            "batteryStatus" to status,
            "batteryHealth" to health,
            "batteryVoltage" to (voltageMv / 1000.0),
            "batteryTempC" to (tempTenths / 10.0),
            "refreshRateHz" to refreshRate,
        )
    }
}
