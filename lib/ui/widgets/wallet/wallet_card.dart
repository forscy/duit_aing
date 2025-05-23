import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Card untuk menampilkan dompet
class WalletCard extends ConsumerWidget {
  final WalletModel wallet;

  const WalletCard({Key? key, required this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          context.push('/wallet/${wallet.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      wallet.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildVisibilityIcon(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Rp${_formatNumber(wallet.balance)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (wallet.visibility == WalletVisibility.shared) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Dibagikan dengan ${wallet.sharedWith.length} orang',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityIcon() {
    switch (wallet.visibility) {
      case WalletVisibility.private:
        return const Icon(Icons.lock, size: 16, color: Colors.grey);
      case WalletVisibility.shared:
        return const Icon(Icons.people, size: 16, color: Colors.grey);
    }
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), '');
  }
}
