import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../utils/currency_formatter.dart';

class BalanceCard extends StatelessWidget {
  final AuthController authController;

  const BalanceCard({
    Key? key,
    required this.authController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B8B), // Pink
            Color(0xFFFF8E53), // Orange
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                authController.appUser?.displayName?.toUpperCase() ?? 'USER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Image.asset(
                'assets/images/logo.png',  // Pastikan logo ada, atau gunakan Icon
                width: 60,
                height: 20,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.credit_card, color: Colors.white);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  '••••',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          GetX<WalletController>(
            builder: (controller) => Text(
              'Rp${CurrencyFormatter.format(controller.totalBalance)}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
