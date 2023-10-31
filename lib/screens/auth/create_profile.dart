// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:end2end_messaging/helpers/dialog.dart';
import 'package:end2end_messaging/home.dart';
import 'package:end2end_messaging/services/firestore_service.dart';
import 'package:end2end_messaging/services/storage_service.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CreateProfilePage extends ConsumerStatefulWidget {
  const CreateProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<CreateProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  bool isLoading = false;
  bool isNameTapped = false;
  bool isStatusTapped = false;

  File? selectedPhoto;

  final storage = const FlutterSecureStorage();

  List<String> securelyMessages = [
    "Hey there! Securely is my secret agent for messaging.",
    "Hello! Securely guards my messages like a fortress.",
    "Hey! With Securely, my messages are CIA-level safe.",
    "Hi there! I'm James Bonding my messages with Securely.",
    "Hey there! Securely is my superhero shield for messages.",
    "Hello! Securely stores my messages like a hidden treasure.",
    "Hey! Securely protects my messages against decryption experts.",
    "Hi! Securely stores my messages like they're ancient artifacts.",
    "Hello! Securely safeguards my messages like a mystery novel.",
    "Hi there! With Securely, I'm the champion of privacy."
  ];

  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomColors.black,
      child: Stack(
        children: [
          CupertinoPageScaffold(
            backgroundColor: CustomColors.black,
            navigationBar: navBar(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  photo(),
                  const SizedBox(
                    height: 40,
                  ),
                  nameField(context),
                  const SizedBox(
                    height: 20,
                  ),
                  statusField(context),
                  const SizedBox(
                    height: 10,
                  ),
                  // slidable cupertino chips for default status
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: ListView(
                      // horizontal scroll
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        // chip with icon
                        defaultStatus(context, 'Available'),
                        const SizedBox(
                          width: 10,
                        ),
                        // chip with icon
                        defaultStatus(context, 'Busy'),
                        const SizedBox(
                          width: 10,
                        ),
                        // chip with icon
                        defaultStatus(context, 'At school'),
                        const SizedBox(
                          width: 10,
                        ),
                        // chip with icon
                        defaultStatus(context, 'At the movies'),
                        const SizedBox(
                          width: 10,
                        ),
                        // chip with icon
                        defaultStatus(context, 'At the gym'),
                        const SizedBox(
                          width: 10,
                        ),

                        // chip with icon
                        defaultStatus(context, 'Making apps ;)'),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  saveBtn(),
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

  Padding saveBtn() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  DialogHelper().cupertinoDialog(
                    title: 'Error',
                    subtitle: 'Name cannot be empty.',
                  );
                  return;
                }
                save();
              },
              color: CustomColors.primaryColor,
              child: Text(
                'Save',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  CupertinoButton defaultStatus(BuildContext context, String status) {
    return CupertinoButton(
      onPressed: () {
        setState(() {
          statusController.text = status;
        });
      },
      padding: const EdgeInsets.all(0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CustomColors.black,
          border: Border.all(
            color: CustomColors.grey,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.circle_fill,
              color: CustomColors.primaryColor,
              size: 10,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              ' $status',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding statusField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CupertinoTextField(
        controller: statusController,
        onTap: () {
          setState(() {
            isStatusTapped = true;
            isNameTapped = false;
          });
        },
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
          setState(() {
            isStatusTapped = false;
            isNameTapped = false;
          });
        },
        cursorColor: CustomColors.primaryColor,
        padding: const EdgeInsets.all(15.0),
        placeholder: 'About',
        placeholderStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.w400,
          fontSize: MediaQuery.of(context).size.width * 0.04,
        ),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: MediaQuery.of(context).size.width * 0.04,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CustomColors.black,
          border: Border.all(
            color:
                isStatusTapped ? CustomColors.primaryColor : CustomColors.grey,
            width: 1,
          ),
        ),
      ),
    );
  }

  Padding nameField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CupertinoTextField(
        controller: nameController,
        onTap: () {
          setState(() {
            isNameTapped = true;
            isStatusTapped = false;
          });
        },
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
          setState(() {
            isNameTapped = false;
            isStatusTapped = false;
          });
        },
        cursorColor: CustomColors.primaryColor,
        padding: const EdgeInsets.all(15.0),
        placeholder: 'Name',
        placeholderStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.5),
          fontWeight: FontWeight.w400,
          fontSize: MediaQuery.of(context).size.width * 0.04,
        ),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: MediaQuery.of(context).size.width * 0.04,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CustomColors.black,
          border: Border.all(
            color: isNameTapped ? CustomColors.primaryColor : CustomColors.grey,
            width: 1,
          ),
        ),
      ),
    );
  }

  Material photo() {
    return Material(
      color: Colors.transparent,
      child: profilePhoto,
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
        'Create Profile',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget get profilePhoto => Center(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: CustomColors.orange,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: InkWell(
                  onTap: pickFromGallery,
                  child: CircleAvatar(
                    backgroundColor: CustomColors.grey,
                    backgroundImage: getPhoto(),
                    radius: 50.0,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: pickFromGallery,
                child: CircleAvatar(
                  backgroundColor: CustomColors.grey.withOpacity(0.8),
                  radius: 20.0,
                  child: const Icon(
                    CupertinoIcons.camera,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  getPhoto() {
    // if (selectedPhoto == null) {
    //   String url = storage.read(key: 'photoURL').toString();
    //   return NetworkImage(url);
    // } else {
    //   return FileImage(selectedPhoto!);
    // }

    if (selectedPhoto == null) {
      User? user = FirebaseAuth.instance.currentUser;

      String? phoneNumber = user!.phoneNumber;
      debugPrint("phone number: $phoneNumber");

      return NetworkImage(
          "https://api.dicebear.com/7.x/bottts-neutral/png?seed=$phoneNumber");
    } else {
      return FileImage(selectedPhoto!);
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
    });
  }

  save() async {
    try {
      setState(() {
        isLoading = true;
      });
      User? user = FirebaseAuth.instance.currentUser;

      String? profilePhotoUrl;
      if (selectedPhoto != null) {
        profilePhotoUrl =
            await StorageService().uploadProfilePhoto(selectedPhoto!);
      } else {
        profilePhotoUrl =
            "https://api.dicebear.com/7.x/bottts-neutral/png?seed=${user!.phoneNumber}";
      }

      // update firestore user
      await FirestoreService().updateUser(
        name: nameController.text,
        status: statusController.text.isEmpty
            ? securelyMessages[now.second % securelyMessages.length]
            : statusController.text,
        profileUrl: profilePhotoUrl,
        phoneNumber: user!.phoneNumber!,
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
}
