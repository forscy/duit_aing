import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'controllers/bindings.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Duit Aing',      theme: ThemeData(
        primaryColor: Color(0xFF6C5CE7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF6C5CE7),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),      initialBinding: AppBindings(),
      initialRoute: Routes.home,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.fade,
      debugShowCheckedModeBanner: false,
    );
  }
}
