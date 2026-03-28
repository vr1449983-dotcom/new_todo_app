import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_todo_app/screens/todo_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/auth_controller.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  bool isAccepted = false;

  @override
  Widget build(BuildContext context) {
    final data = Get.arguments ?? {};
    final bool isGoogleUser = data["isGoogleUser"] ?? false;
    final bool fromProfile = data["fromProfile"] ?? false;

    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        /// ❌ If opened from profile → allow normal back
        if (fromProfile) {
          Get.back();
          return;
        }

        /// 🔒 If coming from register/google → force accept
        final shouldPop = await Get.dialog(
          AlertDialog(
            title: const Text("Exit"),
            content: const Text(
              "You must accept the privacy policy to continue. Go back?",
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text("Stay"),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text("Go Back"),
              ),
            ],
          ),
        );

        if (shouldPop == true) {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,

        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          centerTitle: true,
          title: Text(
            "Privacy Policy",
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              /// HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.privacy_tip, color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      "Your Privacy Matters",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "We are committed to protecting your data",
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              /// SECTIONS
              section(
                context,
                "1. Data Collection",
                "We may collect user data such as name, email, and profile image.",
              ),
              section(
                context,
                "2. Usage",
                "Data is used to improve your app experience and personalize features.",
              ),
              section(
                context,
                "3. Storage",
                "Your data is securely stored using Firebase services.",
              ),
              section(
                context,
                "4. Third-party Services",
                "We use Cloudinary for image uploads and external services.",
              ),
              section(
                context,
                "5. Security",
                "We take appropriate measures to protect your personal data.",
              ),
              section(
                context,
                "6. Contact",
                "For any questions or concerns, please contact support.",
              ),

              const SizedBox(height: 20),

              /// 🔥 SHOW ONLY IF NOT FROM PROFILE
              if (!fromProfile) ...[
                /// ACCEPT CHECKBOX
                Row(
                  children: [
                    Checkbox(
                      value: isAccepted,
                      onChanged: (value) {
                        setState(() {
                          isAccepted = value!;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "I agree to the Privacy Policy",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// FINAL BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isAccepted
                        ? () async {
                      final controller = Get.find<AuthController>();

                      if (isGoogleUser) {
                        final user = data["user"];
                        if (user == null) return;

                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(user.uid)
                            .set({
                          "name": user.displayName ?? "",
                          "email": user.email ?? "",
                          "photoUrl": user.photoURL ?? "",
                          "createdAt": FieldValue.serverTimestamp(),
                          "lastLogin": FieldValue.serverTimestamp(),
                          "acceptedPolicy": true,
                        });

                        Get.snackbar("Success", "Account Created");
                        Get.offAll(() => const TodoListScreen());
                      } else {
                        controller.register(
                          data["name"],
                          data["email"],
                          data["password"],
                        );
                      }
                    }
                        : null,
                    child: const Text(
                      "Accept & Register",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget section(BuildContext context, String title, String content) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}