import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState
    extends State<ForgotPasswordPage> {

  late TextEditingController emailController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    /// ✅ Auto-fill email (if logged in)
    emailController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.email ?? "",
    );
  }

  /// 🔥 SEND RESET EMAIL
  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter your email");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Invalid Email", "Enter valid email");
      return;
    }

    try {
      setState(() => isLoading = true);

      /// ✅ SIMPLE & CORRECT (NO deep link)
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);

      /// 🔥 PROFESSIONAL MESSAGE
      Get.snackbar(
        "Reset Link Sent",
        "Check your email and login again after resetting password",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      /// ✅ GO TO LOGIN PAGE
      Get.offAllNamed("/login");
      // OR:
      // Get.offAll(() => const LoginPage());

    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Failed");
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: const Text("Forgot Password"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            /// 🔥 PREMIUM GLASS CARD
            ClipRRect(
              borderRadius: BorderRadius.circular(25),

              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

                child: Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(.7),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// TITLE
                      Text(
                        "Reset your password",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Enter your email and we’ll send you a reset link.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// EMAIL FIELD
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// SEND BUTTON
                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: isLoading ? null : sendResetEmail,

                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),

                          child: isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            "Send Reset Link",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// BACK BUTTON
                      Center(
                        child: TextButton(
                          onPressed: () => Get.offAll(() => const LoginPage()),
                          child: const Text("Back to Login"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}