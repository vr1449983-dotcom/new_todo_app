import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';
import '../db/feedback_firestore_service.dart';

class HelpFeedbackController extends GetxController {
  final ProfileController profileController;

  HelpFeedbackController({required this.profileController});

  late final TextEditingController messageController;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    messageController = TextEditingController();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  Future<void> submitFeedback() async {
    final msg = messageController.text.trim();

    if (msg.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your message",
        backgroundColor: const Color(0xFFB00020),
        colorText: Colors.white,
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    final userUid = profileController.uid.value.isNotEmpty
        ? profileController.uid.value
        : (currentUser?.uid ?? '');

    if (userUid.isEmpty) {
      Get.snackbar(
        "Error",
        "User UID not found",
        backgroundColor: const Color(0xFFB00020),
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      await FeedbackFirestoreService.addFeedback(
        uid: userUid,
        name: profileController.name.value,
        email: profileController.email.value,
        message: msg,
      );

      messageController.clear();

      Get.snackbar(
        "Success",
        "Feedback submitted",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to submit feedback",
        backgroundColor: const Color(0xFFB00020),
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}