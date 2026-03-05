import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'package:eduverifica_app/services/supabasekey.dart';
import 'screens/login_screen.dart';


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

