import 'package:end2end_messaging/screens/auth/onboarding.dart';
import 'package:end2end_messaging/services/notification_service.dart';
import 'package:end2end_messaging/yonlendirme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

int? initScreen; // for onboarding

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  NotificationService().initNotificationService();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  //disable landscape mode
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = prefs.getInt("initScreen");
  await prefs.setInt("initScreen", 1);
  debugPrint('initScreen $initScreen');

  runApp(const ProviderScope(child: MyApp()));
}

class GlobalcontextService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      navigatorKey: GlobalcontextService.navigatorKey,
      debugShowCheckedModeBanner: false,
      // dark theme
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Color(0xff1c1c1c),
      ),
      localizationsDelegates: const [DefaultMaterialLocalizations.delegate],
      title: 'Securely',
      home: initScreen == 0 || initScreen == null
          ? const OnboardingScreen()
          : const Yonlendirme(),
      // home: const Yonlendirme(),
    );
  }
}
