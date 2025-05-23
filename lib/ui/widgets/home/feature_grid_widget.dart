import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/settings_bottom_sheet.dart';

/// Widget untuk menampilkan grid menu fitur-fitur
class FeatureGridWidget extends StatelessWidget {
  const FeatureGridWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fitur',
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
            _buildFeatureItem(
              context,
              Icons.account_balance_wallet,
              'Dompet',
              () {
                context.go('/wallet');
              },
            ),
            _buildFeatureItem(
              context,
              Icons.receipt_long,
              'Transaksi',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Transaksi belum diimplementasi')),
                );
              },
            ),            _buildFeatureItem(
              context,
              Icons.attach_money,
              'Hutang',
              () {
                context.go('/debt');
              },
            ),
            _buildFeatureItem(
              context,
              Icons.pie_chart,
              'Laporan',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Laporan belum diimplementasi')),
                );
              },
            ),
            _buildFeatureItem(
              context,
              Icons.settings,
              'Pengaturan',
              () {
                // Menampilkan dialog opsi pengaturan
                showModalBottomSheet(
                  context: context,
                  builder: (context) => const SettingsBottomSheet(),
                );
              },
            ),
            _buildFeatureItem(
              context,
              Icons.help,
              'Bantuan',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Bantuan belum diimplementasi')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
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
              size: 32,
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
}
