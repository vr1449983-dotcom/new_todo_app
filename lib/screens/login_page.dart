import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final AuthController authController = Get.put(AuthController());

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();

    final data = Get.arguments;
    if (data != null) {
      emailController.text = data["email"] ?? "";
      passwordController.text = data["password"] ?? "";
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration inputStyle(String hint, IconData icon) {
    final theme = Theme.of(context);

    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),

      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),

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
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [

          /// 🌈 MODERN GRADIENT BACKGROUND
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

          /// CONTENT
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),

                child: Column(
                  children: [

                    /// 🔐 ICON
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: const Icon(
                        Icons.lock_person_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// TITLE
                    Obx(() {
                      final name = authController.userName.value;

                      return Text(
                        name.isEmpty
                            ? "Welcome Back"
                            : "Welcome, $name",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),

                    const SizedBox(height: 6),

                    const Text(
                      "Login to continue",
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
                            color: theme.colorScheme.surface.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),

                          child: Column(
                            children: [

                              /// EMAIL
                              TextField(
                                controller: emailController,
                                onChanged: (value) {
                                  authController.fetchUserNameByEmail(value.trim());
                                },
                                decoration: inputStyle("Email", Icons.email_outlined),
                              ),

                              const SizedBox(height: 16),

                              /// PASSWORD
                              TextField(
                                controller: passwordController,
                                obscureText: obscurePassword,
                                decoration: inputStyle("Password", Icons.lock_outline)
                                    .copyWith(
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

                              const SizedBox(height: 10),

                              /// FORGOT PASSWORD
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Get.to(() => const ForgotPasswordPage());
                                  },
                                  child: const Text("Forgot Password?"),
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// LOGIN BUTTON
                              SizedBox(
                                width: double.infinity,
                                height: 54,

                                child: Obx(() => ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 6,
                                    shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                                    backgroundColor: theme.colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),

                                  onPressed: authController.isLoading.value
                                      ? null
                                      : () {
                                    authController.login(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                    );
                                  },

                                  child: authController.isLoading.value
                                      ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                      : const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )),
                              ),

                              const SizedBox(height: 18),

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

                              const SizedBox(height: 18),

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
                                    authController.signInWithGoogle();
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

                              /// REGISTER
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don’t have an account?",
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.to(() => const RegisterPage());
                                    },
                                    child: const Text("Register"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}