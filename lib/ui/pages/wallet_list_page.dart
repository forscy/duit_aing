import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/wallet.dart';
import 'package:duit_aing/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Halaman untuk menampilkan daftar wallet
class WalletListPage extends ConsumerWidget {
  const WalletListPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Make sure wallet state is reset when needed
    ref.watch(walletResetProvider);

    // Now watch the wallet list
    final walletsAsync = ref.watch(walletListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet Saya'),
        // back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              context.push('/wallet-invitations');
            },
            tooltip: 'Undangan Dompet',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'migration') {
                context.push('/database-migration');
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'migration',
                    child: Text('Migrasi Database'),
                  ),
                ],
          ),
        ],
      ),
      body: walletsAsync.when(
        data: (wallets) {
          if (wallets.isEmpty) {
            return const Center(
              child: Text('Belum ada dompet. Buat dompet baru untuk memulai.'),
            );
          }

          return ListView.builder(
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              return WalletCard(wallet: wallet);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) =>
                Center(child: Text('Error: ${error.toString()}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateWalletDialog(context, ref),
        child: const Icon(Icons.add),
        tooltip: 'Buat Dompet Baru',
      ),
    );
  }

  void _showCreateWalletDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    WalletVisibility visibility = WalletVisibility.private;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Buat Dompet Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Dompet'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<WalletVisibility>(
                    value: visibility,
                    decoration: const InputDecoration(labelText: 'Visibilitas'),
                    items:
                        WalletVisibility.values.map((v) {
                          return DropdownMenuItem(
                            value: v,
                            child: Text(
                              v == WalletVisibility.private
                                  ? 'Pribadi'
                                  : 'Bersama',
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          visibility = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final walletState = ref.watch(walletNotifierProvider);
                    final isLoading = walletState is AsyncLoading;

                    return FilledButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (nameController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Nama dompet tidak boleh kosong',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  final walletNotifier = ref.read(
                                    walletNotifierProvider.notifier,
                                  );
                                  await walletNotifier.createWallet(
                                    nameController.text.trim(),
                                    visibility,
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Dompet berhasil dibuat'),
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
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Buat'),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

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
