import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'auth/login_page.dart';
import 'home/home_page.dart';

/// This widget handles the authentication state and decides which screen to show
class AuthRoot extends StatelessWidget {
  const AuthRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Obx(() {
      if (authController.isLoading.value) {
        // Show loading screen while checking auth state
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else if (authController.isLoggedIn) {
        // User is logged in, show home page
        return const HomePage();
      } else {
        // User is not logged in, show login page
        return LoginPage();
      }
    });
  }
}
