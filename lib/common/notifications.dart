import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

late NotificationAppLaunchDetails notificationAppLaunchDetails;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

Future<void> initializeNotifications() async {
  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  const initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_notification');
  const initializationSettings =
      InitializationSettings(initializationSettingsAndroid, null);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    selectNotificationSubject.add(payload);
  },);
}

void configureSelectNotificationSubject(context) {
  selectNotificationSubject.stream.listen((String payload) async {
//    await Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => SecondScreen(payload)),
//    );
  });
}

Future<void> showChatNotification(
    String chatId, String title, String body,) async {
  // For multiple messages check: inbox notification
  //  var largeIconPath = await _downloadAndSaveFile(
  //      'http://via.placeholder.com/128x128/00FF00/000000', 'largeIcon');

  const androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'RetroshareFlutter', 'RetroshareFlutter', 'Retroshare flutter app',
    importance: Importance.Max,
    priority: Priority.High,
    ticker: 'ticker',
    color: Color.fromARGB(255, 35, 144, 191),
    ledColor: Color.fromARGB(255, 35, 144, 191),
    ledOnMs: 1000,
    ledOffMs: 500,
//      largeIcon: FilePathAndroidBitmap(largeIconPath),
  );
  const platformChannelSpecifics =
      NotificationDetails(androidPlatformChannelSpecifics, null);
  await flutterLocalNotificationsPlugin.show(
    int.parse(chatId),
    title,
    body,
    platformChannelSpecifics,
    payload: chatId,
  );
}

Future<void> showInviteCopyNotification() async {
  const androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'RetroshareFlutter',
    'RetroshareFlutter',
    'Retroshare flutter app',
    ticker: 'ticker',
  );
  const platformChannelSpecifics =
      NotificationDetails(androidPlatformChannelSpecifics, null);
  await flutterLocalNotificationsPlugin.show(
      1111,
      'Invite copied!',
      'Your RetroShare invite was copied to your clipboard',
      platformChannelSpecifics,);
}
