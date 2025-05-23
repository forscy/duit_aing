import 'package:flutter/material.dart';
import 'sign_out_button.dart';

/// Widget untuk settings bottom sheet
class SettingsBottomSheet extends StatelessWidget {
  /// Constructor
  const SettingsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Pengaturan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingItem(
            context,
            Icons.person,
            'Profil',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Profil belum diimplementasi')),
              );
            },
          ),
          _buildSettingItem(
            context,
            Icons.notifications,
            'Notifikasi',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Notifikasi belum diimplementasi')),
              );
            },
          ),
          _buildSettingItem(
            context,
            Icons.language,
            'Bahasa',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Bahasa belum diimplementasi')),
              );
            },
          ),
          _buildSettingItem(
            context,
            Icons.dark_mode,
            'Tema',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Tema belum diimplementasi')),
              );
            },
          ),
          const Divider(thickness: 1),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SignOutButton(buttonType: SignOutButtonType.elevatedWithIcon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
