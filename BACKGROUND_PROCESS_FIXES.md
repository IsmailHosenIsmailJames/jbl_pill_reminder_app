# Background Process and Notification Fixes

## Summary of Changes

This document outlines all the changes made to fix background process issues with WorkManager, alarms, and notifications in your Pill Reminder app.

## Problems Fixed

1. ✅ Android OS killing background processes
2. ✅ WorkManager tasks not surviving battery optimization
3. ✅ Alarms and notifications not triggering reliably
4. ✅ Background tasks not restarting after device reboot
5. ✅ Missing proper permissions for Android 14+
6. ✅ Callback dispatcher not properly initialized

## Changes Made

### 1. Android Manifest Updates (`android/app/src/main/AndroidManifest.xml`)

**Added Permissions:**
- `FOREGROUND_SERVICE_HEALTH` - Required for Android 14+ health-related foreground services
- `REQUEST_COMPANION_RUN_IN_BACKGROUND` - Helps with background execution
- `com.android.alarm.permission.SET_ALARM` - Additional alarm permission

**Updated Service:**
- Changed foreground service type from `dataSync` to `health` (more appropriate for pill reminders)

**Added BootReceiver:**
- Automatically restarts WorkManager tasks after device reboot
- Handles package updates to re-register tasks

### 2. Main Application (`lib/main.dart`)

**Enhanced CallbackDispatcher:**
- Properly initializes Hive, Alarm, and AwesomeNotifications in background isolate
- Added error handling with try-catch
- Fixed inputData key from "inputData" to "reloadDB"

**Improved WorkManager Configuration:**
- Added `Constraints` to prevent tasks from being killed
- Added `BackoffPolicy` for retry logic
- Integrated with new `BackgroundTaskManager` helper class

**Enhanced Permission Request:**
- Added visual improvements (icon, better layout)
- Created informative dialog about battery optimization
- Manufacturer-specific instructions for:
  - Xiaomi/Redmi
  - Samsung
  - Huawei
  - Oppo/Realme
- Direct link to battery optimization settings

### 3. New Files Created

**`lib/src/core/background/background_task_manager.dart`**
- Centralized task management
- Registers 15-minute and daily tasks
- Proper constraint configuration
- Task cancellation utilities

**`android/app/src/main/kotlin/com/jbl/pill_reminder/BootReceiver.kt`**
- Listens for boot completed events
- Re-registers WorkManager tasks on boot
- Handles app updates

## How to Use

### For Users

After updating the app, users need to:

1. **Grant Required Permissions:**
   - Notifications
   - Schedule Exact Alarms
   - Disable Battery Optimization

2. **Manufacturer-Specific Settings:**

   **Xiaomi/Redmi:**
   - Go to Settings → Apps → Manage apps → Pill Reminder
   - Enable "Autostart"
   - Go to Battery saver → Choose "No restrictions"

   **Samsung:**
   - Go to Settings → Apps → Pill Reminder → Battery
   - Select "Unrestricted"

   **Huawei:**
   - Go to Settings → Apps → Apps → Pill Reminder
   - Battery → App launch → "Manage manually"
   - Enable all options (Auto-launch, Secondary launch, Run in background)

   **Oppo/Realme:**
   - Go to Settings → Battery → Battery optimization
   - Find "Pill Reminder" → Select "Don't optimize"
   - Go to Settings → App Management → Pill Reminder
   - Enable "Startup Manager"

   **OnePlus:**
   - Go to Settings → Battery → Battery optimization
   - Select "All apps" → Find "Pill Reminder" → "Don't optimize"

### For Developers

**Testing Background Tasks:**

```bash
# View WorkManager tasks
adb shell dumpsys jobscheduler | grep pill_reminder

# Check alarms
adb shell dumpsys alarm | grep pill_reminder

# Monitor logs
adb logcat | grep -E "BootReceiver|WorkManager|Alarm"

# Simulate reboot
adb shell am broadcast -a android.intent.action.BOOT_COMPLETED

# Kill app and test
adb shell am force-stop com.jbl.pill_reminder
```

**Force run WorkManager task (for testing):**

```bash
adb shell cmd jobscheduler run -f com.jbl.pill_reminder 1
```

## Best Practices Implemented

1. **Proper Constraints:**
   - No network required
   - No battery level requirements
   - Works on all device states

2. **Backoff Policy:**
   - Linear backoff with 30-second delay
   - Prevents excessive retries

3. **Boot Persistence:**
   - Tasks automatically re-register on reboot
   - Handles app updates gracefully

4. **Error Handling:**
   - Try-catch in callback dispatcher
   - Graceful failure recovery

5. **User Guidance:**
   - Clear permission explanations
   - Manufacturer-specific instructions
   - Direct settings access

## Known Limitations

1. **Minimum Task Interval:**
   - Android limits periodic tasks to minimum 15 minutes
   - Cannot schedule more frequent background checks

2. **Manufacturer Restrictions:**
   - Some manufacturers (Xiaomi, Huawei, etc.) have very aggressive battery optimization
   - Users MUST manually disable these restrictions
   - No programmatic way to bypass manufacturer restrictions

3. **Doze Mode:**
   - In deep doze mode, tasks may be delayed
   - Exact alarms still work, but WorkManager tasks may be batched

4. **Android 12+ Restrictions:**
   - Stricter background execution limits
   - Foreground service notifications required

## Testing Checklist

- [ ] Install app and grant all permissions
- [ ] Verify battery optimization is disabled
- [ ] Set a reminder for 1 minute from now
- [ ] Close the app completely
- [ ] Wait for notification/alarm
- [ ] Reboot device
- [ ] Verify reminders still work after reboot
- [ ] Test on different manufacturers (Xiaomi, Samsung, etc.)
- [ ] Leave app closed for 24+ hours and verify it still works

## Additional Resources

- [Android Background Execution Limits](https://developer.android.com/about/versions/oreo/background)
- [WorkManager Documentation](https://developer.android.com/topic/libraries/architecture/workmanager)
- [Don't Kill My App](https://dontkillmyapp.com/) - Manufacturer-specific guides

## Troubleshooting

**Reminders not working:**
1. Check battery optimization is disabled
2. Verify autostart is enabled (manufacturer-specific)
3. Check notification permissions
4. Verify exact alarm permission (Android 12+)

**Tasks not running after reboot:**
1. Check BOOT_COMPLETED permission
2. Verify BootReceiver is registered
3. Check device logs for errors

**Notifications delayed:**
1. This is expected in doze mode
2. Use alarms for critical reminders (they bypass doze)
3. Consider foreground service for high-priority apps

## Future Improvements

1. Add device manufacturer detection
2. Auto-detect and warn about aggressive battery optimization
3. Implement foreground service option for critical reminders
4. Add in-app task status monitoring
5. Implement notification delivery verification
6. Add reminder statistics and missed dose tracking
