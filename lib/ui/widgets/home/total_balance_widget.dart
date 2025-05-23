import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/wallet.dart';
import '../../../providers/wallet_provider.dart';
import '../../../utils/currency_formatter.dart';

/// Widget untuk menampilkan total saldo dari semua wallet
class TotalBalanceWidget extends ConsumerWidget {
  const TotalBalanceWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletListProvider);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Saldo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            walletsAsync.when(
              data: (wallets) {
                final totalBalance = _calculateTotalBalance(wallets);
                return Text(
                  CurrencyFormatter.format(totalBalance),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 24,
                child: Center(
                  child: LinearProgressIndicator(),
                ),
              ),
              error: (error, stackTrace) => Text(
                'Error: ${error.toString()}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 8),
            walletsAsync.when(
              data: (wallets) => Text(
                'Dari ${wallets.length} dompet',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  /// Menghitung total saldo dari semua wallet
  double _calculateTotalBalance(List<WalletModel> wallets) {
    return wallets.fold(0.0, (sum, wallet) => sum + wallet.balance);
  }
}
