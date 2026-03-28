import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_todo_app/screens/login_page.dart';
import 'package:new_todo_app/screens/todo_list.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() {

    Future.delayed(const Duration(seconds: 2), () {

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User already logged in
        Get.offAll(() => const TodoListScreen());
      } else {
        // User not logged in
        Get.offAll(() => const LoginPage());
      }

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Image.asset(
          Assets.splashlogo,
          height: 250,
        ),
      ),
    );

  }
}