import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_todo_app/screens/account_info_page.dart';
import 'package:new_todo_app/screens/delete_account_page.dart';
import 'package:new_todo_app/screens/export_data_page.dart';
import '../controller/profile_controller.dart';
import 'change_password_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: const Text("Account"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// USER INFO CARD
            ClipRRect(
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
                  child: Obx(() => Row(
                    children: [

                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                        theme.colorScheme.primaryContainer,
                        child: controller.photoUrl.value.isNotEmpty
                            ? ClipOval(
                          child: Image.network(
                            controller.photoUrl.value,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Icon(
                          Icons.person,
                          size: 30,
                          color: theme.colorScheme.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.name.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            controller.email.value,
                            style: TextStyle(
                              color: theme.colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ACCOUNT OPTIONS
            glassTile(
              context,
              Icons.lock,
              "Change Password",
                  () => Get.to(() => const ChangePasswordPage()),
            ),



            glassTile(
              context,
              Icons.info_outline,
              "Account Info",
                  () =>Get.to(() => AccountInfoPage()),
            ),

            glassTile(
              context,
              Icons.download,
              "Export Data",
                  () =>Get.to(() => ExportDataPage()),
            ),

            const SizedBox(height: 20),

            /// DELETE ACCOUNT (DANGER)
            glassTile(
              context,
              Icons.delete_forever,
              "Delete Account",
                  () =>Get.to(() => DeleteAccountPage()),
            ),
          ],
        ),
      ),
    );
  }

  /// REUSABLE GLASS TILE
  Widget glassTile(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool isDanger = false,
      }) {

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),

        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
              ),
            ),

            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isDanger
                    ? theme.colorScheme.errorContainer
                    : theme.colorScheme.primaryContainer,

                child: Icon(
                  icon,
                  color: isDanger
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
              ),

              title: Text(title),

              trailing: const Icon(Icons.chevron_right),

              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}