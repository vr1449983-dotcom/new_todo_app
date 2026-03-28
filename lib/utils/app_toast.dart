import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showToast({
  required String title,
  required String message,
  Color bgColor = Colors.black87,
  IconData icon = Icons.info_outline,
}) {
  Get.showSnackbar(
    GetSnackBar(
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      backgroundColor: bgColor,
      duration: const Duration(seconds: 2),

      messageText: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 2),
                Text(message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    )),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}