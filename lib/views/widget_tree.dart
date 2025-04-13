import 'package:flutter/material.dart';
import 'package:mahalaga_app/data/notifiers.dart';
import 'package:mahalaga_app/views/pages/calendar_page.dart';
import 'package:mahalaga_app/views/pages/home_page.dart';
import 'package:mahalaga_app/views/pages/menu_page.dart';
import 'package:mahalaga_app/views/pages/pet_page.dart';
import 'package:mahalaga_app/views/widgets/navbar_widget.dart';

List<Widget> pages = [HomePage(), PetPage(), CalendarPage(), MenuPage()];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Mahalaga: Pet Care App'),
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
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
