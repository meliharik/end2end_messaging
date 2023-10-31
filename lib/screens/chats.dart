// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:end2end_messaging/helpers/dialog.dart';
import 'package:end2end_messaging/helpers/space.dart';
import 'package:end2end_messaging/models/message.dart';
import 'package:end2end_messaging/models/user.dart';
import 'package:end2end_messaging/screens/auth/enter_number.dart';
import 'package:end2end_messaging/screens/chat_screen.dart';
import 'package:end2end_messaging/services/firestore_service.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatsPage extends ConsumerStatefulWidget {
  const ChatsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatsPageState();
}

class _ChatsPageState extends ConsumerState<ChatsPage> {
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: callAsyncFetch(),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          var number = snapshot.data;

          return CupertinoPageScaffold(
            backgroundColor: CustomColors.black,
            child: CustomScrollView(
              slivers: [
                CupertinoSliverNavigationBar(
                  // bottom border grey
                  border: Border(
                    bottom: BorderSide(
                      color: CustomColors.grey,
                      width: 0.0,
                    ),
                  ),
                  backgroundColor: CustomColors.black,
                  largeTitle: Text(
                    "Chats",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: StreamBuilder(
                    stream: FirestoreService().getChats(number),
                    builder: (context, AsyncSnapshot snapshot) {
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
                        final data = snapshot.requireData;

                        List<String> userIds = [];

                        for (var i = 0; i < data.size; i++) {
                          userIds.add(data.docs[i].id);
                        }

                        if (data.size == 0) {
                          return Center(
                            child: Column(
                              children: [
                                Lottie.asset(
                                  "assets/lottie/empty2.json",
                                  width: MediaQuery.of(context).size.width / 2,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await storage.deleteAll();
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.clear();

                                    await FirebaseAuth.instance.signOut();
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            const EnterNumberPage(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: Text(
                                    'No chats yet',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SpaceHelper.height(context, 0.02),
                                Text(
                                  'Start a new chat in People section',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize:
                                        MediaQuery.of(context).size.width / 25,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        debugPrint(userIds.toString());

                        return ListView.separated(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: userIds.length,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) {
                            return Divider(
                              color: CustomColors.grey,
                              endIndent: MediaQuery.of(context).size.width / 2,
                              indent: MediaQuery.of(context).size.width / 2,
                            );
                          },
                          itemBuilder: ((context, index) {
                            return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .snapshots(),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (snapshot.hasData) {
                                  List<FirestoreUser> users = [];
                                  for (var i = 0; i < snapshot.data.size; i++) {
                                    users.add(
                                      FirestoreUser.fromFirestore(
                                        snapshot.data.docs[i],
                                      ),
                                    );
                                  }
                                  FirestoreUser user = users.firstWhere(
                                      (element) =>
                                          element.phoneNumber ==
                                          userIds[index]);
                                  return StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('chats')
                                        .doc(number)
                                        .collection('messageTo')
                                        .doc(user.phoneNumber)
                                        .collection('messages')
                                        .snapshots(),
                                    builder: (context, AsyncSnapshot snapshot) {
                                      if (snapshot.hasData) {
                                        int unreadMessages = 0;
                                        List<Message> messages = [];
                                        for (var i = 0;
                                            i < snapshot.data.size;
                                            i++) {
                                          messages.add(
                                            Message.fromFirestore(
                                              snapshot.data.docs[i],
                                            ),
                                          );
                                        }

                                        for (var i = 0;
                                            i < messages.length;
                                            i++) {
                                          if (messages[i].isRead == false) {
                                            unreadMessages++;
                                          }
                                        }
                                        return Material(
                                          color: CustomColors.black,
                                          child: ListTile(
                                            onTap: () {
                                              ref
                                                  .read(isLoadingProvider
                                                      .notifier)
                                                  .state = false;
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      ChatScreen(
                                                    receiverUser: user,
                                                    senderUser: users
                                                        .firstWhere((element) =>
                                                            element
                                                                .phoneNumber ==
                                                            number),
                                                  ),
                                                ),
                                              );
                                            },
                                            leading: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                user.photoURL,
                                                fit: BoxFit.cover,
                                                loadingBuilder:
                                                    (context, child, progress) {
                                                  return progress == null
                                                      ? child
                                                      : Shimmer.fromColors(
                                                          baseColor: Colors
                                                              .grey.shade700,
                                                          highlightColor: Colors
                                                              .grey.shade500,
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                7,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                7,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.grey,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                        );
                                                },
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    7,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    7,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
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
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    22,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            subtitle: Text(
                                              getSubtitle(data.docs[index]
                                                  ['lastMessage']),
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    33,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            trailing: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                if (unreadMessages != 0)
                                                  Badge(
                                                    backgroundColor:
                                                        CustomColors
                                                            .primaryColor,
                                                    label: Text(
                                                      unreadMessages.toString(),
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: Colors.white,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            40,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                Text(
                                                  timeago.format(
                                                    data.docs[index]
                                                            ['createdAt']
                                                        .toDate(),
                                                  ),
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.grey,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            33,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Text(
                                    "Error: ${snapshot.error}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            );
                          }),
                        );
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
        } else {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
      },
    );
  }

  callAsyncFetch() async {
    const storage = FlutterSecureStorage();
    var number = await storage.read(key: "number");
    var x = await storage.read(key: "pri_key");
    if (x == "empty") {
      DialogHelper().cupertinoDialog(
        title: 'Error',
        subtitle: 'Please generate a key pair.',
      );
    }
    return number;
  }

  String getSubtitle(doc) {
    if (doc.length > 250) {
      return 'Image';
    } else if (doc.length > 22) {
      return doc.substring(0, 22) + "...";
    } else {
      return doc;
    }
  }
}
