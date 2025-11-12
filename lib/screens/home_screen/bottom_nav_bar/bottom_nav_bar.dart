import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final void Function(int)? onTap;
  final int currentIndex = 0;

  const BottomNavBar({
    super.key,
    required this.items,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.green,
      items: items,
      onTap: onTap,
    );
  }
}
