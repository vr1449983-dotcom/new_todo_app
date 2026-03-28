import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:new_todo_app/screens/todo_list.dart';
import '../screens/privacy_policy_page.dart';
import '../screens/register_page.dart';

class AuthController extends GetxController {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;
  RxString userName = "".obs;
  RxBool isNameLoading = false.obs;

  // LOGIN
  Future<void> login(String email, String password) async {

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email and Password cannot be empty");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Invalid Email", "Enter valid email");
      return;
    }

    try {

      isLoading.value = true;

      final methods = await _auth.fetchSignInMethodsForEmail(email);

      if (methods.isEmpty) {

        Get.snackbar(
          "Not Registered",
          "You are not registered. Please register first",
        );

        Get.to(
              () => const RegisterPage(),
          arguments: {
            "email": email,
            "password": password,
          },
        );

        return;
      }

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = _auth.currentUser;

      await _firestore.collection("users").doc(user!.uid).set({
        "lastLogin": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar("Success", "Login Successful");

      Get.offAll(() => const TodoListScreen());

    } on FirebaseAuthException catch (e) {

      if (e.code == "wrong-password" || e.code == "invalid-credential") {

        Get.snackbar(
          "Wrong Password",
          "Please enter correct password",
        );

      } else {

        Get.snackbar("Error", e.message ?? "Login Failed");

      }

    } finally {

      isLoading.value = false;

    }
  }

  // REGISTER
  Future<void> register(String name, String email, String password) async {

    try {

      isLoading.value = true;

      // CREATE AUTH USER
      UserCredential credential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;

      // SAVE USER DATA IN FIRESTORE
      await _firestore.collection("users").doc(user.uid).set({
        "name": name,
        "email": email,
        "photoUrl": "",
        "createdAt": FieldValue.serverTimestamp(),
        "lastLogin": FieldValue.serverTimestamp(),
      });

      Get.snackbar("Success", "Registration Successful");

      Get.offAll(() => const TodoListScreen());

    } on FirebaseAuthException catch (e) {

      Get.snackbar("Error", e.message ?? "Registration failed");

    } finally {

      isLoading.value = false;

    }
  }
  Future<void> fetchUserNameByEmail(String email) async {
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      userName.value = "";
      return;
    }

    try {
      isNameLoading.value = true;

      final query = await _firestore
          .collection("users")
          .where("email", isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        userName.value = query.docs.first.data()["name"] ?? "";
      } else {
        userName.value = "";
      }

    } catch (e) {
      userName.value = "";
    } finally {
      isNameLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      final GoogleSignIn googleSignIn = GoogleSignIn();

      await googleSignIn.signOut(); // optional (forces account picker)

      final GoogleSignInAccount? googleUser =
      await googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      final user = userCredential.user!;

      final doc =
      await _firestore.collection("users").doc(user.uid).get();

      /// 🔥 CHECK: NEW USER OR POLICY NOT ACCEPTED
      if (!doc.exists ||
          (doc.data()?["acceptedPolicy"] ?? false) != true) {

        isLoading.value = false;

        Get.to(() => const PrivacyPolicyPage(), arguments: {
          "isGoogleUser": true,
          "user": user,
        });

        return;
      }

      /// ✅ NORMAL LOGIN
      await _firestore.collection("users").doc(user.uid).set({
        "lastLogin": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Get.snackbar("Success", "Welcome Back");

      Get.offAll(() => const TodoListScreen());

    } catch (e) {
      Get.snackbar("Error", e.toString());
      print("GoogleSignIn Error = ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}