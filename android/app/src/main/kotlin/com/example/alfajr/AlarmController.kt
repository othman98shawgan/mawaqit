package com.example.alfajr

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.core.app.NotificationCompat

object AlarmController {
    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var previousAlarmVolume: Int? = null

    var pendingAlarmPayload: String? = null
    var onAlarmTriggeredCallback: ((String) -> Unit)? = null

    fun startAlarm(
        context: Context,
        id: Int,
        prayerName: String,
        soundName: String,
        title: String,
        body: String,
        dismissLabel: String,
        snoozeLabel: String,
        snoozeMinutes: Int,
        vibrate: Boolean
    ) {
        val appContext = context.applicationContext
        acquireWakeLock(appContext)

        val payload = "alarm|$prayerName|$soundName|$snoozeMinutes"
        pendingAlarmPayload = payload

        // 1. Start continuous looping audio at max volume on STREAM_ALARM (skip if silent)
        if (soundName != "silent") {
            startAudio(appContext, soundName)
        }

        // 2. Start vibration if enabled or if alarm is silent
        if (vibrate || soundName == "silent") {
            startVibration(appContext)
        }

        // 3. Post silent ongoing notification with Dismiss / Snooze buttons
        showAlarmNotification(
            appContext,
            id = id,
            prayerName = prayerName,
            soundName = soundName,
            title = title,
            body = body,
            dismissLabel = dismissLabel,
            snoozeLabel = snoozeLabel,
            snoozeMinutes = snoozeMinutes,
            payload = payload
        )

        // 4. Immediately launch MainActivity to show the Stop/Snooze screen
        try {
            val activityIntent = Intent(appContext, MainActivity::class.java).apply {
                action = "com.othman.mawaqitquds.ALARM_RING"
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
                putExtra("payload", payload)
                putExtra("alarm_id", id)
            }
            appContext.startActivity(activityIntent)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // 5. Notify Flutter if engine is already alive
        onAlarmTriggeredCallback?.invoke(payload)
    }

    private fun acquireWakeLock(context: Context) {
        try {
            if (wakeLock?.isHeld == true) return
            val pm = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
            @Suppress("DEPRECATION")
            wakeLock = pm?.newWakeLock(
                PowerManager.FULL_WAKE_LOCK or
                        PowerManager.ACQUIRE_CAUSES_WAKEUP or
                        PowerManager.ON_AFTER_RELEASE,
                "mawaqit:alarm_wakelock"
            )?.apply {
                acquire(10 * 60 * 1000L) // 10 minutes max
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun startAudio(context: Context, soundName: String) {
        if (soundName == "silent") {
            return
        }
        if (mediaPlayer?.isPlaying == true) {
            return
        }
        stopAudioOnly(context)
        try {
            val appContext = context.applicationContext
            val audioManager = appContext.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
            audioManager?.let { am ->
                if (previousAlarmVolume == null) {
                    previousAlarmVolume = am.getStreamVolume(AudioManager.STREAM_ALARM)
                }
                val maxVol = am.getStreamMaxVolume(AudioManager.STREAM_ALARM)
                am.setStreamVolume(AudioManager.STREAM_ALARM, maxVol, 0)
            }

            val player = MediaPlayer()
            val attributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build()
            player.setAudioAttributes(attributes)

            val rawResName = when (soundName) {
                "alaqsa" -> "adhan_alaqsa"
                "makkah" -> "adhan_makkah"
                "madina" -> "adhan_madina"
                "abdulbasit" -> "adhan_abdulbasit"
                "minshawi" -> "adhan_minshawi"
                "hussary" -> "adhan_hussary"
                "nafees" -> "adhan_nafees"
                else -> soundName
            }

            if (soundName == "system") {
                val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                player.setDataSource(appContext, alarmUri)
            } else {
                val resId = appContext.resources.getIdentifier(rawResName, "raw", appContext.packageName)
                if (resId != 0) {
                    val afd = appContext.resources.openRawResourceFd(resId)
                    player.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                    afd.close()
                } else {
                    val defaultUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                    player.setDataSource(appContext, defaultUri)
                }
            }

            player.isLooping = true
            player.prepare()
            player.start()
            mediaPlayer = player
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun startVibration(context: Context) {
        try {
            val vib = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vm = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
                vm?.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
            }
            if (vib?.hasVibrator() == false) {
                return
            }
            vibrator = vib
            val pattern = longArrayOf(0, 1000, 500, 1000, 500, 1000)
            val attributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vib?.vibrate(VibrationEffect.createWaveform(pattern, 0), attributes)
            } else {
                @Suppress("DEPRECATION")
                vib?.vibrate(pattern, 0)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stopAudioOnly(context: Context) {
        try {
            mediaPlayer?.let {
                if (it.isPlaying) {
                    it.stop()
                }
                it.reset()
                it.release()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            mediaPlayer = null
        }

        try {
            vibrator?.cancel()
            vibrator = null
        } catch (e: Exception) {
            e.printStackTrace()
        }

        try {
            previousAlarmVolume?.let { prevVol ->
                val audioManager = context.applicationContext.getSystemService(Context.AUDIO_SERVICE) as? AudioManager
                audioManager?.setStreamVolume(AudioManager.STREAM_ALARM, prevVol, 0)
                previousAlarmVolume = null
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
            }
            wakeLock = null
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun stopAlarm(context: Context, id: Int? = null) {
        val appContext = context.applicationContext
        stopAudioOnly(appContext)
        pendingAlarmPayload = null
        val nm = appContext.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        if (id != null) {
            nm?.cancel(id)
            removeAlarmFromPrefs(appContext, id)
        } else {
            // Cancel all known alarm notification IDs
            val ids = intArrayOf(810010, 810020, 810030, 810040, 810050, 810060, 810090, 810091, 810092, 810093, 810094, 810095, 810999)
            for (alarmId in ids) {
                nm?.cancel(alarmId)
            }
        }
    }

    private fun showAlarmNotification(
        context: Context,
        id: Int,
        prayerName: String,
        soundName: String,
        title: String,
        body: String,
        dismissLabel: String,
        snoozeLabel: String,
        snoozeMinutes: Int,
        payload: String
    ) {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "mawaqit_native_alarm_silent_v3"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Prayer Alarm Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "High-priority prayer alarm controls"
                setSound(null, null)
                enableVibration(false)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
                setBypassDnd(true)
            }
            nm.createNotificationChannel(channel)
        }

        val fullScreenIntent = Intent(context, MainActivity::class.java).apply {
            action = "com.othman.mawaqitquds.ALARM_RING"
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("payload", payload)
            putExtra("alarm_id", id)
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context,
            id,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val dismissIntent = Intent(context, MawaqitAlarmReceiver::class.java).apply {
            action = MawaqitAlarmReceiver.ACTION_DISMISS
            putExtra("alarm_id", id)
            putExtra("prayer_name", prayerName)
        }
        val dismissPendingIntent = PendingIntent.getBroadcast(
            context,
            id + 1000,
            dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val iconResId = context.resources.getIdentifier("launcher_icon", "drawable", context.packageName)
            .let { if (it != 0) it else android.R.drawable.ic_lock_idle_alarm }

        val builder = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(iconResId)
            .setContentTitle(title)
            .setContentText(body)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setAutoCancel(false)
            .setSilent(true)
            .setContentIntent(fullScreenPendingIntent)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .addAction(0, dismissLabel, dismissPendingIntent)

        if (snoozeMinutes > 0) {
            val snoozeIntent = Intent(context, MawaqitAlarmReceiver::class.java).apply {
                action = MawaqitAlarmReceiver.ACTION_SNOOZE
                putExtra("alarm_id", id)
                putExtra("prayer_name", prayerName)
                putExtra("sound_name", soundName)
                putExtra("title", title)
                putExtra("body", body)
                putExtra("dismiss_label", dismissLabel)
                putExtra("snooze_label", snoozeLabel)
                putExtra("snooze_minutes", snoozeMinutes)
            }
            val snoozePendingIntent = PendingIntent.getBroadcast(
                context,
                id + 2000,
                snoozeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            builder.addAction(0, snoozeLabel, snoozePendingIntent)
        }

        nm.notify(id, builder.build())
    }

    fun scheduleExactAlarm(
        context: Context,
        id: Int,
        triggerAtMillis: Long,
        prayerName: String,
        soundName: String,
        title: String,
        body: String,
        dismissLabel: String,
        snoozeLabel: String,
        snoozeMinutes: Int,
        vibrate: Boolean
    ) {
        val appContext = context.applicationContext
        val alarmManager = appContext.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        val receiverIntent = Intent(appContext, MawaqitAlarmReceiver::class.java).apply {
            action = MawaqitAlarmReceiver.ACTION_ALARM_TRIGGER
            putExtra("alarm_id", id)
            putExtra("prayer_name", prayerName)
            putExtra("sound_name", soundName)
            putExtra("title", title)
            putExtra("body", body)
            putExtra("dismiss_label", dismissLabel)
            putExtra("snooze_label", snoozeLabel)
            putExtra("snooze_minutes", snoozeMinutes)
            putExtra("vibrate", vibrate)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            appContext,
            id,
            receiverIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val showIntent = Intent(appContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val showPendingIntent = PendingIntent.getActivity(
            appContext,
            id + 5000,
            showIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmClockInfo = AlarmManager.AlarmClockInfo(triggerAtMillis, showPendingIntent)
        alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
        saveAlarmToPrefs(
            appContext,
            id,
            triggerAtMillis,
            prayerName,
            soundName,
            title,
            body,
            dismissLabel,
            snoozeLabel,
            snoozeMinutes,
            vibrate
        )
    }

    fun cancelExactAlarm(context: Context, id: Int) {
        val appContext = context.applicationContext
        val alarmManager = appContext.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val receiverIntent = Intent(appContext, MawaqitAlarmReceiver::class.java).apply {
            action = MawaqitAlarmReceiver.ACTION_ALARM_TRIGGER
        }
        val pendingIntent = PendingIntent.getBroadcast(
            appContext,
            id,
            receiverIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pendingIntent)
        val nm = appContext.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        nm?.cancel(id)
        removeAlarmFromPrefs(appContext, id)
    }

    private const val PREFS_NAME = "mawaqit_scheduled_alarms_v1"

    private fun saveAlarmToPrefs(
        context: Context,
        id: Int,
        triggerAtMillis: Long,
        prayerName: String,
        soundName: String,
        title: String,
        body: String,
        dismissLabel: String,
        snoozeLabel: String,
        snoozeMinutes: Int,
        vibrate: Boolean
    ) {
        try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val json = org.json.JSONObject().apply {
                put("id", id)
                put("triggerAtMillis", triggerAtMillis)
                put("prayerName", prayerName)
                put("soundName", soundName)
                put("title", title)
                put("body", body)
                put("dismissLabel", dismissLabel)
                put("snoozeLabel", snoozeLabel)
                put("snoozeMinutes", snoozeMinutes)
                put("vibrate", vibrate)
            }
            prefs.edit().putString("alarm_$id", json.toString()).apply()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun removeAlarmFromPrefs(context: Context, id: Int) {
        try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().remove("alarm_$id").apply()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun restoreAlarms(context: Context) {
        try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val now = System.currentTimeMillis()
            val allEntries = prefs.all
            val editor = prefs.edit()
            for ((key, value) in allEntries) {
                if (value is String) {
                    try {
                        val obj = org.json.JSONObject(value)
                        val triggerAtMillis = obj.optLong("triggerAtMillis", 0L)
                        val id = obj.optInt("id", 0)
                        if (triggerAtMillis > now && id != 0) {
                            scheduleExactAlarm(
                                context = context,
                                id = id,
                                triggerAtMillis = triggerAtMillis,
                                prayerName = obj.optString("prayerName", "Fajr"),
                                soundName = obj.optString("soundName", "alaqsa"),
                                title = obj.optString("title", "Prayer Alarm"),
                                body = obj.optString("body", ""),
                                dismissLabel = obj.optString("dismissLabel", "Dismiss"),
                                snoozeLabel = obj.optString("snoozeLabel", "Snooze"),
                                snoozeMinutes = obj.optInt("snoozeMinutes", 10),
                                vibrate = obj.optBoolean("vibrate", true)
                            )
                        } else {
                            editor.remove(key)
                        }
                    } catch (e: Exception) {
                        editor.remove(key)
                    }
                }
            }
            editor.apply()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun getScheduledAlarms(context: Context): List<Map<String, Any>> {
        val list = mutableListOf<Map<String, Any>>()
        try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val now = System.currentTimeMillis()
            val allEntries = prefs.all
            val editor = prefs.edit()
            for ((key, value) in allEntries) {
                if (value is String) {
                    try {
                        val obj = org.json.JSONObject(value)
                        val triggerAtMillis = obj.optLong("triggerAtMillis", 0L)
                        val id = obj.optInt("id", 0)
                        if (triggerAtMillis > (now - 60000L) && id != 0) {
                            val map = mutableMapOf<String, Any>()
                            map["id"] = id
                            map["triggerAtMillis"] = triggerAtMillis
                            map["prayerName"] = obj.optString("prayerName", "")
                            map["soundName"] = obj.optString("soundName", "")
                            map["title"] = obj.optString("title", "")
                            map["body"] = obj.optString("body", "")
                            map["snoozeMinutes"] = obj.optInt("snoozeMinutes", 0)
                            map["vibrate"] = obj.optBoolean("vibrate", true)
                            map["isPast"] = triggerAtMillis <= now
                            list.add(map)
                        } else {
                            editor.remove(key)
                        }
                    } catch (e: Exception) {
                        editor.remove(key)
                    }
                }
            }
            editor.apply()
            list.sortBy { (it["triggerAtMillis"] as? Long) ?: 0L }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return list
    }
}
