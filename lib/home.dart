import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:end2end_messaging/screens/chats.dart';
import 'package:end2end_messaging/screens/people_screen.dart';
import 'package:end2end_messaging/screens/settings.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
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
    // return cupertino tabbar with bottomnavigationbar and appbar
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
          // BottomNavigationBarItem(
          //   activeIcon: Icon(CupertinoIcons.person_2_fill),
          //   icon: Icon(CupertinoIcons.person_2),
          //   label: 'Groups',
          // ),
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
          // case 1:
          //   return const Center(
          //     child: Text('Groups'),
          //   );
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
