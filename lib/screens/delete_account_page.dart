import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/delete_account_controller.dart';

class DeleteAccountPage extends StatefulWidget {
  DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final controller = Get.put(DeleteAccountController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Delete Account"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "⚠️ Danger Zone",
              style: TextStyle(
                color: Colors.red,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Your account will be soft deleted.\n"
                  "You can restore within 7 days.\n\n"
                  "A backup will be created automatically.",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 30),

            _buildButton(
              "Delete with Google",
              Icons.g_mobiledata,
              Colors.red,
                  () => controller.startDeleteFlow("google"),
            ),

            const SizedBox(height: 10),

            _buildButton(
              "Delete with Apple",
              Icons.apple,
              Colors.grey,
                  () => controller.startDeleteFlow("apple"),
            ),

            const SizedBox(height: 30),

            Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(text, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}