import 'package:flutter/material.dart';
import '../ui/pages/wallet_detail_page.dart';
import '../ui/pages/wallet_invitations_page.dart';
import '../ui/pages/wallet_list_page.dart';
import './app_routes.dart';

/// Router class for handling all application routes
class AppRouter {
  /// Generate routes based on settings
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');
    final path = uri.path;
    final params = uri.pathSegments;

    switch (path) {
      case Routes.wallet:
        if (params.length >= 2) {
          final walletId = params[1];
          return MaterialPageRoute(
            builder: (_) => WalletDetailPage(walletId: walletId),
          );
        }
        return MaterialPageRoute(builder: (_) => const WalletListPage());
        
      case '/wallet-invitations':
        return MaterialPageRoute(builder: (_) => const WalletInvitationsPage());
        
      default:
        return null;
    }
  }
}
