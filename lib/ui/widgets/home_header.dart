import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class HomeHeader extends StatelessWidget {
  final AuthController authController;

  const HomeHeader({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 5),
              Obx(() => Text(
                    authController.appUser?.displayName ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
            ],
          ),
          GestureDetector(
            onTap: () {
              // Navigate to profile page
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
