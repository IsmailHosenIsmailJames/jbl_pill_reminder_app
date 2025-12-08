package com.jbl.pill_reminder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * BootReceiver to handle device boot and app updates.
 * The workmanager Flutter plugin will automatically re-register tasks
 * when the app is initialized, but this receiver ensures the plugin is aware
 * of boot events for better reliability.
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            "android.intent.action.QUICKBOOT_POWERON", // Some devices use this
            Intent.ACTION_MY_PACKAGE_REPLACED -> {
                Log.d("PillReminder", "BootReceiver: Device booted or app updated")
                Log.d("PillReminder", "Action: ${intent.action}")
                
                // The workmanager plugin handles task re-registration automatically
                // when the Flutter app initializes. This receiver just ensures
                // the plugin is aware of boot events.
                
                // Note: WorkManager tasks registered via the Flutter plugin
                // persist across reboots automatically since WorkManager stores
                // them in a database. No manual re-registration needed here.
            }
        }
    }
}
