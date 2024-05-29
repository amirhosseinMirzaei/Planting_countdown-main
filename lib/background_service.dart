import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'PlantingPage/presentation/page/planting_page.dart';

class PlantingService {
  Timer? timer;
  String iconAddress = '@mipmap/ic_launcher_adaptive_fore';
  int channelId = 1231231;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> startForegroundService({required Types type}) async {
    if (kIsWeb) return;
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher_adaptive_fore');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId.toString(),
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    updateNotification(
        flutterLocalNotificationsPlugin, platformChannelSpecifics,
        type: type);
  }

  void updateNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      NotificationDetails platformChannelSpecifics,
      {required Types type}) {
    flutterLocalNotificationsPlugin.show(
        channelId, // Notification ID
        'فعالیت ${getTypeName(type: type)} شما در حال اجراست', // Notification title
        'برای حذف یا توقف لمس کنید', // Notification body with current time
        platformChannelSpecifics);
  }

  void stopService() {
    if (kIsWeb) return;
    flutterLocalNotificationsPlugin.cancel(channelId);
  }

  String? getTypeName({required Types type}) {
    switch (type) {
      case Types.STUDY:
        return "مطالعه";
      case Types.ENTERTAINMENT:
        return "سرگرمی";
      case Types.OTHER:
        return "متفرقه";
      case Types.REST:
        return "استراحت";
      case Types.SOCIAL:
        return "شبکه اجتماعی";
      case Types.SPORT:
        return "ورزش";
      case Types.UNSET:
        return "تعیین نشده";
      case Types.WORK:
        return "کار";
    }
  }
}
