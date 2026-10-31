package com.example.alfajr

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.othman.mawaqitquds/alarm"
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        wakeScreen()
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        wakeScreen()
        handleIntent(intent)
    }

    private fun extractPayload(intent: Intent?): String? {
        if (intent == null) return null
        val p = intent.getStringExtra("payload")
        if (!p.isNullOrEmpty() && p.contains("alarm|")) return p
        val extras = intent.extras
        if (extras != null) {
            for (key in extras.keySet()) {
                val value = extras.get(key)
                if (value is String && value.contains("alarm|")) {
                    return value
                }
            }
        }
        val data = intent.dataString
        if (!data.isNullOrEmpty() && data.contains("alarm|")) {
            return data
        }
        return null
    }

    private fun handleIntent(intent: Intent?) {
        val payload = extractPayload(intent)
        if (payload != null && payload.contains("alarm|")) {
            wakeScreen()
            val clean = payload.substring(payload.indexOf("alarm|"))
            val parts = clean.split("|")
            val soundName = if (parts.size >= 3) parts[2] else "alaqsa"
            if (soundName != "silent") {
                AlarmController.startAudio(applicationContext, soundName)
            }
            AlarmController.pendingAlarmPayload = clean
            methodChannel?.invokeMethod("onAlarmTriggered", clean)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AlarmController.onAlarmTriggeredCallback = { payload ->
            runOnUiThread {
                wakeScreen()
                methodChannel?.invokeMethod("onAlarmTriggered", payload)
            }
        }

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "wakeScreen" -> {
                        wakeScreen()
                        result.success(true)
                    }
                    "startAlarmAudio" -> {
                        val soundName = call.argument<String>("soundName") ?: "alaqsa"
                        if (soundName != "silent") {
                            AlarmController.startAudio(applicationContext, soundName)
                        }
                        result.success(true)
                    }
                    "stopAlarmAudio" -> {
                        AlarmController.stopAlarm(applicationContext)
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                        result.success(true)
                    }
                    "scheduleNativeAlarm" -> {
                        val id = call.argument<Int>("id") ?: 810999
                        val triggerAtMillis = call.argument<Number>("triggerAtMillis")?.toLong()
                            ?: (System.currentTimeMillis() + 5000L)
                        val prayerName = call.argument<String>("prayerName") ?: "Fajr"
                        val soundName = call.argument<String>("soundName") ?: "alaqsa"
                        val title = call.argument<String>("title") ?: "$prayerName Alarm"
                        val body = call.argument<String>("body") ?: ""
                        val dismissLabel = call.argument<String>("dismissLabel") ?: "Dismiss"
                        val snoozeLabel = call.argument<String>("snoozeLabel") ?: "Snooze"
                        val snoozeMinutes = call.argument<Int>("snoozeMinutes") ?: 10
                        val vibrate = call.argument<Boolean>("vibrate") ?: true

                        AlarmController.scheduleExactAlarm(
                            context = applicationContext,
                            id = id,
                            triggerAtMillis = triggerAtMillis,
                            prayerName = prayerName,
                            soundName = soundName,
                            title = title,
                            body = body,
                            dismissLabel = dismissLabel,
                            snoozeLabel = snoozeLabel,
                            snoozeMinutes = snoozeMinutes,
                            vibrate = vibrate
                        )
                        result.success(true)
                    }
                    "cancelNativeAlarm" -> {
                        val id = call.argument<Int>("id") ?: 810999
                        AlarmController.cancelExactAlarm(applicationContext, id)
                        result.success(true)
                    }
                    "canUseFullScreenIntent" -> {
                        var allowed = true
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                            allowed = allowed && nm.canUseFullScreenIntent()
                        }
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            allowed = allowed && Settings.canDrawOverlays(applicationContext)
                        }
                        result.success(allowed)
                    }
                    "openFullScreenIntentSettings" -> {
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(applicationContext)) {
                                val intent = Intent(
                                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                    Uri.parse("package:$packageName")
                                ).apply {
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(intent)
                            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                                val intent = Intent(
                                    Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT,
                                    Uri.parse("package:$packageName")
                                ).apply {
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(intent)
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SETTINGS_ERROR", e.message, null)
                        }
                    }
                    "triggerAlarmNow" -> {
                        val payload = call.argument<String>("payload")
                        if (payload != null) {
                            val dummyIntent = Intent().apply {
                                putExtra("payload", payload)
                            }
                            handleIntent(dummyIntent)
                        }
                        result.success(true)
                    }
                    "getPendingAlarmPayload" -> {
                        val p = AlarmController.pendingAlarmPayload
                        AlarmController.pendingAlarmPayload = null
                        result.success(p)
                    }
                    "getScheduledNativeAlarms" -> {
                        val alarms = AlarmController.getScheduledAlarms(applicationContext)
                        result.success(alarms)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        AlarmController.pendingAlarmPayload?.let {
            methodChannel?.invokeMethod("onAlarmTriggered", it)
        }
    }

    private fun wakeScreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }

    override fun onDestroy() {
        if (AlarmController.onAlarmTriggeredCallback != null) {
            AlarmController.onAlarmTriggeredCallback = null
        }
        super.onDestroy()
    }
}
