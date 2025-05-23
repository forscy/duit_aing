import 'package:duit_aing/providers/wallet_provider.dart';
import 'package:duit_aing/ui/widgets/wallet/create_wallet_dialog.dart';
import 'package:duit_aing/ui/widgets/wallet/wallet_card.dart';
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
            itemBuilder: (context) => [
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
        error: (error, stackTrace) =>
            Center(child: Text('Error: ${error.toString()}')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const CreateWalletDialog(),
        ),
        child: const Icon(Icons.add),
        tooltip: 'Buat Dompet Baru',
      ),
    );
  }
}
