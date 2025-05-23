import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'routes/app_router_config.dart';
import 'providers/wallet_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set orientasi aplikasi ke portrait saja
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize Firebase: $e');
    // Masih lanjutkan aplikasi meskipun Firebase gagal, 
    // tapi usernya akan menemukan masalah saat mencoba login
  }  
  final container = ProviderContainer(
    observers: [
      LogoutProviderObserver(),
    ],
  );
  
  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

/// Observer to handle user logout events
class LogoutProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Check for auth state changes (logout)
    if (provider.name == 'authStateProvider' && 
        previousValue != newValue && 
        newValue == null) {
      // User logged out, invalidate all providers
      _resetAllProviders(container);
    }
  }
  
  void _resetAllProviders(ProviderContainer container) {
    // Reset all wallet-related providers
    try {
      container.invalidate(walletListProvider);
      container.invalidate(walletInvitationsProvider);
      container.invalidate(walletServiceProvider);
      // Add more providers as needed
    } catch (e) {
      debugPrint('Error resetting providers: $e');
    }
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the router from the provider
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Duit Aing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      // Use GoRouter configuration
      routerConfig: router,
    );
  }
}