// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:end2end_messaging/main.dart';
import 'package:end2end_messaging/models/user.dart';
import 'package:end2end_messaging/screens/auth/enter_number.dart';
import 'package:end2end_messaging/screens/chat_screen.dart';
import 'package:end2end_messaging/screens/chats.dart';
import 'package:end2end_messaging/screens/people_screen.dart';
import 'package:end2end_messaging/screens/settings.dart';
import 'package:end2end_messaging/services/firestore_service.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final storage = const FlutterSecureStorage();

  void _configureFirebaseMessaging() {
    _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("onMessage: $message");
      _handleNotification(message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("onMessageOpenedApp: $message");
      _handleNotification(message.data);
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      debugPrint("onBackgroundMessage: $message");
      _handleNotification(message.data);
    });

    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      debugPrint("Push Messaging token: $token");
    });

    _firebaseMessaging.subscribeToTopic('all');

    _firebaseMessaging.onTokenRefresh.listen((event) {
      debugPrint("onTokenRefresh: $event");
    });

    _firebaseMessaging.getInitialMessage().then((message) {
      debugPrint("getInitialMessage: $message");
      if (message != null) {
        _handleNotification(message.data);
      }
    });
  }

  Future<void> _handleNotification(Map<String, dynamic> message) async {
    debugPrint("message: $message");
    // send to loading screen

    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: CustomColors.black,
          body: const Center(
            child: CupertinoActivityIndicator(),
          ),
        ),
      ),
      (route) => false,
    );

    FirestoreUser alici = await FirestoreService().getUserData(
      message['aliciId'],
    );

    FirestoreUser gonderen = await FirestoreService().getUserData(
      message['gonderenId'],
    );

    Navigator.of(GlobalcontextService.navigatorKey.currentContext!).pushAndRemoveUntil(
      CupertinoPageRoute(
        builder: (context) => const HomePage(),
      ),
      (route) => false,
    );

    Navigator.push(
      GlobalcontextService.navigatorKey.currentContext!,
      CupertinoPageRoute(
        builder: (context) => ChatScreen(
          senderUser: alici,
          receiverUser: gonderen,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // if user did not login, go to login page
    if (FirebaseAuth.instance.currentUser == null) {
      storage.deleteAll();
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
          builder: (context) => const EnterNumberPage(),
        ),
        (route) => false,
      );
    }

    // check users token
    _firebaseMessaging.getToken().then((token) {
      debugPrint("token: $token");
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.phoneNumber.toString())
          .update({'token': token});
    });

    _configureFirebaseMessaging();

    final user = FirebaseAuth.instance.currentUser;

    debugPrint("user uid: ${user!.uid}");

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    final user = FirebaseAuth.instance.currentUser;
    if (state == AppLifecycleState.resumed) {
      debugPrint("The user is online");
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.phoneNumber.toString())
          .update({'status': 'Online'});
    } else {
      debugPrint("The user is offline");
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.phoneNumber.toString())
          .update({
        'status': 'Offline',
        'lastSeen': DateTime.now().toUtc(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      backgroundColor: CustomColors.black,
      tabBar: CupertinoTabBar(
        onTap: (index) {
          if (index == 0) {
            setState(() {});
          }
        },
        backgroundColor: CustomColors.black,
        items: const [
          BottomNavigationBarItem(
            activeIcon: Icon(CupertinoIcons.chat_bubble_2_fill),
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(CupertinoIcons.group_solid),
            icon: Icon(CupertinoIcons.group),
            label: 'People',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(CupertinoIcons.settings_solid),
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          )
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const ChatsPage();
          case 1:
            return const PeopleScreen();

          case 2:
            return const SettingsPage();
          default:
            return const Center(
              child: Text('Chats'),
            );
        }
      },
    );
  }
}
