import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // IMPORTANT! ITO YUNG LINE NA NAMALI KO KAYA NAWASTE YUNG ILANG ORAS KO T^T

  await Supabase.initialize(
    url: 'https://hntloshxinkevqumurmm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhudGxvc2h4aW5rZXZxdW11cm1tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzMTIyMDgsImV4cCI6MjA2MDg4ODIwOH0.OqMe0u5YupElH3rY422KvnYTYdje-nuBjv0Ls86glwo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Pet App',
      theme: ThemeData(primarySwatch: Colors.green),
      home:
          Supabase.instance.client.auth.currentSession == null
              ? const LoginScreen()
              : const HomePage(),
    );
  }
}
