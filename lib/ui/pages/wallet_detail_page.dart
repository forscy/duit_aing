import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/wallet.dart';
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
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Make sure wallet state is reset when needed
    ref.watch(walletResetProvider);
    
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
                _buildWalletHeader(context, wallet),
                const SizedBox(height: 24),
                _buildActions(context, ref, wallet),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add transaction page (Implementation to be added)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tambah transaksi akan diimplementasikan')),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Transaksi',
      ),
    );
  }

  Widget _buildWalletHeader(BuildContext context, Wallet wallet) {
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

  Widget _buildActions(BuildContext context, WidgetRef ref, Wallet wallet) {
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
          children: [
            _buildActionItem(
              context,
              Icons.add_circle,
              'Top Up',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Top Up akan diimplementasikan')),
                );
              },
            ),
            _buildActionItem(
              context,
              Icons.remove_circle,
              'Tarik',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Tarik akan diimplementasikan')),
                );
              },
            ),
            _buildActionItem(
              context,
              Icons.swap_horiz,
              'Transfer',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Transfer akan diimplementasikan')),
                );
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

  Widget _buildSharedWithSection(BuildContext context, Wallet wallet) {
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
                  context.pop(); // Close the bottom sheet
                  ref.read(selectedWalletProvider(walletId)).whenData(
                    (wallet) {
                      if (wallet != null) {
                        _showEditWalletDialog(context, ref, wallet);
                      }
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Hapus Dompet'),
                onTap: () {
                  context.pop(); // Close the bottom sheet
                  ref.read(selectedWalletProvider(walletId)).whenData(
                    (wallet) {
                      if (wallet != null) {
                        _showDeleteConfirmation(context, ref, wallet);
                      }
                    },
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
    Wallet wallet,
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
                            );

                            await ref
                                .read(walletNotifierProvider.notifier)
                                .updateWallet(updatedWallet);                            if (context.mounted) {
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
    Wallet wallet,
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
                              context.go('/wallet'); // Navigate back to wallet list
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
    Wallet wallet,
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
}
