// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:end2end_messaging/helpers/space.dart';
import 'package:end2end_messaging/models/user.dart';
import 'package:end2end_messaging/screens/chat_screen.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  TextEditingController searchTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustomColors.black,
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            border: Border(
              bottom: BorderSide(
                color: CustomColors.grey,
                width: 0.0,
              ),
            ),
            backgroundColor: CustomColors.black,
            largeTitle: Text(
              "People",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .orderBy("createdAt")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    "Error: ${snapshot.error}",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: CupertinoActivityIndicator(),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  QuerySnapshot data = snapshot.data as QuerySnapshot;
                  List<FirestoreUser> users = [];

                  for (var user in data.docs) {
                    users.add(FirestoreUser.fromFirestore(user));
                  }

                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Lottie.asset(
                            "assets/lottie/empty2.json",
                            width: MediaQuery.of(context).size.width / 2,
                          ),
                          Text(
                            'No user yet',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: MediaQuery.of(context).size.width / 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SpaceHelper.height(context, 0.02),
                          Text(
                            'You can invite your friends to use this app',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: MediaQuery.of(context).size.width / 25,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    FirestoreUser? currentUserData;

                    for (var user in users) {
                      if (user.phoneNumber ==
                          FirebaseAuth.instance.currentUser!.phoneNumber) {
                        currentUserData = user;
                        debugPrint(
                            "currentUser: ${currentUserData.displayName}");
                        users.remove(user);
                        break;
                      }
                    }

                    return Column(
                      children: [
                        SpaceHelper.height(context, 0.02),
                        Material(
                          color: Colors.transparent,
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                            child: ListTile(
                              onTap: () {
                                ref.read(isLoadingProvider.notifier).state =
                                    false;
                                // show dialog and show user's infos
                                showCupertinoDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      content: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                    currentUserData!.photoURL,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              currentUserData.displayName
                                                  .toString(),
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              currentUserData.description,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              currentUserData.phoneNumber,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
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
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  currentUserData!.photoURL,
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width / 7,
                                  height: MediaQuery.of(context).size.width / 7,
                                  loadingBuilder: (context, child, progress) {
                                    return progress == null
                                        ? child
                                        : Shimmer.fromColors(
                                            baseColor: Colors.grey.shade700,
                                            highlightColor:
                                                Colors.grey.shade500,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  7,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  7,
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      color: Colors.black,
                                    );
                                  },
                                ),
                              ),
                              title: Text(
                                "${currentUserData.displayName} (You)",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 22,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              subtitle: Text(
                                currentUserData.description,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 33,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              trailing: Text(
                                currentUserData.status,
                                style: GoogleFonts.poppins(
                                  color: currentUserData.status == "Online"
                                      ? CustomColors.primaryColor
                                      : CustomColors.orange,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 35,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.white24,
                          endIndent: MediaQuery.of(context).size.width / 10,
                          indent: MediaQuery.of(context).size.width / 10,
                        ),
                        ListView.separated(
                          padding: const EdgeInsets.all(0.0),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: users.length,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) {
                            return Divider(
                              color: Colors.white24,
                              endIndent: MediaQuery.of(context).size.width / 10,
                              indent: MediaQuery.of(context).size.width / 10,
                            );
                          },
                          itemBuilder: (context, index) {
                            FirestoreUser user = users[index];
                            return Material(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 0.0, 8.0, 0.0),
                                child: ListTile(
                                  onTap: () {
                                    ref.read(isLoadingProvider.notifier).state =
                                        false;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          senderUser: currentUserData!,
                                          receiverUser: user,
                                        ),
                                      ),
                                    );
                                  },
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      user.photoURL,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, progress) {
                                        return progress == null
                                            ? child
                                            : Shimmer.fromColors(
                                                baseColor: Colors.grey.shade700,
                                                highlightColor:
                                                    Colors.grey.shade500,
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      7,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      7,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                              );
                                      },
                                      width:
                                          MediaQuery.of(context).size.width / 7,
                                      height:
                                          MediaQuery.of(context).size.width / 7,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.person,
                                          color: Colors.black,
                                        );
                                      },
                                    ),
                                  ),
                                  title: Text(
                                    user.displayName,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              22,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  subtitle: Text(
                                    user.description,
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              33,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  trailing: Text(
                                    user.status,
                                    style: GoogleFonts.poppins(
                                      color: user.status == "Online"
                                          ? CustomColors.primaryColor
                                          : CustomColors.orange,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              35,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }
                }
                return const Center(
                  child: CupertinoActivityIndicator(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
