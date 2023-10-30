import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  // Properties
  // final String id;
  final String messageForReceiver;
  final String messageForSender;
  final String senderId;
  final String receiverId;
  final DateTime createdAt;
  final bool isRead;
  final bool isImage;

  // Constructor
  Message({
    // required this.id,
    required this.messageForReceiver,
    required this.messageForSender,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
    required this.isRead,
    required this.isImage,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Message(
      // id: data['id'],
      messageForReceiver: data['messageForReceiver'],
      messageForSender: data['messageForSender'],
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      createdAt: data['createdAt'].toDate(),
      isRead: data['isRead'],
      isImage: data['isImage'],
    );
  }
}
