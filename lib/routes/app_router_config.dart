import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ui/pages/home_page.dart';
import '../ui/pages/wallet_list_page.dart';
import '../ui/pages/wallet_detail_page.dart';
import '../ui/pages/wallet_invitations_page.dart';

// Provider for GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Home route
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      
      // Wallet List route
      GoRoute(
        path: '/wallet',
        name: 'wallets',
        builder: (context, state) => const WalletListPage(),
      ),
      
      // Wallet Detail route
      GoRoute(
        path: '/wallet/:id',
        name: 'wallet-detail',
        builder: (context, state) {
          final walletId = state.pathParameters['id'] ?? '';
          return WalletDetailPage(walletId: walletId);
        },
      ),
      
      // Wallet Invitations route
      GoRoute(
        path: '/wallet-invitations',
        name: 'wallet-invitations',
        builder: (context, state) => const WalletInvitationsPage(),
      ),
    ],
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Halaman tidak ditemukan: ${state.uri.path}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    ),
  );
});
