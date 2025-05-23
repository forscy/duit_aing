import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/transaction.dart';
import 'package:duit_aing/models/wallet.dart';
import 'package:duit_aing/providers/transaction_provider.dart';
import 'package:duit_aing/providers/wallet_provider.dart';
import 'package:duit_aing/ui/widgets/wallet/delete_wallet_dialog.dart';
import 'package:duit_aing/ui/widgets/wallet/edit_wallet_dialog.dart';
import 'package:duit_aing/ui/widgets/wallet/invite_user_dialog.dart';
import 'package:duit_aing/ui/widgets/wallet/transaction_actions_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/wallet/wallet_header.dart';
import '../widgets/wallet/wallet_action_buttons.dart';
import '../widgets/wallet/transactions_list.dart';
import '../widgets/wallet/shared_with_section.dart';

/// Halaman untuk menampilkan detail wallet
class WalletDetailPage extends ConsumerWidget {
  final String walletId;

  const WalletDetailPage({
    Key? key,
    required this.walletId,
  }) : super(key: key);

  @override 
  Widget build(BuildContext context, WidgetRef ref) {
    final walletAsync = ref.watch(selectedWalletProvider(walletId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Dompet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showWalletOptions(context, ref),
          ),
        ],
      ),
      body: walletAsync.when(
        data: (wallet) {
          if (wallet == null) {
            return const Center(
              child: Text('Dompet tidak ditemukan'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WalletHeader(wallet: wallet),
                const SizedBox(height: 24),
                WalletActionButtons(
                  walletId: walletId,
                  wallet: wallet,
                  onInvitePressed: (context, ref) {
                    showDialog(
                      context: context,
                      builder: (context) => InviteUserDialog(wallet: wallet),
                    );
                  },
                  onEditPressed: (context, ref) {
                    showDialog(
                      context: context,
                      builder: (context) => EditWalletDialog(wallet: wallet),
                    );
                  },
                  onDeletePressed: (context, ref) {
                    showDialog(
                      context: context,
                      builder: (context) => DeleteWalletDialog(wallet: wallet),
                    );
                  },
                ),
                const SizedBox(height: 24),
                TransactionsList(
                  walletId: walletId,
                  onTransactionLongPress: (context, ref, transaction) {
                    _handleTransactionAction(context, ref, transaction);
                  },
                ),
                const SizedBox(height: 24),
                if (wallet.visibility == WalletVisibility.shared)
                  SharedWithSection(wallet: wallet),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/wallet/${walletId}/add-transaction'),
        child: const Icon(Icons.add),
        tooltip: 'Tambah Transaksi',
      ),
    );
  }

  void _showWalletOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Dompet'),
                onTap: () {
                  context.pop(); // Close the bottom sheet
                  ref.read(selectedWalletProvider(walletId).future).then(
                    (wallet) {
                      if (wallet != null && context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => EditWalletDialog(wallet: wallet),
                        );
                      }
                    },
                    onError: (error) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${error.toString()}')),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Hapus Dompet'),
                onTap: () {
                  context.pop(); // Close the bottom sheet
                  ref.read(selectedWalletProvider(walletId).future).then(
                    (wallet) {
                      if (wallet != null && context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => DeleteWalletDialog(wallet: wallet),
                        );
                      }
                    },
                    onError: (error) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${error.toString()}')),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleTransactionAction(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TransactionActionsDialog(transaction: transaction),
    );

    if (result == true && context.mounted) {
      try {
        if (transaction.isActive) {
          await ref
              .read(transactionNotifierProvider.notifier)
              .cancelTransaction(transaction);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaksi berhasil dibatalkan')),
            );
          }
        } else {
          await ref
              .read(transactionNotifierProvider.notifier)
              .reactivateTransaction(transaction);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaksi berhasil diaktifkan kembali')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }
}
