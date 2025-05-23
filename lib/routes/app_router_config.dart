import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:duit_aing/models/enums.dart';

import '../ui/pages/home_page.dart';
import '../ui/pages/wallet_list_page.dart';
import '../ui/pages/wallet_detail_page.dart';
import '../ui/pages/wallet_invitations_page.dart';
import '../ui/pages/login_page.dart';
import '../ui/pages/register_page.dart';
import '../ui/pages/forgot_password_page.dart';
import '../ui/pages/add_transaction_page.dart';
import '../ui/widgets/auth_check.dart';
import '../providers/auth_provider.dart';

// Provider for GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  // Observe authentication state changes
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges()
    ),
    redirect: (context, state) {
      // Check for user authentication
      final isLoggedIn = authState.value != null;
      
      // Get the current location
      final location = state.matchedLocation;
      
      // List of paths that don't require authentication
      final nonAuthPaths = ['/login', '/register', '/forgot-password'];
      
      // If user is logged in and trying to access auth pages, redirect to home
      if (isLoggedIn && nonAuthPaths.contains(location)) {
        return '/';
      }
      
      // If user is not logged in and trying to access protected pages
      if (!isLoggedIn && !nonAuthPaths.contains(location)) {
        return '/login';
      }
      
      // Allow the navigation to proceed
      return null;
    },
    routes: [
      // Home route
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const AuthCheck(
          signedInBuilder: HomePage(),
          signedOutBuilder: LoginPage(),
        ),
      ),
      
      // Login route
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      
      // Register route
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      
      // Forgot Password route
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Wallet List route
      GoRoute(
        path: '/wallet',
        name: 'wallets',
        builder: (context, state) => const AuthCheck(
          signedInBuilder: WalletListPage(),
          signedOutBuilder: LoginPage(),
        ),
      ),
      
      // Wallet Detail route
      GoRoute(
        path: '/wallet/:id',
        name: 'wallet-detail',
        builder: (context, state) {
          final walletId = state.pathParameters['id'] ?? '';
          return AuthCheck(
            signedInBuilder: WalletDetailPage(walletId: walletId),
            signedOutBuilder: const LoginPage(),
          );
        },
      ),
        // Wallet Invitations route
      GoRoute(
        path: '/wallet-invitations',
        name: 'wallet-invitations',
        builder: (context, state) => const AuthCheck(
          signedInBuilder: WalletInvitationsPage(),
          signedOutBuilder: LoginPage(),
        ),
      ),
        // Add Transaction route
      GoRoute(
        path: '/wallet/:id/add-transaction',
        name: 'add-transaction',
        builder: (context, state) {
          final walletId = state.pathParameters['id'] ?? '';
          final typeParam = state.uri.queryParameters['type'];
          TransactionType? initialType;
          
          if (typeParam != null) {
            try {
              initialType = TransactionType.values.firstWhere(
                (e) => e.toString().split('.').last == typeParam
              );
            } catch (_) {
              // Invalid type parameter, use default (null)
            }
          }
          
          return AuthCheck(
            signedInBuilder: AddTransactionPage(
              walletId: walletId,
              initialType: initialType,
            ),
            signedOutBuilder: const LoginPage(),
          );
        },
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

// A notifier for GoRouter that listens to a Stream
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
