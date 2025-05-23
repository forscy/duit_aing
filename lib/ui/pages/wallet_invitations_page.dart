import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/wallet.dart';
import 'package:duit_aing/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Halaman untuk menampilkan undangan dompet
class WalletInvitationsPage extends ConsumerWidget {
  const WalletInvitationsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Make sure wallet state is reset when needed
    ref.watch(walletResetProvider);
    
    final invitationsAsync = ref.watch(walletInvitationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Undangan Dompet'),
      ),
      body: invitationsAsync.when(
        data: (invitations) {
          if (invitations.isEmpty) {
            return const Center(
              child: Text('Tidak ada undangan dompet saat ini'),
            );
          }

          return ListView.builder(
            itemCount: invitations.length,
            itemBuilder: (context, index) {
              final item = invitations[index];
              final wallet = item['wallet'] as WalletModel;
              final invitation = item['invitation'] as WalletInvitation;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.account_balance_wallet),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              wallet.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Diundang oleh pemilik dompet',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _respondToInvitation(
                                context, ref, wallet.id, invitation.email, 
                                InvitationStatus.rejected,
                              ),
                              child: const Text('Tolak'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => _respondToInvitation(
                                context, ref, wallet.id, invitation.email, 
                                InvitationStatus.accepted,
                              ),
                              child: const Text('Terima'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  void _respondToInvitation(
    BuildContext context,
    WidgetRef ref,
    String walletId,
    String email,
    InvitationStatus response,
  ) async {
    try {
      await ref
          .read(walletNotifierProvider.notifier)
          .respondToInvitation(walletId, email, response);

      if (context.mounted) {
        final message = response == InvitationStatus.accepted
            ? 'Undangan diterima'
            : 'Undangan ditolak';
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
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
