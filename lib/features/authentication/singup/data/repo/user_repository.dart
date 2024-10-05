import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserRepository {
  final FirebaseStorage _firebaseStorage;
  final ImagePicker _imagePicker;

  UserRepository(this._firebaseStorage, this._imagePicker);

  Future<String?> pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    return pickedFile?.path;
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      final ref = _firebaseStorage.ref('users/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Image upload failed: $e");
      return null;
    }
  }

  Future<void> saveUser(String name, int age, String profileImageUrl) async {
    await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'age': age,
      'profileImage': profileImageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'phone': FirebaseAuth.instance.currentUser!.phoneNumber,
    });
  }
}
