import 'package:duit_aing/models/wallet.dart';
import 'package:duit_aing/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EditWalletDialog extends ConsumerStatefulWidget {
  final WalletModel wallet;

  const EditWalletDialog({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  ConsumerState<EditWalletDialog> createState() => _EditWalletDialogState();
}

class _EditWalletDialogState extends ConsumerState<EditWalletDialog> {
  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.wallet.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        final updatedWallet = widget.wallet.copyWith(
                          name: nameController.text.trim(),
                        );

                        await ref
                            .read(walletNotifierProvider.notifier)
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
  }
}
