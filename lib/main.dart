import 'package:flutter/material.dart';
import 'package:mahalaga_app/data/notifiers.dart';
import 'package:mahalaga_app/views/screens/video_splash_screen.dart';

void main() {
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
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.amber,
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
          ),
          home: VideoSplashScreen(),
        );
      },
    );
  }
}
