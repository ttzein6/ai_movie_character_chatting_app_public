import 'package:ai_char_chat_app/screens/chats/chats_screen.dart';
import 'package:ai_char_chat_app/screens/favorites/favorites_screen.dart';
import 'package:ai_char_chat_app/screens/home/home_page.dart';
import 'package:ai_char_chat_app/screens/home_screen/bottom_nav_bar/modern_bottom_nav_bar.dart';
import 'package:ai_char_chat_app/screens/search/search_screen.dart';
import 'package:ai_char_chat_app/screens/settings_screen/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  bool _isNavBarCollapsed = false;

  final List<Widget> screens = const [
    HomePage(),
    FavoritesScreen(),
    ChatsScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  bool _handleScrollNotification(ScrollNotification notification) {
    // Only handle notifications from the home screen (index 0)
    if (currentIndex != 0) return false;

    if (notification is UserScrollNotification) {
      final direction = notification.direction;

      if (direction == ScrollDirection.forward) {
        // Scrolling up - expand navbar
        if (_isNavBarCollapsed) {
          setState(() {
            _isNavBarCollapsed = false;
          });
        }
      } else if (direction == ScrollDirection.reverse) {
        // Scrolling down - collapse navbar
        if (!_isNavBarCollapsed) {
          setState(() {
            _isNavBarCollapsed = true;
          });
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.black,
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: ModernBottomNavBar(
          currentIndex: currentIndex,
          isCollapsed: _isNavBarCollapsed,
          onTap: (index) {
            setState(() {
              currentIndex = index;
              // Always expand navbar when switching tabs
              _isNavBarCollapsed = false;
            });
          },
        ),
      ),
    );
  }
}
