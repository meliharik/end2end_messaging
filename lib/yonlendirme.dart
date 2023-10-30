import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:end2end_messaging/home.dart';
import 'package:end2end_messaging/screens/auth/enter_number.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Yonlendirme extends ConsumerStatefulWidget {
  const Yonlendirme({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _YonlendirmeState();
}

class _YonlendirmeState extends ConsumerState<Yonlendirme> {
  bool connectedToInternet = false;

  @override
  void initState() {
    super.initState();
    networkControl();
  }

  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return getNavigation();
  }

  getNavigation() {
    // current firebase user

    // if (connectedToInternet == false) {
    // return const NoInternetPage();
    // } else {
    User? user = FirebaseAuth.instance.currentUser;
    // FirebaseAuth.instance.signOut();
    // storage.deleteAll();
    if (user == null) {
      storage.deleteAll();
      return const EnterNumberPage();
    } else {
      // return const HomeTestPage();
      return const HomePage();
    }
    // }
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
