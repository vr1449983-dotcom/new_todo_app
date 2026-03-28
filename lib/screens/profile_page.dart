import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_todo_app/screens/help_feedback_page.dart';
import 'package:new_todo_app/screens/privacy_policy_page.dart';
import 'package:new_todo_app/screens/recently_deleted_page.dart';
import 'package:new_todo_app/screens/setting_page.dart';
import '../controller/profile_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'account_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  /// PHOTO OPTIONS
  void showPhotoOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            ListTile(
              leading: Icon(Icons.photo_camera,
                  color: Get.theme.colorScheme.primary),
              title: const Text("Update Profile Photo"),
              onTap: () {
                Get.back();
                controller.pickImage();
              },
            ),

            if (controller.photoUrl.value.isNotEmpty)
              ListTile(
                leading: Icon(Icons.delete,
                    color: Get.theme.colorScheme.error),
                title: const Text("Remove Profile Photo"),
                onTap: () {
                  Get.back();
                  controller.removePhoto();
                },
              ),

            ListTile(
              leading: const Icon(Icons.close),
              title: const Text("Cancel"),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  void showImagePreview() {
    if (controller.photoUrl.value.isEmpty) return;

    Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: "Preview",
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return GestureDetector(
          onTap: () => Get.back(), // tap outside close
          child: SafeArea(
            child: Center(
              child: Dismissible(
                key: const Key("imagePreview"),
                direction: DismissDirection.vertical,
                onDismissed: (_) => Get.back(),
                child: Hero(
                  tag: "profile_avatar",
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: CachedNetworkImage(
                      imageUrl: controller.photoUrl.value,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// PREMIUM LOGOUT DIALOG
  void showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Icon(
                Icons.logout,
                size: 45,
                color: Get.theme.colorScheme.error,
              ),

              const SizedBox(height: 15),

              const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Get.theme.colorScheme.error,
                      ),
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      body: CustomScrollView(
        slivers: [

          /// COLLAPSIBLE HEADER
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            elevation: 0,

            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),

            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,

              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const SizedBox(height: 40),

                    /// AVATAR
                    Obx(() => GestureDetector(
                      onTap: showPhotoOptions,
                      onLongPress: showImagePreview,
                      child: Hero(
                        tag: "profile_avatar",
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: controller.photoUrl.value.isNotEmpty
                                  ? CachedNetworkImage(
                                imageUrl: controller.photoUrl.value,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                                  : Icon(
                                Icons.person,
                                size: 60,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),

                    const SizedBox(height: 12),

                    /// NAME + EDIT BUTTON
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text(
                          controller.name.value,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 6),

                        GestureDetector(
                          onTap: () {

                            TextEditingController nameController =
                            TextEditingController(
                                text: controller.name.value);

                            Get.defaultDialog(
                              title: "Edit Name",
                              content: TextField(
                                controller: nameController,
                                decoration: const InputDecoration(
                                  hintText: "Enter new name",
                                ),
                              ),
                              textConfirm: "Update",
                              textCancel: "Cancel",
                              onConfirm: () {
                                controller.updateName(
                                    nameController.text.trim());
                                Get.back();
                              },
                            );
                          },

                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white24,
                            child: Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    )),

                    const SizedBox(height: 5),

                    /// EMAIL
                    Obx(() => Text(
                      controller.email.value,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),

          /// SETTINGS AREA
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [

                  glassTile(
                    context,
                    Icons.person_outline,
                    "Account",
                        () => Get.to(() => const AccountPage()),
                  ),

                  glassTile(
                    context,
                    Icons.settings,
                    "Settings",
                        () => Get.to(() =>  SettingsPage()),
                  ),

                  glassTile(
                    context,
                    Icons.help_outline,
                    "Help & Feedback",
                        () => Get.to(() =>  HelpFeedbackPage()),
                  ),

                  glassTile(
                    context,
                    Icons.delete_outline,
                    "Recently Deleted",
                        () => Get.to(() => const RecentlyDeletedPage()),
                  ),

                  glassTile(
                    context,
                    Icons.privacy_tip,
                    "Privacy Policy",
                        () => Get.to(
                          () => const PrivacyPolicyPage(),
                      arguments: {
                        "fromProfile": true,
                      },
                    ),
                  ),

                  glassTile(
                    context,
                    Icons.logout,
                    "Logout",
                    showLogoutDialog,
                    isDanger: true,
                  ),


                  const SizedBox(height: 40),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// GLASS TILE
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

      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 40.0, end: 0.0),

        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(value, 0),
            child: child,
          );
        },

        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),

          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),

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

                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),

                onTap: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}