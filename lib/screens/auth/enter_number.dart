import 'package:end2end_messaging/helpers/dialog.dart';
import 'package:end2end_messaging/screens/auth/verify_number.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class EnterNumberPage extends ConsumerStatefulWidget {
  const EnterNumberPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EnterNumberPageState();
}

class _EnterNumberPageState extends ConsumerState<EnterNumberPage> {
  TextEditingController controller = TextEditingController();
  bool isTextFieldTapped = false;
  String verificationId = '';

  bool isLoading = false;

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
                    'Enter your phone number',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'We will send you a verification code',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // add +90 to the beginning of the number
                  numberField(context),
                  const SizedBox(height: 20),
                  nextBtn(),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Row nextBtn() {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            onPressed: () {
              if (controller.text.isEmpty) {
                DialogHelper().cupertinoDialog(
                  title: 'Error',
                  subtitle: 'Please enter your phone number.',
                );
                return;
              }
              if (controller.text.length != 12) {
                DialogHelper().cupertinoDialog(
                  title: 'Error',
                  subtitle: 'Please enter a valid phone number.',
                );
                return;
              }
              verifyPhoneNumber();
            },
            color: CustomColors.primaryColor,
            child: Text(
              'Next',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  CupertinoTextField numberField(BuildContext context) {
    return CupertinoTextField(
      onTap: () {
        setState(() {
          isTextFieldTapped = true;
        });
      },
      onTapOutside: (_) {
        setState(() {
          isTextFieldTapped = false;
        });
        FocusScope.of(context).unfocus();
      },
      cursorColor: CustomColors.primaryColor,
      controller: controller,
      padding: const EdgeInsets.all(15.0),
      placeholder: 'Phone number',
      placeholderStyle: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.5),
        fontWeight: FontWeight.w400,
        fontSize: MediaQuery.of(context).size.width * 0.038,
      ),
      prefix: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Text(
          '+90',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: MediaQuery.of(context).size.width * 0.04,
          ),
        ),
      ),
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w400,
        fontSize: MediaQuery.of(context).size.width * 0.04,
      ),
      inputFormatters: [
        PhoneInputFormatter(
          defaultCountryCode: 'TR',
        ),
      ],
      decoration: BoxDecoration(
        color: CustomColors.black,
        border: Border.all(
          color:
              isTextFieldTapped ? CustomColors.primaryColor : CustomColors.grey,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      prefixMode: OverlayVisibilityMode.always,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
    );
  }

  CupertinoNavigationBar navBar() {
    return CupertinoNavigationBar(
      automaticallyImplyLeading: false,
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

  Future verifyPhoneNumber() async {
    try {
      setState(() {
        isLoading = true;
      });
      FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+90${controller.text.replaceAll(' ', '')}',
        verificationCompleted: (phonesAuthCredentials) async {
          debugPrint(phonesAuthCredentials.toString());
          setState(() {
            isLoading = false;
          });
        },
        verificationFailed: (verificationFailed) async {
          debugPrint(verificationFailed.message.toString());
          setState(() {
            isLoading = false;
          });
          DialogHelper().cupertinoDialog(
            title: 'Error',
            subtitle: verificationFailed.message.toString(),
          );
        },
        codeSent: (verificationId, resendingToken) async {
          debugPrint(verificationId);
          setState(() {
            isLoading = false;
            this.verificationId = verificationId;
          });
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => VerifyNumberPage(
                verificationId: verificationId,
                phoneNumber: '+90 ${controller.text}',
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) async {
          debugPrint(verificationId);
          setState(() {
            isLoading = false;
          });
          DialogHelper().cupertinoDialog(
            title: 'Error',
            subtitle: 'Code auto retrieval timeout.',
          );
        },
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("hata: $e");
      DialogHelper().cupertinoDialog(
        title: 'Error',
        subtitle: e.toString(),
      );
    }
  }
}
