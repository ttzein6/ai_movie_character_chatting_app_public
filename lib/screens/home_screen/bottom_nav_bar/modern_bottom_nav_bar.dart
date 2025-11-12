import 'package:flutter/material.dart';

class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isCollapsed;

  const ModernBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.isCollapsed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {'icon': Icons.home_rounded, 'label': 'Home', 'index': 0},
      {'icon': Icons.favorite_rounded, 'label': 'Favorites', 'index': 1},
      {'icon': Icons.chat_bubble_rounded, 'label': 'Chats', 'index': 2},
      {'icon': Icons.search_rounded, 'label': 'Search', 'index': 3},
      {'icon': Icons.settings_rounded, 'label': 'Settings', 'index': 4},
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 150 : 20,
        vertical: 20,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 12 : 20,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: isCollapsed
            ? MainAxisAlignment.center
            : MainAxisAlignment.spaceAround,
        children: navItems.map((item) {
          final index = item['index'] as int;
          final isActive = currentIndex == index;

          // When collapsed, only show the active tab
          if (isCollapsed && !isActive) {
            return const SizedBox.shrink();
          }

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isCollapsed
                ? (isActive ? 1.0 : 0.0)
                : 1.0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isCollapsed
                  ? (isActive ? 1.0 : 0.0)
                  : 1.0,
              child: _buildNavItem(
                icon: item['icon'] as IconData,
                label: item['label'] as String,
                index: index,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2196F3).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey[500],
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
