import 'package:flutter/material.dart';
import 'package:duit_aing/models/wallet.dart';
import 'package:duit_aing/utils/currency_formatter.dart';
import 'package:duit_aing/models/enums.dart';

class WalletHeader extends StatelessWidget {
  final WalletModel wallet;

  const WalletHeader({
    Key? key,
    required this.wallet,
  }) : super(key: key);
  @override 
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              wallet.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(wallet.balance),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  wallet.visibility == WalletVisibility.private
                      ? Icons.lock
                      : Icons.people,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  wallet.visibility == WalletVisibility.private
                      ? 'Dompet Pribadi'
                      : 'Dompet Bersama',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
