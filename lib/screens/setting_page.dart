import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/settings_controller.dart';
import '../model/sync_mod.dart';
import '../services/sync_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}
final SettingsController controller = Get.put(SettingsController());

class _SettingsPageState extends State<SettingsPage> {

  ThemeMode currentTheme =
  Get.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void changeTheme(ThemeMode mode) {
    setState(() {
      currentTheme = mode;
      Get.changeThemeMode(mode);
    });
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// HEADER
            Text(
              "Appearance",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Choose how the app looks on your device.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            /// THEME OPTIONS
            glassOption(
              icon: Icons.light_mode,
              title: "Light Theme",
              subtitle: "Bright and clear interface",
              selected: currentTheme == ThemeMode.light,
              onTap: () => changeTheme(ThemeMode.light),
            ),

            glassOption(
              icon: Icons.dark_mode,
              title: "Dark Theme",
              subtitle: "Comfortable for night use",
              selected: currentTheme == ThemeMode.dark,
              onTap: () => changeTheme(ThemeMode.dark),
            ),

            glassOption(
              icon: Icons.phone_android,
              title: "System Default",
              subtitle: "Follow device appearance",
              selected: currentTheme == ThemeMode.system,
              onTap: () => changeTheme(ThemeMode.system),
            ),

            const SizedBox(height: 20),

            /// SYNC MODE SECTION
        /// SYNC MODE SECTION (UPDATED)
        const SizedBox(height: 20),

        Text(
          "Cloud Sync",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Manage how your data syncs with cloud.",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 12),

        Obx(() => ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(.7),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: ExpansionTile(
                initiallyExpanded: true,
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.cloud_sync,
                    color: theme.colorScheme.primary,
                  ),
                ),
                title: const Text(
                  "Sync Mode",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  controller.syncMode.value.name.capitalizeFirst!,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                children: [

                  RadioListTile(
                    title: const Text("Off"),
                    subtitle: const Text("Disable cloud sync"),
                    value: SyncMode.off,
                    groupValue: controller.syncMode.value,
                    onChanged: (value) =>
                        controller.changeSyncMode(value!),
                  ),

                  RadioListTile(
                    title: const Text("Manual"),
                    subtitle: const Text("Sync only when you tap button"),
                    value: SyncMode.manual,
                    groupValue: controller.syncMode.value,
                    onChanged: (value) =>
                        controller.changeSyncMode(value!),
                  ),

                  RadioListTile(
                    title: const Text("Automatic"),
                    subtitle: const Text("Sync in background automatically"),
                    value: SyncMode.automatic,
                    groupValue: controller.syncMode.value,
                    onChanged: (value) =>
                        controller.changeSyncMode(value!),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.sync),
                        label: const Text("Sync Now"),
                        onPressed: () async {
                          if (controller.syncMode.value ==
                              SyncMode.off) {
                            Get.snackbar(
                                "Sync Disabled", "Enable sync first");
                            return;
                          }

                          await SyncService.syncTodos();

                          Get.snackbar("Success", "Data synced");
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        )),
        ],
      )

      ),
    );
  }

  /// MODERN GLASS OPTION TILE
  Widget glassOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 40.0, end: 0.0),

        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(value, 0),
            child: child,
          );
        },

        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),

          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

            child: InkWell(
              onTap: onTap,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),

                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(.7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                ),

                child: Row(
                  children: [

                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        icon,
                        color: theme.colorScheme.primary,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                          width: 2,
                        ),
                        color: selected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                      ),

                      child: selected
                          ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                          : null,
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}