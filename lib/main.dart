import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/login_page.dart';
import 'screens/profile_page.dart';
import 'screens/splash_screen.dart';
import 'screens/todo_list.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // 🌞 Light Theme
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB388FF),// 🔥 modern premium color
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: const Color(0xFFF8FAFC),

        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB388FF),
          brightness: Brightness.dark,
        ),

        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),

      // 📱 System default theme
      themeMode: ThemeMode.system,

      home: const SplashScreen(),
      getPages: [
        GetPage(name: "/login", page: () => LoginPage()),
        GetPage(name: "/profile", page: () => ProfilePage()),
        GetPage(name: "/todo", page: () => const TodoListScreen()),
      ],
    );
  }
}