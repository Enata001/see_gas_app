import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';
import '../utils/firebase_fields.dart';
import '../utils/typedefs.dart';

class FirebaseStorageMethods {
  final _storage = FirebaseStorage.instance;

  Future<String> uploadPicture(
      {String name = FirebaseFields.users,
      bool isPost = false,
      Uint8List? file,
      required UserId userId}) async {
    String photoLink = Constants.profileLink;
    try {
      final ref = _storage.ref().child(name).child(userId);
      if (isPost) {
        final id = const Uuid().v4();
        ref.child(id);
      }

      if (file != null) {
        photoLink = await ref.putData(file).snapshot.ref.getDownloadURL();
      }
      return photoLink;
    } on Exception {
      return Constants.profileLink;
    }
  }

  Future<String> uploadImageToFirebase(Uint8List image, String userId) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('profile_pictures/$userId.jpg');
      await storageRef.putData(image);

      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Failed to upload image: $e');
      return Constants.profileLink;
    }
  }
}
