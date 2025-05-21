import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../widgets/balance_card.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_actions_menu.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/wallet_list.dart';
import '../widgets/dialogs.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final walletController = Get.find<WalletController>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(authController: authController),
              const SizedBox(height: 20),
              BalanceCard(authController: authController),
              const SizedBox(height: 20),
              const QuickActionsMenu(),
              const SizedBox(height: 20),
              const RecentTransactionsList(),
              const SizedBox(height: 20),
              WalletList(controller: walletController),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Get.bottomSheet(
          AddOptionsBottomSheet(
            onAddWallet: () => Get.dialog(const AddWalletDialog()),
            onAddTransaction: () {
              // TODO: Implement add transaction dialog
            },
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ),
    );
  }
}
