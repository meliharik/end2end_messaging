// ignore_for_file: use_build_context_synchronously

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:end2end_messaging/home.dart';
import 'package:end2end_messaging/screens/auth/enter_number.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Yonlendirme extends ConsumerStatefulWidget {
  const Yonlendirme({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _YonlendirmeState();
}

class _YonlendirmeState extends ConsumerState<Yonlendirme> {
  bool connectedToInternet = false;

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    networkControl();

    getNavigation();
  }

  didDeleted() async {
    User? user = FirebaseAuth.instance.currentUser;

    await user?.reload();

    if (user == null) {
      storage.deleteAll();
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => const EnterNumberPage()),
        (Route<dynamic> route) => false,
      );
    } else {

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.black,
      body: const Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  getNavigation() async {
    User? user = FirebaseAuth.instance.currentUser;

    await user?.reload();

    if (user == null) {
      storage.deleteAll();

      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => const EnterNumberPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future networkControl() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    debugPrint(connectivityResult.toString());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        connectedToInternet = false;
      });
    } else if (connectivityResult != ConnectivityResult.none) {
      connectedToInternet = true;
    }
  }
}
