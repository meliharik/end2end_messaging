// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:end2end_messaging/helpers/dialog.dart';
import 'package:end2end_messaging/helpers/space.dart';
import 'package:end2end_messaging/models/message.dart';
import 'package:end2end_messaging/models/user.dart';
import 'package:end2end_messaging/screens/chat_details.dart';
import 'package:end2end_messaging/services/firestore_service.dart';
import 'package:end2end_messaging/utils/colors.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import 'package:pull_down_button/pull_down_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

final isLoadingProvider = StateProvider<bool>((ref) => false);

class ChatScreen extends ConsumerStatefulWidget {
  final FirestoreUser? senderUser;
  final FirestoreUser? receiverUser;
  const ChatScreen({
    super.key,
    required this.senderUser,
    required this.receiverUser,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  TextEditingController messageController = TextEditingController();

  //scrollcontroller
  ScrollController scrollController = ScrollController();

  final storage = const FlutterSecureStorage();

  bool showSecretMessage = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        debugPrint('scrolling down, bottom reached');
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      // if scroll position changes, hide keyboard
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        FocusScope.of(context).unfocus();
      }
    });

    // if user is in chat screen, set all messages as read.
    // if new message comes, it will be set as read
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.senderUser!.phoneNumber)
        .collection('messageTo')
        .doc(widget.receiverUser!.phoneNumber)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get()
        .then((value) {
      for (var message in value.docs) {
        if (message['senderId'] == widget.receiverUser!.phoneNumber) {
          FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.senderUser!.phoneNumber)
              .collection('messageTo')
              .doc(widget.receiverUser!.phoneNumber)
              .collection('messages')
              .doc(message.id)
              .update({
            'isRead': true,
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CupertinoPageScaffold(
          backgroundColor: CustomColors.black,
          navigationBar: navigationBar(context),
          child: Column(
            children: [
              developerModeSwitch(),
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.senderUser!.phoneNumber)
                      .collection('messageTo')
                      .doc(widget.receiverUser!.phoneNumber)
                      .collection('messages')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                          ),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CupertinoActivityIndicator();
                    }
                    if (snapshot.hasData) {
                      final data = snapshot.requireData;
                      if (data.size == 0) {
                        return noMsg(context);
                      } else {
                        markAsReadMessage();
                        List<Message> messages = [];
                        List<DateTime> dateList = [];

                        for (var message in data.docs) {
                          messages.add(Message.fromFirestore(message));
                        }

                        for (var element in messages) {
                          DateTime date = element.createdAt;
                          DateTime newDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                          );
                          dateList.add(newDate);
                        }

                        // removee duplicate dates
                        dateList = dateList.toSet().toList();
                        debugPrint(dateList.toString());

                        return ListView.separated(
                          controller: scrollController,
                          itemCount: dateList.length,
                          separatorBuilder: (context, index) {
                            return SpaceHelper.height(context, 0.03);
                          },
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 20,
                          ),
                          reverse: true,
                          itemBuilder: (context, index) {
                            List<Message> messagesAtThisDay = [];

                            for (var message in messages) {
                              DateTime date = message.createdAt;
                              DateTime newDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                              );
                              if (newDate == dateList[index]) {
                                messagesAtThisDay.add(message);
                              }
                            }

                            return Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: CustomColors.grey.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      getDateName(dateList[index]),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ),
                                ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  separatorBuilder: (context, index) {
                                    return SpaceHelper.height(context, 0.03);
                                  },
                                  shrinkWrap: true,
                                  reverse: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 20,
                                  ),
                                  itemCount: messagesAtThisDay.length,
                                  itemBuilder: (context, index) {
                                    // return Text(messagesAtThisDay[index]
                                    //     .createdAt
                                    //     .toString());
                                    return Column(
                                      crossAxisAlignment:
                                          messagesAtThisDay[index].senderId ==
                                                  FirebaseAuth.instance
                                                      .currentUser!.phoneNumber
                                              ? CrossAxisAlignment.end
                                              : CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 15,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: messagesAtThisDay[index]
                                                        .senderId ==
                                                    widget
                                                        .senderUser!.phoneNumber
                                                ? CustomColors.primaryColor
                                                : CustomColors.grey
                                                    .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: showSecretMessage
                                              ? Text(
                                                  messagesAtThisDay[index]
                                                              .senderId ==
                                                          widget.senderUser!
                                                              .phoneNumber
                                                      ? messagesAtThisDay[index]
                                                          .messageForSender
                                                      : messagesAtThisDay[index]
                                                          .messageForReceiver,
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                )
                                              : messagesAtThisDay[index]
                                                          .isImage ==
                                                      true
                                                  ? imgMsg(
                                                      messagesAtThisDay, index)
                                                  : textMsg(
                                                      messagesAtThisDay, index),
                                        ),
                                        const SizedBox(height: 5),
                                        msgTimeText(messagesAtThisDay, index),
                                      ],
                                    );
                                  },
                                )
                              ],
                            );
                          },
                        );
                      }
                    }
                    return const Expanded(
                      child: Center(
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  },
                ),
              ),
              // const Spacer(),

              textArea(context),
            ],
          ),
        ),
        if (ref.watch(isLoadingProvider))
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CupertinoActivityIndicator(),
            ),
          )
      ],
    );
  }

  Text msgTimeText(List<Message> messagesAtThisDay, int index) {
    return Text(
      timeago.format(messagesAtThisDay[index].createdAt),
      style: GoogleFonts.poppins(
        color: Colors.white.withOpacity(0.6),
        fontSize: 10,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Column noMsg(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SpaceHelper.boslukHeight(context, 0.1),
        Lottie.asset(
          "assets/lottie/ghost.json",
          width: MediaQuery.of(context).size.width / 2,
        ),
        Text(
          'No messages yet',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.7),
            fontSize: MediaQuery.of(context).size.width / 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Say something fun',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.7),
            fontSize: MediaQuery.of(context).size.width / 25,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  SafeArea textArea(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          // only top border grey
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: CustomColors.grey,
                width: 0.0,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              PullDownButton(
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    title: 'Take a photo',
                    onTap: () {
                      takePhoto();
                    },
                    icon: CupertinoIcons.camera,
                  ),
                  PullDownMenuItem(
                    title: 'Select from gallery',
                    onTap: () {
                      selectPhoto();
                    },
                    icon: CupertinoIcons.photo,
                  ),
                ],
                buttonBuilder: (context, showMenu) => CupertinoButton(
                  onPressed: showMenu,
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CupertinoTextField(
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: messageController,
                  cursorColor: CustomColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  placeholder: "Type something...",
                  decoration: BoxDecoration(
                    color: CustomColors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // add send button
              sendMsgBtn(),
            ],
          ),
        ),
      ),
    );
  }

  FloatingActionButton sendMsgBtn() {
    return FloatingActionButton(
      foregroundColor: Colors.white,
      elevation: 5,
      backgroundColor: Colors.orange,
      mini: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Icon(
        CupertinoIcons.paperplane_fill,
        color: Colors.white,
      ),
      onPressed: () async {
        if (messageController.text.trim().isEmpty) {
          return;
        }

        ref.read(isLoadingProvider.notifier).state = true;

        // sender
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.senderUser!.phoneNumber)
            .set({
          'createdAt': DateTime.now(),
        }).then((value) {
          FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.senderUser!.phoneNumber)
              .collection('messageTo')
              .doc(widget.receiverUser!.phoneNumber)
              .set({
            'createdAt': DateTime.now(),
            'lastMessage': messageController.text,
          });
        });

        // receiver
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.receiverUser!.phoneNumber)
            .set({
          'createdAt': DateTime.now(),
        }).then((value) {
          FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.receiverUser!.phoneNumber)
              .collection('messageTo')
              .doc(widget.senderUser!.phoneNumber)
              .set({
            'createdAt': DateTime.now(),
            'lastMessage': messageController.text,
          });
        });

        //sender
        FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.senderUser!.phoneNumber)
            .collection('messageTo')
            .doc(widget.receiverUser!.phoneNumber)
            .collection('messages')
            .add(
          {
            'messageForReceiver': await encryptMsg(messageController.text),
            'messageForSender':
                await encryptMsgForSender(messageController.text),
            'createdAt': DateTime.now(),
            'isRead': true,
            'isImage': false,
            'sendNotification': false,
            'senderId': widget.senderUser!.phoneNumber,
            'receiverId': widget.receiverUser!.phoneNumber,
          },
        );

        FirestoreUser user =
            await FirestoreService().getUserData(widget.receiverUser!.id);

        // receviver
        FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.receiverUser!.phoneNumber)
            .collection('messageTo')
            .doc(widget.senderUser!.phoneNumber)
            .collection('messages')
            .add(
          {
            'messageForReceiver': await encryptMsg(messageController.text),
            'messageForSender':
                await encryptMsgForSender(messageController.text),
            'createdAt': DateTime.now(),
            'isRead': false,
            'isImage': false,
            'sendNotification': user.status == 'Online' ? false : true,
            'senderId': widget.senderUser!.phoneNumber,
            'receiverId': widget.receiverUser!.phoneNumber,
          },
        );

        messageController.clear();
        ref.read(isLoadingProvider.notifier).state = false;
      },
    );
  }

  FutureBuilder<String> textMsg(List<Message> messagesAtThisDay, int index) {
    return FutureBuilder(
        future: decryptMsg(
          messagesAtThisDay[index].messageForReceiver,
          messagesAtThisDay[index].senderId,
          messagesAtThisDay[index].receiverId,
          messagesAtThisDay[index].messageForSender,
        ),
        builder: (context, snapshot) {
          debugPrint("data: ${snapshot.data}");
          if (snapshot.hasData) {
            return Text(
              snapshot.data.toString(),
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
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
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Shimmer(
              gradient: LinearGradient(
                colors: [
                  Colors.grey.withOpacity(0.5),
                  Colors.grey.withOpacity(0.3),
                  Colors.grey.withOpacity(0.5),
                ],
              ),
              child: Container(
                height: 10,
                width: 100,
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
          );
        });
  }

  FutureBuilder<String> imgMsg(List<Message> messagesAtThisDay, int index) {
    return FutureBuilder(
      future: decryptMsg(
        messagesAtThisDay[index].messageForReceiver,
        messagesAtThisDay[index].senderId,
        messagesAtThisDay[index].receiverId,
        messagesAtThisDay[index].messageForSender,
      ),
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          DecorationImage image = DecorationImage(
            image: Image.memory(
              base64Decode(
                snapshot.data.toString(),
              ),
            ).image,
            fit: BoxFit.cover,
          );
          if (messagesAtThisDay[index].isImage == false) {
            return Container();
          }
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      actions: [
                        // download button
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            final result = await ImageGallerySaver.saveImage(
                                base64Decode(
                                  snapshot.data.toString(),
                                ),
                                quality: 60,
                                name: "hello");
                            debugPrint(result.toString());
                            if (result['isSuccess'] == true) {
                              DialogHelper().cupertinoDialog(
                                title: 'Success',
                                subtitle:
                                    'Image saved to gallery successfully.',
                              );
                            } else {
                              DialogHelper().cupertinoDialog(
                                title: 'Error',
                                subtitle: 'Image could not be saved.',
                              );
                            }
                          },
                          child: const Icon(
                            CupertinoIcons.cloud_download,
                            size: 30,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                      backgroundColor: Colors.black,
                      leading: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          CupertinoIcons.back,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    backgroundColor: Colors.black,
                    body: Center(
                      child: InteractiveViewer(
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            image: image,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: Image.memory(
                    base64Decode(
                      snapshot.data.toString(),
                    ),
                  ).image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Shimmer(
            gradient: LinearGradient(
              colors: [
                Colors.grey.withOpacity(0.5),
                Colors.grey.withOpacity(0.3),
                Colors.grey.withOpacity(0.5),
              ],
            ),
            child: Container(
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width / 2,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
        );
      },
    );
  }

  Container developerModeSwitch() {
    return Container(
      decoration: BoxDecoration(
          color: CustomColors.black,
          border: Border(
            bottom: BorderSide(
              color: CustomColors.grey,
              width: 0.0,
            ),
          )),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          title: Text(
            'Developer Mode',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          // small cupertino switch
          trailing: CupertinoSwitch(
            value: showSecretMessage,
            onChanged: (value) {
              setState(() {
                showSecretMessage = value;
              });
            },
            activeColor: CustomColors.primaryColor,
          ),
        ),
      ),
    );
  }

  CupertinoNavigationBar navigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      backgroundColor: CustomColors.black,
      border: Border(
        bottom: BorderSide(
          color: CustomColors.black,
          width: 0.0,
        ),
      ),
      padding: const EdgeInsetsDirectional.only(start: 0.0, end: 0.0),
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
      middle: Row(
        children: [
          GestureDetector(
            // open image in fullscreen
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
                        child: const Icon(
                          CupertinoIcons.back,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                      actions: [
                        // download button
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            var response = await Dio().get(
                                widget.receiverUser!.photoURL,
                                options:
                                    Options(responseType: ResponseType.bytes));
                            final result = await ImageGallerySaver.saveImage(
                                Uint8List.fromList(response.data),
                                quality: 60,
                                name: "hello");
                            debugPrint(result.toString());
                            if (result['isSuccess'] == true) {
                              DialogHelper().cupertinoDialog(
                                title: 'Success',
                                subtitle:
                                    'Image saved to gallery successfully.',
                              );
                            } else {
                              DialogHelper().cupertinoDialog(
                                title: 'Error',
                                subtitle: 'Image could not be saved.',
                              );
                            }
                          },
                          child: const Icon(
                            CupertinoIcons.cloud_download,
                            size: 30,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.black,
                    body: Center(
                      child: Hero(
                        tag: widget.receiverUser!.photoURL,
                        child: // interactice image
                            InteractiveViewer(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.receiverUser!.photoURL,
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
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                widget.receiverUser!.photoURL,
                height: 30,
                width: 30,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverUser!.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.receiverUser!.phoneNumber)
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                          "Error",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Shimmer(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.withOpacity(0.5),
                                Colors.grey.withOpacity(0.3),
                                Colors.grey.withOpacity(0.5),
                              ],
                            ),
                            child: Container(
                              height: 10,
                              width: 100,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        final data = snapshot.requireData;
                        return Text(
                          data['status'] == 'Online'
                              ? 'Online'
                              : 'Last seen ${timeago.format(data['lastSeen'].toDate())}',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      }
                      return const SizedBox();
                    }),
              ],
            ),
          ),
        ],
      ),
      trailing: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ChatDetailsPage(user: widget.receiverUser!),
            ),
          );
        },
        child: Icon(
          CupertinoIcons.info,
          size: 25,
          color: CustomColors.primaryColor,
        ),
      ),
    );
  }

  markAsReadMessage() async {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.senderUser!.phoneNumber)
        .collection('messageTo')
        .doc(widget.receiverUser!.phoneNumber)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get()
        .then((value) {
      for (var message in value.docs) {
        if (message['senderId'] == widget.receiverUser!.phoneNumber) {
          FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.senderUser!.phoneNumber)
              .collection('messageTo')
              .doc(widget.receiverUser!.phoneNumber)
              .collection('messages')
              .doc(message.id)
              .update({
            'isRead': true,
          });
        }
      }
    });
  }

  String getDateName(DateTime date) {
    DateTime now = DateTime.now();
    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today';
    } else if (date.day == now.day - 1 &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<String> decryptMsg(String secretMessage, String senderId,
      String receiverId, String secretMessageForSender) async {
    var privateKey = await storage.read(key: "pri_key");
    var userid = await storage.read(key: "number");

    // debugPrint("privateKey: $privateKey");

    if (senderId == userid) {
      var deMsg =
          await RSA.decryptPKCS1v15(secretMessageForSender, privateKey!);
      // debugPrint(deMsg);

      return deMsg;
    }

    // debugPrint("privateKey: $privateKey");

    var deMsg = await RSA.decryptPKCS1v15(secretMessage, privateKey!);
    // debugPrint(deMsg);

    return deMsg;
  }

  Future<String> encryptMsg(String message) async {
    String publicKey = '';

    publicKey = widget.receiverUser!.publicKey;

    var enMsg = await RSA.encryptPKCS1v15(message, publicKey);
    // debugPrint("enMsg: $enMsg");

    return enMsg;
  }

  Future<String> encryptMsgForSender(String message) async {
    String publicKey = '';

    publicKey = widget.senderUser!.publicKey;

    var enMsg = await RSA.encryptPKCS1v15(message, publicKey);
    // debugPrint("enMsg: $enMsg");

    return enMsg;
  }

  void takePhoto() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 70,
    );
    if (image == null) return;

    String base64 = await Navigator.push(
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
              child: const Icon(
                CupertinoIcons.back,
                size: 30,
                color: Colors.blue,
              ),
            ),
            actions: [
              // send text
              Center(
                child: GestureDetector(
                  onTap: () {
                    // make it to base64
                    // send it to receiver
                    String base64String =
                        base64Encode(File(image.path).readAsBytesSync());

                    return Navigator.pop(context, base64String);
                  },
                  child: Text(
                    'Send',
                    style: GoogleFonts.poppins(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: Hero(
              tag: image.path,
              child: // interactice image
                  InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(image.path),
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
    debugPrint(base64);

    ref.read(isLoadingProvider.notifier).state = true;
    messageController.clear();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.senderUser!.phoneNumber)
        .set({
      'createdAt': DateTime.now(),
    }).then((value) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.senderUser!.phoneNumber)
          .collection('messageTo')
          .doc(widget.receiverUser!.phoneNumber)
          .set({
        'createdAt': DateTime.now(),
        'lastMessage': base64,
      });
    });

    // receiver
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.receiverUser!.phoneNumber)
        .set({
      'createdAt': DateTime.now(),
    }).then((value) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.receiverUser!.phoneNumber)
          .collection('messageTo')
          .doc(widget.senderUser!.phoneNumber)
          .set({
        'createdAt': DateTime.now(),
        'lastMessage': base64,
      });
    });

    //sender
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.senderUser!.phoneNumber)
        .collection('messageTo')
        .doc(widget.receiverUser!.phoneNumber)
        .collection('messages')
        .add(
      {
        'messageForReceiver': await encryptMsg(base64),
        'messageForSender': await encryptMsgForSender(base64),
        'createdAt': DateTime.now(),
        'isRead': true,
        'isImage': true,
        'sendNotification': false,
        'senderId': widget.senderUser!.phoneNumber,
        'receiverId': widget.receiverUser!.phoneNumber,
      },
    );

    FirestoreUser user =
        await FirestoreService().getUserData(widget.receiverUser!.id);

    // receviver
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.receiverUser!.phoneNumber)
        .collection('messageTo')
        .doc(widget.senderUser!.phoneNumber)
        .collection('messages')
        .add(
      {
        'messageForReceiver': await encryptMsg(base64),
        'messageForSender': await encryptMsgForSender(base64),
        'createdAt': DateTime.now(),
        'isRead': false,
        'isImage': true,
        'sendNotification': user.status == 'Online' ? false : true,
        'senderId': widget.senderUser!.phoneNumber,
        'receiverId': widget.receiverUser!.phoneNumber,
      },
    );

    ref.read(isLoadingProvider.notifier).state = false;
  }

  void selectPhoto() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 70,
    );
    if (image == null) return;

    //  converto to base64
    String base64Temp = base64Encode(File(image.path).readAsBytesSync());
    debugPrint(base64Temp.length.toString());

    // convert to Uint8List
    Uint8List bytes = base64Decode(base64Temp);
    debugPrint(bytes.length.toString());

    String base64 = await Navigator.push(
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
              child: const Icon(
                CupertinoIcons.back,
                size: 30,
                color: Colors.blue,
              ),
            ),
            actions: [
              // send text
              Center(
                child: GestureDetector(
                  onTap: () {
                    // make it to base64
                    // send it to receiver
                    String base64String =
                        base64Encode(File(image.path).readAsBytesSync());

                    return Navigator.pop(context, base64String);
                  },
                  child: Text(
                    'Send',
                    style: GoogleFonts.poppins(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: Hero(
              tag: image.path,
              child: // interactice image
                  InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(image.path),
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
    debugPrint(base64);
    ref.read(isLoadingProvider.notifier).state = true;
    messageController.clear();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.senderUser!.phoneNumber)
        .set({
      'createdAt': DateTime.now(),
    }).then((value) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.senderUser!.phoneNumber)
          .collection('messageTo')
          .doc(widget.receiverUser!.phoneNumber)
          .set({
        'createdAt': DateTime.now(),
        'lastMessage': base64,
      });
    });

    // receiver
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.receiverUser!.phoneNumber)
        .set({
      'createdAt': DateTime.now(),
    }).then((value) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.receiverUser!.phoneNumber)
          .collection('messageTo')
          .doc(widget.senderUser!.phoneNumber)
          .set({
        'createdAt': DateTime.now(),
        'lastMessage': base64,
      });
    });

    //sender
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.senderUser!.phoneNumber)
        .collection('messageTo')
        .doc(widget.receiverUser!.phoneNumber)
        .collection('messages')
        .add(
      {
        'messageForReceiver': await encryptMsg(base64),
        'messageForSender': await encryptMsgForSender(base64),
        'createdAt': DateTime.now(),
        'isRead': true,
        'isImage': true,
        'sendNotification': false,
        'senderId': widget.senderUser!.phoneNumber,
        'receiverId': widget.receiverUser!.phoneNumber,
      },
    );

    FirestoreUser user =
        await FirestoreService().getUserData(widget.receiverUser!.id);

    // receviver
    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.receiverUser!.phoneNumber)
        .collection('messageTo')
        .doc(widget.senderUser!.phoneNumber)
        .collection('messages')
        .add(
      {
        'messageForReceiver': await encryptMsg(base64),
        'messageForSender': await encryptMsgForSender(base64),
        'createdAt': DateTime.now(),
        'isRead': false,
        'isImage': true,
        'sendNotification': user.status == 'Online' ? false : true,
        'senderId': widget.senderUser!.phoneNumber,
        'receiverId': widget.receiverUser!.phoneNumber,
      },
    );

    ref.read(isLoadingProvider.notifier).state = false;
  }
}
