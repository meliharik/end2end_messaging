import 'package:end2end_messaging/home.dart';
import 'package:end2end_messaging/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
  debugPrint(message.data.toString());
  debugPrint(message.notification!.body);
  debugPrint(message.notification!.title);
}

class NotificationService {
  final firebaseMessaging = FirebaseMessaging.instance;

  void handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'message') {
      GlobalcontextService.navigatorKey.currentState!.push(
        CupertinoPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }
  }

  Future<void> initNotificationService() async {
    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Handling a foreground message: ${message.messageId}");
      debugPrint(message.data.toString());
      debugPrint(message.notification!.body);
      debugPrint(message.notification!.title);
      handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Handling a message with tap: ${message.messageId}");
      debugPrint(message.data.toString());
      debugPrint(message.notification!.body);
      debugPrint(message.notification!.title);
      handleMessage(message);
    });

    final token = await firebaseMessaging.getToken();
    debugPrint('token: $token');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
