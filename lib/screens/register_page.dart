import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

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

      prefixIcon: Icon(
        icon,
        color: theme.colorScheme.primary,
      ),

      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 2,
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
      backgroundColor: theme.colorScheme.surface,


      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              /// HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primaryContainer,
                    ],
                  ),

                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(35),
                  ),
                ),

                child: Column(
                  children: [

                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_add_alt_1,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Register to get started",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 45),

              /// FORM CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),

                child: Container(
                  padding: const EdgeInsets.all(26),

                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(22),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      )
                    ],
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

                      const SizedBox(height: 20),

                      /// EMAIL
                      TextField(
                        controller: emailController,
                        decoration: customInput(
                          "Email",
                          Icons.email_outlined,
                        ),
                      ),

                      const SizedBox(height: 20),

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

                      const SizedBox(height: 32),

                      /// REGISTER BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: Obx(() => ElevatedButton(

                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),

                          onPressed: controller.isLoading.value
                              ? null
                              : () {

                            controller.register(
                              nameController.text.trim(),
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );

                          },

                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),

                            child: controller.isLoading.value
                                ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              "Register",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )),
                      ),

                      const SizedBox(height: 26),


                      /// 🔹 DIVIDER
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// 🔐 GOOGLE SIGN-IN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),

                          onPressed: () {
                            controller.signInWithGoogle(); // ✅ CALL ONLY
                          },

                          icon: Image.network(
                            "https://cdn-icons-png.flaticon.com/512/281/281764.png",
                            height: 22,
                          ),

                          label: const Text(
                            "Continue with Google",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      /// LOGIN LINK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },

                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}