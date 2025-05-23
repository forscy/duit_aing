import 'package:duit_aing/models/enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wallet.dart';
import '../services/wallet_service.dart';
import 'auth_provider.dart';

/// Provider untuk layanan wallet
final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

/// Provider untuk stream daftar wallet
final walletListProvider = StreamProvider<List<Wallet>>((ref) {
  final walletService = ref.watch(walletServiceProvider);
  return walletService.getWallets();
});

/// Provider untuk wallet yang sedang dipilih (detail)
final selectedWalletProvider = FutureProvider.family<Wallet?, String>((ref, walletId) async {
  final walletService = ref.watch(walletServiceProvider);
  return walletService.getWalletById(walletId);
});

/// Provider untuk invitation wallet
final walletInvitationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final walletService = ref.watch(walletServiceProvider);
  return walletService.getWalletInvitations();
});

/// Provider untuk status operasi wallet
final walletOperationStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

/// Controller notifier untuk wallet
class WalletNotifier extends StateNotifier<AsyncValue<void>> {
  final WalletService _walletService;

  WalletNotifier(this._walletService) : super(const AsyncValue.data(null));

  Future<Wallet> createWallet(String name, WalletVisibility visibility) async {
    state = const AsyncValue.loading();
    try {
      final wallet = await _walletService.createWallet(name, visibility);
      state = const AsyncValue.data(null);
      return wallet;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      throw error;
    }
  }

  Future<void> updateWallet(Wallet wallet) async {
    state = const AsyncValue.loading();
    try {
      await _walletService.updateWallet(wallet);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      throw error;
    }
  }

  Future<void> deleteWallet(String walletId) async {
    state = const AsyncValue.loading();
    try {
      await _walletService.deleteWallet(walletId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      throw error;
    }
  }

  Future<void> inviteToWallet(String walletId, String email) async {
    state = const AsyncValue.loading();
    try {
      await _walletService.inviteToWallet(walletId, email);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      throw error;
    }
  }

  Future<void> respondToInvitation(
      String walletId, String email, InvitationStatus response) async {
    state = const AsyncValue.loading();
    try {
      await _walletService.respondToInvitation(walletId, email, response);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      throw error;
    }
  }
}

/// Provider untuk wallet notifier
final walletNotifierProvider = StateNotifierProvider<WalletNotifier, AsyncValue<void>>((ref) {
  final walletService = ref.watch(walletServiceProvider);
  return WalletNotifier(walletService);
});

/// Provider untuk menandai bahwa wallet state harus di-reset
final walletResetProvider = Provider<void>((ref) {
  // Listen to auth changes to automatically reset wallet state when user logs out
  ref.listen(authStateProvider, (previous, next) {
    next.whenData((user) {
      if (user == null) {
        // Reset all wallet providers when user logs out
        ref.invalidate(walletListProvider);
        ref.invalidate(walletInvitationsProvider);
      }
    });
  });
});
