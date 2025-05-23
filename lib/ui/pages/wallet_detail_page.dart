import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/transaction.dart' as model;
import 'package:duit_aing/models/wallet.dart';
import 'package:duit_aing/providers/transaction_provider.dart';
import 'package:duit_aing/providers/wallet_provider.dart';
import 'package:duit_aing/utils/currency_formatter.dart';
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
                    _showInviteDialog(context, ref, wallet);
                  },
                  onEditPressed: (context, ref) {
                    _showEditWalletDialog(context, ref, wallet);
                  },
                  onDeletePressed: (context, ref) {
                    _showDeleteConfirmation(context, ref, wallet);
                  },
                ),
                const SizedBox(height: 24),
                TransactionsList(
                  walletId: walletId,
                  onTransactionLongPress: (context, ref, transaction) {
                    _showTransactionActions(context, ref, transaction);
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
                      if (wallet != null) {
                        _showEditWalletDialog(context, ref, wallet);
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
                      if (wallet != null) {
                        _showDeleteConfirmation(context, ref, wallet);
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

  void _showTransactionActions(BuildContext context, WidgetRef ref, model.TransactionModel transaction) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(transaction.isActive ? 'Batalkan Transaksi' : 'Aktifkan Transaksi'),
          content: Text(
            transaction.isActive 
              ? 'Anda yakin ingin membatalkan transaksi ini?\nTindakan ini akan mengubah saldo dompet.'
              : 'Anda yakin ingin mengaktifkan kembali transaksi ini?\nTindakan ini akan mengubah saldo dompet.'
          ),
          actions: [
            TextButton(
              child: const Text('Tidak'),
              onPressed: () => context.pop(false),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: transaction.isActive ? Colors.red : Colors.green,
              ),
              child: Text(transaction.isActive ? 'Ya, Batalkan' : 'Ya, Aktifkan'),
              onPressed: () => context.pop(true),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      try {
        if (transaction.isActive) {
          await ref.read(transactionNotifierProvider.notifier)
                   .cancelTransaction(transaction);
                   
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaksi berhasil dibatalkan')),
            );
          }
        } else {
          await ref.read(transactionNotifierProvider.notifier)
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

  void _showEditWalletDialog(BuildContext context, WidgetRef ref, WalletModel wallet) {
    final nameController = TextEditingController(text: wallet.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Dompet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Dompet',
                ),
              ),
            ],
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
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nama dompet tidak boleh kosong'),
                              ),
                            );
                            return;
                          }

                          try {
                            final updatedWallet = wallet.copyWith(
                              name: nameController.text.trim(),
                            );

                            await ref.read(walletNotifierProvider.notifier)
                                .updateWallet(updatedWallet);
                            
                            if (context.mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Dompet berhasil diperbarui'),
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
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, WalletModel wallet) {
    showDialog(
      context: context,
      builder: (context) {
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
                            await ref.read(walletNotifierProvider.notifier)
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
      },
    );
  }

  void _showInviteDialog(BuildContext context, WidgetRef ref, WalletModel wallet) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Undang Pengguna'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
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
                          final email = emailController.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email tidak valid'),
                              ),
                            );
                            return;
                          }

                          if (wallet.sharedWith.contains(email)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pengguna sudah memiliki akses ke dompet ini'),
                              ),
                            );
                            return;
                          }

                          if (wallet.invitations.any((invitation) =>
                              invitation.email == email &&
                              invitation.status == InvitationStatus.pending)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Undangan sudah dikirim ke email ini'),
                              ),
                            );
                            return;
                          }

                          try {
                            await ref.read(walletNotifierProvider.notifier)
                                .inviteToWallet(wallet.id, email);

                            if (context.mounted) {
                              context.pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Undangan berhasil dikirim'),
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
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Undang'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
