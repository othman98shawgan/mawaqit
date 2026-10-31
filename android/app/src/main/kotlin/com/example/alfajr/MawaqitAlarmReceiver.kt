package com.example.alfajr

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class MawaqitAlarmReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_ALARM_TRIGGER = "com.othman.mawaqitquds.ACTION_ALARM_TRIGGER"
        const val ACTION_DISMISS = "com.othman.mawaqitquds.ACTION_DISMISS"
        const val ACTION_SNOOZE = "com.othman.mawaqitquds.ACTION_SNOOZE"
    }

    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            ACTION_ALARM_TRIGGER -> {
                val id = intent.getIntExtra("alarm_id", 810999)
                val prayerName = intent.getStringExtra("prayer_name") ?: "Fajr"
                val soundName = intent.getStringExtra("sound_name") ?: "alaqsa"
                val title = intent.getStringExtra("title") ?: "Time for $prayerName"
                val body = intent.getStringExtra("body") ?: ""
                val dismissLabel = intent.getStringExtra("dismiss_label") ?: "Dismiss"
                val snoozeLabel = intent.getStringExtra("snooze_label") ?: "Snooze"
                val snoozeMinutes = intent.getIntExtra("snooze_minutes", 10)
                val vibrate = intent.getBooleanExtra("vibrate", true)

                AlarmController.startAlarm(
                    context = context,
                    id = id,
                    prayerName = prayerName,
                    soundName = soundName,
                    title = title,
                    body = body,
                    dismissLabel = dismissLabel,
                    snoozeLabel = snoozeLabel,
                    snoozeMinutes = snoozeMinutes,
                    vibrate = vibrate
                )
            }
            ACTION_DISMISS -> {
                val id = intent.getIntExtra("alarm_id", -1)
                if (id != -1) {
                    AlarmController.stopAlarm(context, id)
                } else {
                    AlarmController.stopAlarm(context)
                }
            }
            ACTION_SNOOZE -> {
                val id = intent.getIntExtra("alarm_id", 810090)
                val prayerName = intent.getStringExtra("prayer_name") ?: "Fajr"
                val soundName = intent.getStringExtra("sound_name") ?: "alaqsa"
                val snoozeMinutes = intent.getIntExtra("snooze_minutes", 5)
                val dismissLabel = intent.getStringExtra("dismiss_label") ?: "Dismiss"
                val snoozeLabel = intent.getStringExtra("snooze_label") ?: "Snooze"
                val title = intent.getStringExtra("title") ?: "Snooze: $prayerName"
                val body = "Alarm snoozed for $snoozeMinutes minutes"

                AlarmController.stopAlarm(context, id)

                val triggerAtMillis = System.currentTimeMillis() + (snoozeMinutes * 60 * 1000L)
                AlarmController.scheduleExactAlarm(
                    context = context,
                    id = id,
                    triggerAtMillis = triggerAtMillis,
                    prayerName = if (prayerName.startsWith("Snooze:")) prayerName else "Snooze: $prayerName",
                    soundName = soundName,
                    title = title,
                    body = body,
                    dismissLabel = dismissLabel,
                    snoozeLabel = snoozeLabel,
                    snoozeMinutes = snoozeMinutes,
                    vibrate = true
                )
            }
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            "android.intent.action.QUICKBOOT_POWERON",
            "com.htc.intent.action.QUICKBOOT_POWERON" -> {
                AlarmController.restoreAlarms(context)
            }
        }
    }
}
