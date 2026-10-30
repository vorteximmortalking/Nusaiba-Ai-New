import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/permission_service.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PermissionService.requestAllPermissions(); 
  runApp(const NusaibaApp());
}

class NusaibaApp extends StatelessWidget {
  const NusaibaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nusaiba AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E27),
        primaryColor: const Color(0xFF4FC3F7),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
