import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

/// Widget untuk tombol sign out
class SignOutButton extends ConsumerWidget {
  /// Tipe tombol yang digunakan
  final SignOutButtonType buttonType;

  /// Constructor
  const SignOutButton({
    Key? key,
    this.buttonType = SignOutButtonType.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authNotifierProvider.notifier);
    final isLoading = ref.watch(authNotifierProvider) is AsyncLoading;

    // Handler untuk proses logout
    Future<void> handleSignOut() async {
      try {
        await authNotifier.logout();
        if (context.mounted) {
          context.go('/login');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Berhasil keluar'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal keluar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    switch (buttonType) {
      case SignOutButtonType.icon:
        return IconButton(
          onPressed: isLoading ? null : handleSignOut,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout),
          tooltip: 'Keluar',
        );
      
      case SignOutButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : handleSignOut,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Keluar'),
        );
      
      case SignOutButtonType.textWithIcon:
        return TextButton.icon(
          onPressed: isLoading ? null : handleSignOut,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout),
          label: const Text('Keluar'),
        );
      
      case SignOutButtonType.elevated:
        return ElevatedButton(
          onPressed: isLoading ? null : handleSignOut,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Keluar'),
        );
      
      case SignOutButtonType.elevatedWithIcon:
        return ElevatedButton.icon(
          onPressed: isLoading ? null : handleSignOut,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout),
          label: const Text('Keluar'),
        );
    }
  }
}

/// Enum untuk tipe tombol sign out
enum SignOutButtonType {
  /// Tombol icon saja
  icon,

  /// Tombol text saja
  text,

  /// Tombol text dengan icon
  textWithIcon,

  /// Tombol elevated
  elevated,

  /// Tombol elevated dengan icon
  elevatedWithIcon,
}
