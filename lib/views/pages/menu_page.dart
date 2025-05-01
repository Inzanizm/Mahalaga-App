import 'package:flutter/material.dart';
import 'package:mahalaga_app/kyme/community_widgets/community_forum_screen.dart';
import 'package:mahalaga_app/kyme/map_screen.dart';
import 'package:mahalaga_app/views/pages/login_screen.dart';
// import 'package:mahalaga_app/kyme/community_forum_screen.dart';
// import 'package:mahalaga_app/kyme/map_screen.dart';
// import 'package:mahalaga_app/views/pages/login_screen.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              // Navigate to Map Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 104, 168, 141),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'View Nearby Pet Services',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              // Navigate to Map Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CommunityForumScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 104, 168, 141),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Community Forum',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              // Navigate to Login Page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 104, 168, 141),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
