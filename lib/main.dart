import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';

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
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Duit Aing',      
      theme: ThemeData(
        primaryColor: Color(0xFF6C5CE7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6C5CE7),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: Routes.root,
      defaultTransition: Transition.fade,
      debugShowCheckedModeBanner: false,
      // Menangani error di seluruh aplikasi
      onInit: () {
        // Setup error handling global
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Material(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Silakan coba lagi atau restart aplikasi',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        };
      },
    );
  }
}