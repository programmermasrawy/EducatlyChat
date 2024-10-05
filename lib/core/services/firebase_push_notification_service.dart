import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebasePushNotificationService {
  static final FirebasePushNotificationService _singleton =
      FirebasePushNotificationService._internal();

  factory FirebasePushNotificationService() {
    return _singleton;
  }

  FirebasePushNotificationService._internal();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void inializeFCMService({void Function(int state)? onFcmRecieved}) async {
    flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('mipmap/ic_launcher'),
      ),
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    log("Handling a background message: ${message.messageId}");
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'channelId',
      'Local Notification',
      channelDescription: 'Local description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      '${message.notification?.title}',
      '${message.notification?.body}',
      notificationDetails,
      payload: message.data.toString(),
    );
  }
}
