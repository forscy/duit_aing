import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/transaction.dart' as model;
import 'package:duit_aing/models/wallet.dart';
import 'package:duit_aing/providers/transaction_provider.dart';
import 'package:duit_aing/providers/wallet_provider.dart';
import 'package:duit_aing/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Halaman untuk menampilkan detail wallet
class WalletDetailPage extends ConsumerWidget {
  final String walletId;

  const WalletDetailPage({
    Key? key,
    required this.walletId,
  }) : super(key: key);  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gunakan provider yang autoinvalidate ketika wallet berubah 
    // Dapatkan data wallet dengan watch untuk memastikan UI diupdate ketika data berubah
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
      ),      body: walletAsync.when(
        data: (wallet) {
          if (wallet == null) {
            return const Center(
              child: Text('Dompet tidak ditemukan'),
            );
          }          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWalletHeader(context, wallet),
                const SizedBox(height: 24),
                _buildActions(context, ref, wallet),
                const SizedBox(height: 24),
                _buildTransactionList(context, ref, wallet.id),
                const SizedBox(height: 24),
                if (wallet.visibility == WalletVisibility.shared)
                  _buildSharedWithSection(context, wallet),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add transaction page
          context.push('/wallet/${walletId}/add-transaction');
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Transaksi',
      ),
    );
  }

  Widget _buildWalletHeader(BuildContext context, WalletModel wallet) {
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

  Widget _buildActions(BuildContext context, WidgetRef ref, WalletModel wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tindakan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [            _buildActionItem(
              context,
              Icons.add_circle,
              'Pemasukan',
              () {
                // Navigate to add transaction page with income type pre-selected
                context.push('/wallet/${wallet.id}/add-transaction?type=income');
              },
            ),
            _buildActionItem(
              context,
              Icons.remove_circle,
              'Pengeluaran',
              () {
                // Navigate to add transaction page with expense type pre-selected
                context.push('/wallet/${wallet.id}/add-transaction?type=expense');
              },
            ),
            _buildActionItem(
              context,
              Icons.swap_horiz,
              'Transfer',
              () {
                // Navigate to add transaction page with transfer type pre-selected
                context.push('/wallet/${wallet.id}/add-transaction?type=transfer');
              },
            ),
            if (wallet.visibility == WalletVisibility.shared)
              _buildActionItem(
                context,
                Icons.person_add,
                'Undang',
                () => _showInviteDialog(context, ref, wallet),
              ),
            _buildActionItem(
              context,
              Icons.edit,
              'Edit',
              () => _showEditWalletDialog(context, ref, wallet),
            ),
            _buildActionItem(
              context,
              Icons.delete,
              'Hapus',
              () => _showDeleteConfirmation(context, ref, wallet),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedWithSection(BuildContext context, WalletModel wallet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dibagikan dengan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: wallet.sharedWith.length,
            itemBuilder: (context, index) {
              final email = wallet.sharedWith[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(email),
                subtitle: index == 0 ? const Text('Pemilik') : null,
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (wallet.invitations.isNotEmpty) ...[
          const Text(
            'Undangan Tertunda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wallet.invitations.length,
              itemBuilder: (context, index) {
                final invitation = wallet.invitations[index];
                if (invitation.status != InvitationStatus.pending) {
                  return const SizedBox.shrink();
                }
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.email),
                  ),
                  title: Text(invitation.email),
                  subtitle: const Text('Menunggu konfirmasi'),
                );
              },
            ),
          ),
        ],
      ],
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
                  context.pop(); // Close the bottom sheet                  // Gunakan future untuk operasi one-time ini
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
                  context.pop(); // Close the bottom sheet                  // Gunakan future untuk operasi one-time ini
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
  void _showEditWalletDialog(
    BuildContext context,
    WidgetRef ref,
    WalletModel wallet,
  ) {
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
                                content:
                                    Text('Nama dompet tidak boleh kosong'),
                              ),
                            );
                            return;
                          }

                          try {
                            final updatedWallet = wallet.copyWith(
                              name: nameController.text.trim(),
                            );                            await ref
                                .read(walletNotifierProvider.notifier)
                                .updateWallet(updatedWallet);
                            
                            // Tidak perlu invalidasi manual lagi karena menggunakan StreamProvider
                            // yang akan otomatis update ketika data berubah di Firestore
                            
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
  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    WalletModel wallet,
  ) {
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
                            await ref
                                .read(walletNotifierProvider.notifier)
                                .deleteWallet(wallet.id);                            if (context.mounted) {
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
  void _showInviteDialog(
    BuildContext context,
    WidgetRef ref,
    WalletModel wallet,
  ) {
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
                                content: Text(
                                  'Pengguna sudah memiliki akses ke dompet ini',
                                ),
                              ),
                            );
                            return;
                          }

                          if (wallet.invitations.any((invitation) =>
                              invitation.email == email &&
                              invitation.status ==
                                  InvitationStatus.pending)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Undangan sudah dikirim ke email ini',
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            await ref
                                .read(walletNotifierProvider.notifier)
                                .inviteToWallet(wallet.id, email);                            if (context.mounted) {
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

  Widget _buildTransactionList(BuildContext context, WidgetRef ref, String walletId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Watch transaction stream for this wallet
        Consumer(
          builder: (context, ref, child) {
            final transactionsAsync = ref.watch(walletTransactionsProvider(walletId));
            
            return transactionsAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Belum ada transaksi',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }
                
                return Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return _buildTransactionItem(context, ref, transaction);
                    },
                  ),
                );
              },
              loading: () => const Card(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text('Error: ${error.toString()}'),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(BuildContext context, WidgetRef ref, model.TransactionModel transaction) {
    // Determine icon and color based on transaction type
    IconData icon = Icons.circle; // Default value
    Color color = Colors.grey; // Default value
    String typeText = ''; // Default value
    
    switch (transaction.type) {
      case TransactionType.income:
        icon = Icons.add_circle;
        color = Colors.green;
        typeText = 'Pemasukan';
        break;
      case TransactionType.expense:
        icon = Icons.remove_circle;
        color = Colors.red;
        typeText = 'Pengeluaran';
        break;
      case TransactionType.transfer:
        icon = Icons.swap_horiz;
        color = Colors.blue;
        typeText = 'Transfer';
        break;
    }
    
    // Format date
    final date = transaction.timestamp.toDate();
    final formattedDate = 
        '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return ListTile(
      onLongPress: () async {
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
      },
      leading: CircleAvatar(
        backgroundColor: transaction.isActive 
            ? color.withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        child: Icon(
          icon, 
          color: transaction.isActive ? color : Colors.grey,
        ),
      ),
      title: Text(
        transaction.description,
        style: !transaction.isActive 
            ? const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              )
            : null,
      ),
      subtitle: Row(
        children: [
          Text('$typeText • $formattedDate'),
          if (!transaction.isActive) ...[
            const SizedBox(width: 4),
            const Text(
              '• Dibatalkan',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ],
      ),
      trailing: Text(
        CurrencyFormatter.format(transaction.amount),
        style: TextStyle(
          color: !transaction.isActive 
              ? Colors.grey
              : transaction.type == TransactionType.expense 
                  ? Colors.red 
                  : transaction.type == TransactionType.income 
                      ? Colors.green 
                      : Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
