// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:end2end_messaging/helpers/dialog.dart';
import 'package:end2end_messaging/helpers/space.dart';
import 'package:end2end_messaging/home.dart';
import 'package:end2end_messaging/models/user.dart';
import 'package:end2end_messaging/services/firestore_service.dart';
import 'package:end2end_messaging/services/storage_service.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final FirestoreUser user;
  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  File? selectedPhoto;

  bool showAppBarActions = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user.displayName;
    statusController.text = widget.user.description;
    phoneNumberController.text =
        '${widget.user.phoneNumber.substring(0, 3)} ${widget.user.phoneNumber.substring(3, 6)} ${widget.user.phoneNumber.substring(6, 9)} ${'${widget.user.phoneNumber.substring(9, 11)} ${widget.user.phoneNumber.substring(11, 13)}'}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomColors.black,
      child: Stack(
        children: [
          CupertinoPageScaffold(
            backgroundColor: CustomColors.black,
            navigationBar: CupertinoNavigationBar(
              previousPageTitle: 'Settings',
              backgroundColor: CustomColors.black,
              border: Border(
                bottom: BorderSide(
                  color: CustomColors.grey,
                  width: 0.0,
                ),
              ),
              middle: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: GestureDetector(
                onTap: () {
                  if (nameController.text.isEmpty) {
                    DialogHelper().cupertinoDialog(
                      title: 'Error',
                      subtitle: 'Name cannot be empty',
                    );
                    return;
                  }
                  if (statusController.text.isEmpty) {
                    DialogHelper().cupertinoDialog(
                      title: 'Error',
                      subtitle: 'Status cannot be empty',
                    );
                    return;
                  }
                  save();
                },
                child: Text(
                  'Save',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: showAppBarActions
                        ? Colors.blue
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SpaceHelper.boslukHeight(context, 0.015),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: CustomColors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        children: [
                          SpaceHelper.boslukHeight(context, 0.015),
                          Row(
                            children: [
                              SpaceHelper.boslukWidth(context, 0.02),
                              profilePhoto,
                              SpaceHelper.boslukWidth(context, 0.02),
                              Expanded(
                                child: Text(
                                  'Enter your name and add an optional profile picture.',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.035,
                                    color: Colors.white38,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SpaceHelper.boslukHeight(context, 0.03),
                          Divider(
                            color: CustomColors.grey,
                            height: 0.0,
                            thickness: 0.5,
                          ),
                          // SpaceHelper.boslukHeight(context, 0.015),
                          // customTextField
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.02,
                            ),
                            child: CupertinoTextField(
                              controller: nameController,
                              onTapOutside: (_) {
                                FocusScope.of(context).unfocus();
                              },
                              onChanged: (value) {
                                setState(() {
                                  showAppBarActions = true;
                                });
                              },
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.02,
                                vertical:
                                    MediaQuery.of(context).size.width * 0.03,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              placeholder: 'Name',
                              placeholderStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                color: Colors.white38,
                              ),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.04,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SpaceHelper.boslukHeight(context, 0.02),
                  Row(
                    children: [
                      SpaceHelper.boslukWidth(context, 0.06),
                      Text(
                        'ABOUT',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                  SpaceHelper.boslukHeight(context, 0.002),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomColors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: CupertinoTextField(
                        maxLines: 3,
                        controller: statusController,
                        onTapOutside: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        onChanged: (value) {
                          setState(() {
                            showAppBarActions = true;
                          });
                        },
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04,
                          vertical: MediaQuery.of(context).size.width * 0.03,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        placeholder: 'Status',
                        placeholderStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: Colors.white38,
                        ),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SpaceHelper.boslukHeight(context, 0.02),
                  Row(
                    children: [
                      SpaceHelper.boslukWidth(context, 0.06),
                      Text(
                        'PHONE NUMBER',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                  SpaceHelper.boslukHeight(context, 0.002),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.02,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CustomColors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: CupertinoTextField(
                        controller: phoneNumberController,
                        readOnly: true,
                        onTapOutside: (_) {
                          FocusScope.of(context).unfocus();
                        },
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04,
                          vertical: MediaQuery.of(context).size.width * 0.03,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        placeholder: 'Phone Number',
                        placeholderStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: Colors.white38,
                        ),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SpaceHelper.boslukHeight(context, 0.2),
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

  @override
  void dispose() {
    nameController.dispose();
    statusController.dispose();
    phoneNumberController.dispose();
    selectedPhoto = null;
    super.dispose();
  }

  Widget get profilePhoto => GestureDetector(
        onTap: () {
          pickFromGallery();
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: getPhoto(),
            ),
            Positioned(
              bottom: 0.0,
              right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: CustomColors.grey.withOpacity(1),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.width * 0.01,
                      ),
                      child: Icon(
                        CupertinoIcons.camera,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  save() async {
    try {
      setState(() {
        isLoading = true;
      });

      String? profilePhotoUrl;
      if (selectedPhoto != null) {
        profilePhotoUrl =
            await StorageService().uploadProfilePhoto(selectedPhoto!);
      } else {
        profilePhotoUrl = widget.user.photoURL;
      }

      await FirestoreService().updateUser(
        name: nameController.text,
        status: statusController.text,
        profileUrl: profilePhotoUrl,
        phoneNumber: widget.user.phoneNumber,
      );

      setState(() {
        isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint("Error: $e");

      DialogHelper().cupertinoDialog(
        title: 'Error',
        subtitle: 'Something went wrong. Please try again. $e',
      );
    }
  }

  getPhoto() {
    if (selectedPhoto == null) {
      return Image.network(
        widget.user.photoURL,
        width: MediaQuery.of(context).size.width * 0.22,
        height: MediaQuery.of(context).size.width * 0.22,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        selectedPhoto!,
        width: MediaQuery.of(context).size.width * 0.22,
        height: MediaQuery.of(context).size.width * 0.22,
        fit: BoxFit.cover,
      );
    }
  }

  pickFromGallery() async {
    var image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 100);
    setState(() {
      selectedPhoto = File(image!.path);
      showAppBarActions = true;
    });
  }
}
