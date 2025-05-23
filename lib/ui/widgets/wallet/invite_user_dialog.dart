import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/wallet.dart';
import 'package:duit_aing/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class InviteUserDialog extends ConsumerStatefulWidget {
  final WalletModel wallet;

  const InviteUserDialog({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  ConsumerState<InviteUserDialog> createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends ConsumerState<InviteUserDialog> {
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

                      if (widget.wallet.sharedWith.contains(email)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Pengguna sudah memiliki akses ke dompet ini'),
                          ),
                        );
                        return;
                      }

                      if (widget.wallet.invitations.any((invitation) =>
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
                        await ref
                            .read(walletNotifierProvider.notifier)
                            .inviteToWallet(widget.wallet.id, email);

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
  }
}
