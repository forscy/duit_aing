import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/providers/wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateWalletDialog extends ConsumerStatefulWidget {
  const CreateWalletDialog({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateWalletDialog> createState() => _CreateWalletDialogState();
}

class _CreateWalletDialogState extends ConsumerState<CreateWalletDialog> {
  final nameController = TextEditingController();
  WalletVisibility visibility = WalletVisibility.private;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            items: WalletVisibility.values.map((v) {
              return DropdownMenuItem(
                value: v,
                child: Text(
                  v == WalletVisibility.private ? 'Pribadi' : 'Bersama',
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
              onPressed: isLoading
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
                        final walletNotifier =
                            ref.read(walletNotifierProvider.notifier);
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
              child: isLoading
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
  }
}
