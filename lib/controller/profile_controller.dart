import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../screens/login_page.dart';

class ProfileController extends GetxController {
  /// USER DATA
  var uid = ''.obs;
  var name = ''.obs;
  var email = ''.obs;
  var photoUrl = ''.obs;

  /// STATUS
  var isUploading = false.obs;
  var isEmailVerified = false.obs;

  /// META INFO
  var lastLogin = ''.obs;
  var createdAt = ''.obs;

  /// IMAGE PICKER
  final picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// ================================
  /// LOAD USER DATA (REALTIME)
  /// ================================
  void loadUserData() {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      uid.value = user.uid;
      isEmailVerified.value = user.emailVerified;

      /// CREATED AT
      if (user.metadata.creationTime != null) {
        createdAt.value = DateFormat('dd MMM yyyy, hh:mm a')
            .format(user.metadata.creationTime!);
      }

      /// FIRESTORE REALTIME LISTENER
      FirebaseFirestore.instance
          .collection("users")
          .doc(uid.value)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          final data = doc.data()!;

          name.value = data["name"] ?? "";
          email.value = data["email"] ?? user.email ?? "";
          photoUrl.value = data["photoUrl"] ?? "";

          /// LAST LOGIN
          if (data["lastLogin"] != null) {
            lastLogin.value = DateFormat('dd MMM yyyy, hh:mm a')
                .format(data["lastLogin"].toDate());
          } else {
            lastLogin.value = "First Login";
          }
        }
      });

    } catch (e) {
      Get.snackbar("Error", "Failed to load profile");
    }
  }

  /// ================================
  /// REFRESH EMAIL VERIFICATION
  /// ================================
  Future<void> refreshEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();

      isEmailVerified.value =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    } catch (e) {
      Get.snackbar("Error", "Failed to refresh status");
    }
  }

  /// ================================
  /// PICK IMAGE + UPLOAD
  /// ================================
  Future<void> pickImage({required bool fromCamera}) async {
    try {
      isUploading.value = true;

      /// ✅ ASK PERMISSION
      PermissionStatus status = fromCamera
          ? await Permission.camera.request()
          : await Permission.photos.request();

      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }

        Get.snackbar("Permission", "Permission denied");
        isUploading.value = false;
        return;
      }

      /// ✅ PICK IMAGE
      final pickedFile = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
      );

      if (pickedFile == null) {
        isUploading.value = false;
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final file = File(pickedFile.path);

      /// ☁️ CLOUDINARY UPLOAD (your existing code)
      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/drzpe0v4i/image/upload",
      );

      var request = http.MultipartRequest("POST", url);
      request.fields["upload_preset"] = "profile_upload";

      request.files.add(
        await http.MultipartFile.fromPath("file", file.path),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);

      if (data["secure_url"] != null) {
        String imageUrl = data["secure_url"];

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .set({
          "photoUrl": imageUrl,
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        photoUrl.value = imageUrl;

        Get.snackbar("Success", "Profile updated");
      } else {
        Get.snackbar("Error", "Upload failed");
      }

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isUploading.value = false;
    }
  }

  /// ================================
  /// REMOVE PHOTO
  /// ================================
  Future<void> removePhoto() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "photoUrl": "",
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      photoUrl.value = "";

    } catch (e) {
      Get.snackbar("Error", "Failed to remove photo");
    }
  }

  /// ================================
  /// UPDATE NAME
  /// ================================
  Future<void> updateName(String newName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "name": newName,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      name.value = newName;

    } catch (e) {
      Get.snackbar("Error", "Failed to update name");
    }
  }

  /// ================================
  /// LOGOUT
  /// ================================
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => const LoginPage());
  }
}