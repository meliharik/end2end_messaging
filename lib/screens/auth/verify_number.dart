// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:end2end_messaging/helpers/dialog.dart';
import 'package:end2end_messaging/home.dart';
import 'package:end2end_messaging/screens/auth/create_profile.dart';
import 'package:end2end_messaging/services/firestore_service.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class VerifyNumberPage extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const VerifyNumberPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VerifyNumberPageState();
}

class _VerifyNumberPageState extends ConsumerState<VerifyNumberPage> {
  //rsa variables
  var key, pub_key, pri_key;
  var message;

  final storage = const FlutterSecureStorage();

  bool isLoading = false;

  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomColors.black,
      child: Stack(
        children: [
          CupertinoPageScaffold(
            navigationBar: navBar(),
            backgroundColor: CustomColors.black,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verify your phone number',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Enter the 6-digit code sent to ${widget.phoneNumber}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  pinField()
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Platform.isIOS
                    ? const CupertinoActivityIndicator()
                    : CircularProgressIndicator(
                        color: CustomColors.primaryColor,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Directionality pinField() {
    return Directionality(
      // Specify direction if desired
      textDirection: TextDirection.ltr,
      child: Material(
        color: Colors.transparent,
        child: Theme(
          // make it dark
          data: ThemeData.dark(),
          child: Pinput(
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            // keyboard theme

            autofocus: true,
            closeKeyboardWhenCompleted: true,
            preFilledWidget: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 56,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            onCompleted: (value) {
              debugPrint('onCompleted: $value');
              debugPrint("widget.verificationId: ${widget.verificationId}");

              setState(() {
                isLoading = true;
              });
              sendCodeToFirebase(code: controller.text);
              // }
            },
            defaultPinTheme: PinTheme(
              width: 60,
              height: 60,
              textStyle: GoogleFonts.poppins(
                fontSize: 22,
                color: Colors.white,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(19),
                border: Border.all(
                  color: CustomColors.black,
                ),
              ),
            ),
            controller: controller,
            androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
            pinAnimationType: PinAnimationType.slide,
            listenForMultipleSmsOnAndroid: true,
            length: 6,
            isCursorAnimationEnabled: true,
            showCursor: true,
            senderPhoneNumber: widget.phoneNumber.replaceAll(' ', ''),
            cursor: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 56,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  CupertinoNavigationBar navBar() {
    return CupertinoNavigationBar(
      backgroundColor: CustomColors.black,
      border: Border.all(
        color: CustomColors.black,
        width: 0,
      ),
      middle: Text(
        'Securely',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future sendCodeToFirebase({String? code}) async {
    var credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId, smsCode: code!);

    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((value) async {
          // search users collection for the user
          var user = await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.phoneNumber.replaceAll(' ', ''))
              .get();
          if (!user.exists) {
            ////////////////////////////////////////////////////
            ////////////////////generating key//////////////////
            ////////////////////////////////////////////////////

            key = await RSA.generate(2048);
            setState(() {
              pub_key = key.publicKey;
              pri_key = key.privateKey;
            });

            ////////////////////////////////////////////////////
            // in shared preference
            // Write value
            await storage.write(key: "pri_key", value: pri_key);

            String phoneNumber = widget.phoneNumber.replaceAll(' ', '');

            await storage.write(
              key: "number",
              value: phoneNumber,
            );

            // FirestoreService().createUser(
            //   id: phoneNumber,
            //   displayName: 'Unknown',
            //   description: 'Hey! I am safe with Securely.',
            //   photoUrl:
            //       "https://api.dicebear.com/7.x/bottts-neutral/png?seed=$phoneNumber",
            //   publicKey: pub_key.toString(),
            //   status: 'Online',
            //   token: value.toString(),
            //   phoneNumber: phoneNumber,
            // );

            await FirebaseMessaging.instance
                .getToken()
                .whenComplete(() {})
                .then(
                  (value) => FirestoreService().createUser(
                    id: phoneNumber,
                    displayName: 'Unknown',
                    description: 'Hey! I am safe with Securely.',
                    photoUrl:
                        "https://api.dicebear.com/7.x/bottts-neutral/png?seed=$phoneNumber",
                    publicKey: pub_key.toString(),
                    status: 'Online',
                    token: value.toString(),
                    phoneNumber: phoneNumber,
                  ),
                );

            setState(() {
              isLoading = false;
            });

            User? user = FirebaseAuth.instance.currentUser;

            user!.updateDisplayName('Unknown');
            user.updatePhotoURL(
                "https://api.dicebear.com/7.x/bottts-neutral/png?seed=$phoneNumber");

            // storage.write(key: "name", value: "Unknown");
            // storage.write(
            //   key: "photoURL",
            //   value:
            //       "https://api.dicebear.com/7.x/bottts-neutral/png?seed=$phoneNumber",
            // );

            debugPrint(user.photoURL.toString());
            debugPrint(user.displayName.toString());

            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(
                builder: (context) => const CreateProfilePage(),
              ),
              (route) => false,
            );
          } else {
            String phoneNumber = widget.phoneNumber.replaceAll(' ', '');

            // writing phone number in shared preferences
            await storage.write(key: "number", value: phoneNumber);

            setState(() {
              isLoading = false;
            });

            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          }
        })
        .whenComplete(() {})
        .onError((error, stackTrace) {
          debugPrint("hata: $error");
          setState(() {
            isLoading = false;
          });
          if (error.toString().contains("invalid-verification-code")) {
            DialogHelper().cupertinoDialog(
              title: 'Error',
              subtitle: 'Invalid verification code.',
            );
          } else {
            DialogHelper().cupertinoDialog(
              title: 'Error',
              subtitle: error.toString(),
            );
          }
        });
  }
}
