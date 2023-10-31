// ignore_for_file: use_build_context_synchronously

import 'package:end2end_messaging/helpers/space.dart';
import 'package:end2end_messaging/models/user.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyScreen extends ConsumerStatefulWidget {
  final FirestoreUser user;
  const PrivacyScreen({super.key, required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<PrivacyScreen> {
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.black,
      navigationBar: navBar(),
      child: Column(
        children: [
          publicKeyTile(context),
          SpaceHelper.height(context, 0.02),
          privateKeyTile(context),
        ],
      ),
    );
  }

  Padding privateKeyTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: () async {
              var privateKey = await storage.read(key: "pri_key");
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text(
                      'Your private key',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Text(
                        privateKey!,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Close',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            title: Text(
              'View your private key',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              'Do not share this key with anyone!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding publicKeyTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: () async {
              showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text(
                      'Your public key',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    content: SingleChildScrollView(
                      child: Text(
                        widget.user.publicKey,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Close',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            title: Text(
              'View your public key',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  CupertinoNavigationBar navBar() {
    return CupertinoNavigationBar(
      previousPageTitle: 'Settings',
      backgroundColor: CustomColors.black,
      border: Border(
        bottom: BorderSide(
          color: CustomColors.grey,
          width: 0.0,
        ),
      ),
      middle: Text(
        'Privacy',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
