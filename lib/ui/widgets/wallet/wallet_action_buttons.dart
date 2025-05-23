import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/wallet.dart';

class WalletActionButtons extends ConsumerWidget {  final String walletId;
  final WalletModel wallet;
  final void Function(BuildContext context, WidgetRef ref) onInvitePressed;
  final void Function(BuildContext context, WidgetRef ref) onEditPressed;
  final void Function(BuildContext context, WidgetRef ref) onDeletePressed;
  
  const WalletActionButtons({
    Key? key,
    required this.walletId,
    required this.wallet,
    required this.onInvitePressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _buildActionButton(
              context,
              icon: Icons.add_circle,
              label: 'Pemasukan',
              onTap: () => context.push('/wallet/$walletId/add-transaction?type=income'),
            ),
            _buildActionButton(
              context,
              icon: Icons.remove_circle,
              label: 'Pengeluaran',
              onTap: () => context.push('/wallet/$walletId/add-transaction?type=expense'),
            ),
            _buildActionButton(
              context,
              icon: Icons.swap_horiz,
              label: 'Transfer',
              onTap: () => context.push('/wallet/$walletId/add-transaction?type=transfer'),
            ),
            if (wallet.visibility == WalletVisibility.shared)
              _buildActionButton(
                context,
                icon: Icons.person_add,
                label: 'Undang',
                onTap: () => onInvitePressed(context, ref),
              ),
            _buildActionButton(
              context,
              icon: Icons.edit,
              label: 'Edit',
              onTap: () => onEditPressed(context, ref),
            ),
            _buildActionButton(
              context,
              icon: Icons.delete,
              label: 'Hapus',
              onTap: () => onDeletePressed(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
