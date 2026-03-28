import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../controller/profile_controller.dart';

class AccountInfoPage extends StatelessWidget {
  AccountInfoPage({super.key});

  final controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: const Text("Account Info"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// PROFILE CARD
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

                  child: Obx(() => Column(
                    children: [

                      /// PHOTO
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                        theme.colorScheme.primaryContainer,
                        child: controller.photoUrl.value.isNotEmpty
                            ? ClipOval(
                          child: Image.network(
                            controller.photoUrl.value,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.person,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// NAME
                      Text(
                        controller.name.value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      /// EMAIL
                      Text(
                        controller.email.value,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// EMAIL STATUS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            controller.isEmailVerified.value
                                ? Icons.verified
                                : Icons.error_outline,
                            color: controller.isEmailVerified.value
                                ? Colors.green
                                : Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            controller.isEmailVerified.value
                                ? "Email Verified"
                                : "Not Verified",
                          )
                        ],
                      ),

                      const SizedBox(height: 10),

                      /// REFRESH EMAIL STATUS
                      TextButton(
                        onPressed: controller.refreshEmailVerification,
                        child: const Text("Refresh Status"),
                      ),
                    ],
                  )),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// INFO TILES
            infoTile(context, "User ID", controller.uid.value, copy: true),
            infoTile(context, "Created At", controller.createdAt.value),
            infoTile(context, "Last Login", controller.lastLogin.value),

            const SizedBox(height: 20),

            /// VERIFY EMAIL BUTTON
            Obx(() => controller.isEmailVerified.value
                ? const SizedBox()
                : ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();

                Get.snackbar(
                    "Verification Sent",
                    "Check your email");
              },
              child: const Text("Verify Email"),
            )),
          ],
        ),
      ),
    );
  }

  /// INFO TILE
  Widget infoTile(
      BuildContext context,
      String title,
      String value, {
        bool copy = false,
      }) {

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
            ),

            child: Row(
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value.isEmpty ? "-" : value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                if (copy)
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: value),
                      );
                      Get.snackbar("Copied", "User ID copied");
                    },
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}