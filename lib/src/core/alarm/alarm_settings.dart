import 'dart:io';

import 'package:alarm/alarm.dart';

final alarmSettings = AlarmSettings(
  id: 42,
  dateTime: DateTime.now().add(const Duration(seconds: 30)),
  assetAudioPath: 'assets/shaking-pill-bottle.mp3',
  loopAudio: true,
  vibrate: true,
  volume: 0.8,
  fadeDuration: 3.0,
  warningNotificationOnKill: Platform.isIOS,
  androidFullScreenIntent: true,
  notificationSettings: const NotificationSettings(
    title: 'This is the title',
    body: 'This is the body',
    stopButton: 'Stop the alarm',
    icon: 'notification_icon',
  ),
);
