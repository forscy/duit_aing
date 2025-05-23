import 'package:duit_aing/models/wallet.dart';
import 'package:duit_aing/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DeleteWalletDialog extends ConsumerWidget {
  final WalletModel wallet;

  const DeleteWalletDialog({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Hapus Dompet'),
      content: Text(
        'Apakah Anda yakin ingin menghapus dompet "${wallet.name}"? '
        'Semua data dan transaksi di dalamnya akan dihapus permanen.',
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Batal'),
        ),
        Consumer(
          builder: (context, ref, _) {
            final walletState = ref.watch(walletNotifierProvider);
            final isLoading = walletState is AsyncLoading;

            return FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      try {
                        await ref
                            .read(walletNotifierProvider.notifier)
                            .deleteWallet(wallet.id);

                        if (context.mounted) {
                          context.pop(); // Close the dialog
                          context.push('/wallet'); // Navigate back to wallet list
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Dompet berhasil dihapus'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                            ),
                          );
                        }
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Hapus'),
            );
          },
        ),
      ],
    );
  }
}
