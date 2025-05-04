import 'package:flutter/material.dart';
import 'package:mahalaga_app/data/notifiers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mahalaga_app/views/screens/video_splash_screen.dart';

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
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.teal,
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
          ), // Applies a teal color theme to the app
          // theme: ThemeData(
          //   colorScheme: ColorScheme.fromSeed(
          //     seedColor: Colors.teal,
          //     brightness: isDarkMode ? Brightness.dark : Brightness.light,
          //   ),
          // ),
          home: VideoSplashScreen(),
        );
      },
    );
  }
}
