import 'package:end2end_messaging/main.dart';
import 'package:flutter/cupertino.dart';

class DialogHelper {
  Future<dynamic> cupertinoDialog({
    required String title,
    required String subtitle,
  }) {
    return showCupertinoDialog(
      context: GlobalcontextService.navigatorKey.currentContext!,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(subtitle),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
