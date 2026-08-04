import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// background notification manger
Future<void> firebaseMessaginBackgroundHandler(
    RemoteMessage remoteMessage) async {
  await Firebase.initializeApp();
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin localNotificationsPlugin;

mixin FBNotificationsController {
  ///called in main funcation between ensureInitialized <-> runApp
  static Future<void> initNotifications() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessaginBackgroundHandler);

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'flutter_android_notifications_channel',
        'flutter_android_Notifications_Channel',
        description:
            'This channel will receive notifications specific to news-app',
        importance: Importance.high,
        enableLights: true,
        enableVibration: true,
        // ledColor: Colors.orange,
        showBadge: true,
        playSound: true,
      );
    }

    // android foreground
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // IOS foreground
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void initializeForegroundNotificationForAndroid() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? androidNotification = notification?.android;

      if (notification != null && androidNotification != null) {
        localNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
            )));
      }
    });
  }

  Future<void> requestNotificationPermissions() async {
    NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      sound: true,
      badge: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
    }
  }

  void mangeNotificationAction() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _controlNotificationNavigation(message.data);
    });
  }

  void _controlNotificationNavigation(Map<String, dynamic> data) {
    if (data['page'] == 'message') {}
  }
}
