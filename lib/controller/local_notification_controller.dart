import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotification() async {
  // إعداد الإشعارات لنظام Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // تأكد من أن أيقونة التطبيق معرفة

  // إعدادات عامة لجميع الأنظمة (هنا فقط Android)
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // تهيئة الإشعارات
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// دالة لإظهار الإشعار
Future<void> showNotification({
  required int id,
  required String title,
  required String message,
}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'flutter_android_notifications_channel', // معرف القناة
    'flutter_android_notifications_channel', // اسم القناة
    importance: Importance.max, // أهمية الإشعار
    priority: Priority.high, // أولوية الإشعار
    icon: '@mipmap/ic_launcher',
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    id, // معرف فريد للإشعار
    title, // عنوان الإشعار
    message, // محتوى الإشعار
    platformChannelSpecifics,
  );
}
