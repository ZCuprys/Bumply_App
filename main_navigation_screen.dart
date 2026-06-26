import 'package:flutter/material.dart';

import 'package:bumply_app/gradient_container.dart';
import 'package:bumply_app/home_screen.dart';
import 'package:bumply_app/reports_screen.dart';
import 'package:bumply_app/articles_screen.dart';
import 'package:bumply_app/calendar_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int userId;

  const MainNavigationScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MainNavigationScreen> createState() {
    return _MainNavigationScreenState();
  }
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int selectedPageIndex = 0;

  void selectPage(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(userId: widget.userId),
      ReportsPage(userId: widget.userId),
      const ArticlesScreen(),
      CalendarScreen(userId: widget.userId),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const GradientContainer(
            Color.fromRGBO(137, 168, 248, 1),
            Color.fromRGBO(201, 216, 250, 1),
            Color.fromRGBO(241, 246, 255, 1),
          ),

          pages[selectedPageIndex],
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPageIndex,
        onTap: selectPage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromRGBO(241, 246, 255, 1),
        selectedItemColor: const Color.fromRGBO(137, 168, 248, 1),
        unselectedItemColor: const Color.fromRGBO(120, 130, 160, 1),
        selectedFontSize: 13,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}