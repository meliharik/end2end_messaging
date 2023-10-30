import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final Reference _storage = FirebaseStorage.instance.ref();
  String? photoId;

  Future<String> uploadProfilePhoto(File file) async {
    photoId = const Uuid().v4();
    UploadTask manager = _storage
        .child("photos/profile_photos/profile_$photoId.jpg")
        .putFile(file);
    TaskSnapshot snapshot = await manager;
    String uploadedUrl = await snapshot.ref.getDownloadURL();
    return uploadedUrl;
  }
}
