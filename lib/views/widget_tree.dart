import 'package:flutter/material.dart';
import 'package:mahalaga_app/data/notifiers.dart';
import 'package:mahalaga_app/views/auth_service.dart';
import 'package:mahalaga_app/views/pages/calendar_page.dart';
import 'package:mahalaga_app/views/pages/home_page.dart';
import 'package:mahalaga_app/views/pages/menu_page.dart';
import 'package:mahalaga_app/views/pages/pet_page/pet_adoption_page.dart';
import 'package:mahalaga_app/views/pages/pet_page/pet_profile_view.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final authService = AuthService();
  int _currentIndex = 0; // Tracks the currently selected tab
  bool isViewProfileSelected = false; // Controls if Pet Info Card is shown
  bool showAdoptionPage =
      false; // Controls if PetAdoptionPage is shown instead of PetProfileView
  bool showMenuSubNav = false; // Controls if Menu sub-navigation is shown

  void logout() async {
    await authService.signOut();
  }

  // Determines what to show on the Pet tab (either profile or adoption page)
  Widget _getPetTabContent() {
    return showAdoptionPage ? PetAdoptionPage() : PetProfileView();
  }

  // Determines what to show on the Menu tab
  Widget _getMenuTabContent() {
    if (showMenuSubNav) {
      // Replace with your desired sub-page widgets
      return Center(child: Text("Sub-page content here"));
    }
    return MenuPage(); // Default MenuPage content
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Mahalaga'),
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 0, 0, 0),
          child: Image.asset('assets/logo/logo_nobg.png'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              isDarkModeNotifier.value = !isDarkModeNotifier.value;
            },
            icon: ValueListenableBuilder(
              valueListenable: isDarkModeNotifier,
              builder: (context, isDarkMode, child) {
                return Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode);
              },
            ),
          ),
          IconButton(onPressed: logout, icon: Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          // Main content area that changes depending on selected tab
          Expanded(
            child:
                _currentIndex == 1
                    ? _getPetTabContent() // If Pet tab is selected, show pet content
                    : _currentIndex == 0
                    ? HomePage() // Home tab content
                    : _currentIndex == 2
                    ? CalendarPage() // Calendar tab content
                    : _getMenuTabContent(), // Menu tab content
          ),

          // Shows a secondary navigation (Pet Profile / Adoption) only when Pet tab is active
          if (_currentIndex == 1)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Colors.teal.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAdoptionPage = false; // Show Pet Profile
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.pets,
                          color: showAdoptionPage ? Colors.grey : Colors.teal,
                        ),
                        Text(
                          'Pet Profile',
                          style: TextStyle(
                            fontSize: 12,
                            color: showAdoptionPage ? Colors.grey : Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAdoptionPage = true; // Show Adoption Page
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.volunteer_activism,
                          color: showAdoptionPage ? Colors.teal : Colors.grey,
                        ),
                        Text(
                          'Adoption',
                          style: TextStyle(
                            fontSize: 12,
                            color: showAdoptionPage ? Colors.teal : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Shows a secondary navigation for Menu tab
          if (_currentIndex == 3)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Colors.teal.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showMenuSubNav = false; // Show default MenuPage
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.menu_book,
                          color: showMenuSubNav ? Colors.grey : Colors.teal,
                        ),
                        Text(
                          'Menu',
                          style: TextStyle(
                            fontSize: 12,
                            color: showMenuSubNav ? Colors.grey : Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showMenuSubNav = true; // Show sub-page content
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.settings,
                          color: showMenuSubNav ? Colors.teal : Colors.grey,
                        ),
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 12,
                            color: showMenuSubNav ? Colors.teal : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;

            // Reset sub-navigation states when switching tabs
            if (index != 1) showAdoptionPage = false;
            if (index != 3) showMenuSubNav = false;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pet'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}
