import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/debt.dart';
import '../services/debt_service.dart';

final debtServiceProvider = Provider<DebtService>((ref) => DebtService());

final debtsStreamProvider = StreamProvider<List<DebtModel>>((ref) {
  final debtService = ref.watch(debtServiceProvider);
  return debtService.getDebts();
});

final unpaidDebtsStreamProvider = StreamProvider<List<DebtModel>>((ref) {
  final debtService = ref.watch(debtServiceProvider);
  return debtService.getUnpaidDebts();
});

final walletDebtsStreamProvider = StreamProvider.family<List<DebtModel>, String>((ref, walletId) {
  final debtService = ref.watch(debtServiceProvider);
  return debtService.getDebtsByWallet(walletId);
});
