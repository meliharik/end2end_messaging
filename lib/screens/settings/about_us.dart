import 'package:end2end_messaging/helpers/space.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsPage extends ConsumerStatefulWidget {
  const AboutUsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends ConsumerState<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.black,
      navigationBar: navBar(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
          ),
          SpaceHelper.height(context, 0.05),
          Text(
            'We are Securely.',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: MediaQuery.of(context).size.width * 0.07,
            ),
          ),
          Text(
            'We are protecting the world!',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: MediaQuery.of(context).size.width * 0.06,
            ),
          ),
          SpaceHelper.height(context, 0.05),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.03,
            ),
            child: Text(
              "We developed this application as a graduation project for Bursa Uludag University department of Computer Engineering. We hope you liked it.",
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SpaceHelper.height(context, 0.03),
          Row(
            children: [
              SpaceHelper.width(context, 0.03),
              Text(
                'Developers',
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.055,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SpaceHelper.height(context, 0.02),
          person(context, 'Melih Arık', 'assets/images/melih.JPG'),
          SpaceHelper.height(context, 0.02),
          person(context, 'Kürşat Memiş', 'assets/images/kursat.jpg'),
        ],
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
        'About Us',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Row person(BuildContext context, String name, String image) {
    return Row(
      children: [
        SpaceHelper.width(context, 0.03),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.03,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SpaceHelper.width(context, 0.03),
      ],
    );
  }
}
