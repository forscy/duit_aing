import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

/// Widget untuk mengecek status autentikasi
class AuthCheck extends ConsumerWidget {
  /// Widget untuk ditampilkan saat user sedang login
  final Widget signedInBuilder;

  /// Widget untuk ditampilkan saat user belum login
  final Widget signedOutBuilder;

  /// Widget yang ditampilkan saat proses loading
  final Widget? loadingBuilder;

  /// Constructor
  const AuthCheck({
    Key? key,
    required this.signedInBuilder,
    required this.signedOutBuilder,
    this.loadingBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (User? user) {
        if (user != null) {
          return signedInBuilder;
        } else {
          return signedOutBuilder;
        }
      },
      loading: () => loadingBuilder ?? 
        const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }
}
