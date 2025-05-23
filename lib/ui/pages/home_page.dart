import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sign_out_button.dart';
import '../widgets/home/user_greeting_widget.dart';
import '../widgets/home/total_balance_widget.dart';
import '../widgets/home/feature_grid_widget.dart';
import '../widgets/home/recent_transactions_widget.dart';

/// Halaman utama aplikasi
class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duit Aing'),
        actions: const [
          SignOutButton(buttonType: SignOutButtonType.icon),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            UserGreetingWidget(),
            SizedBox(height: 16),
            TotalBalanceWidget(),
            SizedBox(height: 24),
            FeatureGridWidget(),
            SizedBox(height: 24),
            RecentTransactionsWidget(),
          ],
        ),
      ),
    );
  }
}