import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../screens/login_page.dart';

class ChangePasswordController extends GetxController {

  var oldPass = ''.obs;
  var newPass = ''.obs;
  var confirmPass = ''.obs;
  var isLoading = false.obs;

  /// 🔐 UPDATE PASSWORD (FULL VALIDATION)
  Future<void> updatePassword() async {

    if (oldPass.value.isEmpty ||
        newPass.value.isEmpty ||
        confirmPass.value.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return;
    }

    if (newPass.value.length < 6) {
      Get.snackbar("Weak Password", "Minimum 6 characters required");
      return;
    }

    if (newPass.value != confirmPass.value) {
      Get.snackbar("Mismatch", "Passwords do not match");
      return;
    }

    if (oldPass.value == newPass.value) {
      Get.snackbar("Invalid", "New password must be different");
      return;
    }

    try {
      isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.snackbar("Error", "User not logged in");
        return;
      }

      final email = user.email!;

      /// 🔥 RE-AUTHENTICATE
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: oldPass.value,
      );

      await user.reauthenticateWithCredential(credential);

      /// 🔥 UPDATE PASSWORD
      await user.updatePassword(newPass.value);

      /// 🔥 FORCE LOGOUT AFTER CHANGE
      await FirebaseAuth.instance.signOut();

      Get.snackbar("Success", "Password updated. Please login again");

      Get.offAll(() => const LoginPage());

    } on FirebaseAuthException catch (e) {

      if (e.code == "wrong-password") {
        Get.snackbar("Error", "Current password is incorrect");
      } else {
        Get.snackbar("Error", e.message ?? "Failed");
      }

    } finally {
      isLoading.value = false;
    }
  }
}