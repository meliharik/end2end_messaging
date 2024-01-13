import 'dart:io';

import 'package:end2end_messaging/main.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogHelper {
  Future<dynamic> cupertinoDialog({
    required String title,
    required String subtitle,
  }) {
    return showCupertinoDialog(
      context: GlobalcontextService.navigatorKey.currentContext!,
      builder: (context) {
        if (Platform.isIOS) {
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
        } else {
          return AlertDialog(
            backgroundColor: CustomColors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            content: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              )
            ],
          );
        }
      },
    );
  }
}
