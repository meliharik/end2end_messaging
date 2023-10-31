import 'package:end2end_messaging/helpers/space.dart';
import 'package:end2end_messaging/models/user.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatDetailsPage extends ConsumerStatefulWidget {
  final FirestoreUser user;
  const ChatDetailsPage({super.key, required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChatDetailsPageState();
}

class _ChatDetailsPageState extends ConsumerState<ChatDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.black,
      navigationBar: navBar(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SpaceHelper.height(context, 0.03),
            Container(width: MediaQuery.of(context).size.width),
            profilePhoto(context),
            SpaceHelper.height(context, 0.03),
            name(context),
            // SpaceHelper.boslukHeight(context, 0.01),
            phoneNumber(context),
            SpaceHelper.height(context, 0.03),
            aboutText(context),
            SpaceHelper.height(context, 0.002),
            about(context),
            SpaceHelper.height(context, 0.03),
            publicKeyText(context),
            SpaceHelper.height(context, 0.002),
            publicKey(context),
            SpaceHelper.height(context, 0.03),
            privateKeyText(context),
            SpaceHelper.height(context, 0.002),
            privateKeyMeme(context),
            SpaceHelper.height(context, 0.2),
          ],
        ),
      ),
    );
  }

  Row aboutText(BuildContext context) {
    return Row(
      children: [
        SpaceHelper.width(context, 0.06),
        Text(
          'ABOUT',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: MediaQuery.of(context).size.width * 0.035,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Padding privateKeyMeme(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * 0.04,
            MediaQuery.of(context).size.width * 0.02,
            MediaQuery.of(context).size.width * 0.04,
            MediaQuery.of(context).size.width * 0.02,
          ),
          child: Text(
            'Hey come on, you can\'t see this. You can only see your own private key.',
            textAlign: TextAlign.start,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: MediaQuery.of(context).size.width * 0.04,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Row privateKeyText(BuildContext context) {
    return Row(
      children: [
        SpaceHelper.width(context, 0.06),
        Text(
          'PRIVATE KEY',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: MediaQuery.of(context).size.width * 0.035,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Padding publicKey(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * 0.04,
            MediaQuery.of(context).size.width * 0.02,
            MediaQuery.of(context).size.width * 0.04,
            MediaQuery.of(context).size.width * 0.02,
          ),
          child: Text(
            widget.user.publicKey,
            textAlign: TextAlign.start,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: MediaQuery.of(context).size.width * 0.04,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Row publicKeyText(BuildContext context) {
    return Row(
      children: [
        SpaceHelper.width(context, 0.06),
        Text(
          'PUBLIC KEY',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: MediaQuery.of(context).size.width * 0.035,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }

  Row about(BuildContext context) {
    return Row(
      children: [
        SpaceHelper.width(context, 0.02),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: CustomColors.grey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.04,
                MediaQuery.of(context).size.width * 0.02,
                MediaQuery.of(context).size.width * 0.04,
                MediaQuery.of(context).size.width * 0.02,
              ),
              child: Text(
                widget.user.description,
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SpaceHelper.width(context, 0.02),
      ],
    );
  }

  Text phoneNumber(BuildContext context) {
    return Text(
      '${widget.user.phoneNumber.substring(0, 3)} ${widget.user.phoneNumber.substring(3, 6)} ${widget.user.phoneNumber.substring(6, 9)} ${widget.user.phoneNumber.substring(9, 11)} ${widget.user.phoneNumber.substring(11, 13)}',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.5),
        fontWeight: FontWeight.w400,
        fontSize: MediaQuery.of(context).size.width * 0.045,
      ),
    );
  }

  Text name(BuildContext context) {
    return Text(
      widget.user.displayName,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontSize: MediaQuery.of(context).size.width * 0.06,
      ),
    );
  }

  GestureDetector profilePhoto(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.black,
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    CupertinoIcons.back,
                    size: 30,
                    color: CustomColors.primaryColor,
                  ),
                ),
              ),
              backgroundColor: Colors.black,
              body: Center(
                child: Hero(
                  tag: widget.user.photoURL,
                  child: InteractiveViewer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.user.photoURL,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.network(
          widget.user.photoURL,
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.width * 0.3,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  CupertinoNavigationBar navBar() {
    return CupertinoNavigationBar(
      backgroundColor: CustomColors.black,
      border: Border(
        bottom: BorderSide(
          color: CustomColors.grey,
          width: 0.0,
        ),
      ),
      middle: Text(
        'Contact Info',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
