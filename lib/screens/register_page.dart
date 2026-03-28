import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_todo_app/screens/privacy_policy_page.dart';
import '../controller/auth_controller.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final AuthController controller = Get.find();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  InputDecoration customInput(String label, IconData icon) {

    final theme = Theme.of(context);

    return InputDecoration(
      labelText: label,

      prefixIcon: Icon(icon),

      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    final data = Get.arguments;

    if (data != null){
      emailController.text = data["email"] ?? "";
      passwordController.text = data["password"] ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [

          /// 🌈 GRADIENT BACKGROUND
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 🔥 BLUR EFFECT
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: Column(
                children: [

                  const SizedBox(height: 30),

                  /// 🔹 HEADER ICON
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// TITLE
                  Text(
                    "Create Account",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Register to get started",
                    style: TextStyle(color: Colors.white70),
                  ),

                  const SizedBox(height: 30),

                  /// 🧊 GLASS CARD
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),

                        child: Column(
                          children: [

                            /// NAME
                            TextField(
                              controller: nameController,
                              decoration: customInput(
                                "Full Name",
                                Icons.person_outline,
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// EMAIL
                            TextField(
                              controller: emailController,
                              decoration: customInput(
                                "Email",
                                Icons.email_outlined,
                              ),
                            ),

                            const SizedBox(height: 16),

                            /// PASSWORD
                            TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              decoration: customInput(
                                "Password",
                                Icons.lock_outline,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            /// 🔥 REGISTER BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 55,

                              child: Obx(() => ElevatedButton(

                                style: ElevatedButton.styleFrom(
                                  elevation: 6,
                                  shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                                  backgroundColor: theme.colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),

                                onPressed: controller.isLoading.value
                                    ? null
                                    : () async {

                                  final name = nameController.text.trim();
                                  final email = emailController.text.trim();
                                  final password = passwordController.text.trim();

                                  if (name.isEmpty || email.isEmpty || password.isEmpty) {
                                    Get.snackbar("Error", "All fields are required");
                                    return;
                                  }

                                  if (!GetUtils.isEmail(email)) {
                                    Get.snackbar("Invalid Email", "Enter valid email");
                                    return;
                                  }

                                  try {
                                    controller.isLoading.value = true;

                                    final methods = await FirebaseAuth.instance
                                        .fetchSignInMethodsForEmail(email);

                                    if (methods.isNotEmpty) {
                                      controller.isLoading.value = false;

                                      Get.snackbar(
                                        "Account Exists",
                                        "Redirecting to login...",
                                      );

                                      await Future.delayed(const Duration(seconds: 1));

                                      Get.off(() => const LoginPage(), arguments: {
                                        "email": email,
                                        "password": password,
                                      });

                                      return;
                                    }

                                    final query = await FirebaseFirestore.instance
                                        .collection("users")
                                        .where("email", isEqualTo: email)
                                        .limit(1)
                                        .get();

                                    if (query.docs.isNotEmpty) {
                                      controller.isLoading.value = false;

                                      Get.snackbar(
                                        "Already Registered",
                                        "Redirecting to login...",
                                      );

                                      await Future.delayed(const Duration(seconds: 1));

                                      Get.off(() => const LoginPage(), arguments: {
                                        "email": email,
                                        "password": password,
                                      });

                                      return;
                                    }

                                    controller.isLoading.value = false;

                                    Get.to(
                                          () => const PrivacyPolicyPage(),
                                      arguments: {
                                        "name": name,
                                        "email": email,
                                        "password": password,
                                      },
                                    );

                                  } catch (e) {
                                    controller.isLoading.value = false;
                                    Get.snackbar("Error", e.toString());
                                  }
                                },

                                child: controller.isLoading.value
                                    ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text(
                                  "Register",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              )),
                            ),

                            const SizedBox(height: 20),

                            /// DIVIDER
                            Row(
                              children: const [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text("OR"),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: 20),

                            /// GOOGLE BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: 55,

                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  side: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),

                                onPressed: () {
                                  controller.signInWithGoogle();
                                },

                                icon: Image.network(
                                  "https://cdn-icons-png.flaticon.com/512/281/281764.png",
                                  height: 22,
                                ),

                                label: const Text(
                                  "Continue with Google",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// LOGIN LINK
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account?",
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  child: const Text("Login"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}