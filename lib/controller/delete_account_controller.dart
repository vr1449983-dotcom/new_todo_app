import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../services/backup_service.dart';
import '../services/reauth_service.dart';

class DeleteAccountController extends GetxController {
  var isLoading = false.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// MAIN ENTRY
  Future<void> startDeleteFlow(String method) async {
    try {
      isLoading.value = true;

      final user = _auth.currentUser!;
      final uid = user.uid;

      /// 1. Re-authenticate
      if (method == "google") {
        await ReAuthService.reauthWithGoogle();
      } else if (method == "apple") {
        await ReAuthService.reauthWithApple();
      }

      /// 2. Fetch user data for backup
      final userDoc = await _db.collection("users").doc(uid).get();

      final categories = await _db
          .collection("users")
          .doc(uid)
          .collection("categories")
          .get();

      final todos = await _db
          .collection("users")
          .doc(uid)
          .collection("todos")
          .get();

      final backupData = {
        "profile": userDoc.data(),
        "categories": categories.docs.map((e) => e.data()).toList(),
        "todos": todos.docs.map((e) => e.data()).toList(),
      };

      /// 3. Create ZIP backup
      final backupFile = await BackupService.createBackup(backupData);

      /// (Optional) Upload to Firebase Storage here and get URL

      /// 4. Soft delete (mark account)
      await _db.collection("users").doc(uid).update({
        "isDeleted": true,
        "deletedAt": FieldValue.serverTimestamp(),
      });

      /// 5. Sign out user
      await _auth.signOut();

      Get.snackbar("Deleted", "Account marked for deletion");

      Get.offAllNamed("/login");

    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// RESTORE ACCOUNT
  Future<void> restoreAccount(String uid) async {
    await _db.collection("users").doc(uid).update({
      "isDeleted": false,
      "deletedAt": null,
    });
  }

  /// ADMIN HARD DELETE
  Future<void> adminDeleteUser(String uid) async {
    final userRef = _db.collection("users").doc(uid);

    final cats = await userRef.collection("categories").get();
    for (var d in cats.docs) {
      await d.reference.delete();
    }

    final todos = await userRef.collection("todos").get();
    for (var d in todos.docs) {
      await d.reference.delete();
    }

    await userRef.delete();
  }
}