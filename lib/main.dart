import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'screens/login_screen.dart';

const supabaseUrl = 'https://lspyupeetixgoshbdsxu.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxzcHl1cGVldGl4Z29zaGJkc3h1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1NDc5NzYsImV4cCI6MjA3ODEyMzk3Nn0.ac3tvZwZ72WqEtk_IC-Tp57zBIYgfr18iB54RWqvT1Q';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const EduVerificaApp());
}

class EduVerificaApp extends StatelessWidget {
  const EduVerificaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduVerifica',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
