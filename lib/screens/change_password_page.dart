import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/change_password_controller.dart';
import 'forgot_password_page.dart';

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(ChangePasswordController());
    final theme = Theme.of(context);

    /// 👁️ VISIBILITY STATES
    final isOldVisible = false.obs;
    final isNewVisible = false.obs;
    final isConfirmVisible = false.obs;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: const Text("Change Password"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            const SizedBox(height: 20),

            /// 🔥 GLASS CARD
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
                    children: [

                      /// CURRENT PASSWORD
                      Obx(() => TextField(
                        obscureText: !isOldVisible.value,
                        decoration: InputDecoration(
                          labelText: "Current Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isOldVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                            isOldVisible.value = !isOldVisible.value,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onChanged: (v) =>
                        controller.oldPass.value = v,
                      )),

                      const SizedBox(height: 15),

                      /// NEW PASSWORD
                      Obx(() => TextField(
                        obscureText: !isNewVisible.value,
                        decoration: InputDecoration(
                          labelText: "New Password",
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isNewVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                            isNewVisible.value = !isNewVisible.value,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onChanged: (v) =>
                        controller.newPass.value = v,
                      )),

                      const SizedBox(height: 15),

                      /// CONFIRM PASSWORD
                      Obx(() => TextField(
                        obscureText: !isConfirmVisible.value,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          prefixIcon: const Icon(Icons.lock_reset),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isConfirmVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () =>
                            isConfirmVisible.value =
                            !isConfirmVisible.value,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onChanged: (v) =>
                        controller.confirmPass.value = v,
                      )),

                      const SizedBox(height: 25),

                      /// UPDATE BUTTON
                      Obx(() => SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.updatePassword,

                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          child: controller.isLoading.value
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            "Update Password",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )),

                      const SizedBox(height: 12),

                      /// FORGOT PASSWORD
                      TextButton(
                        onPressed: () {
                          Get.to(() => const ForgotPasswordPage());
                        },
                        child: const Text("Forgot Password?"),
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