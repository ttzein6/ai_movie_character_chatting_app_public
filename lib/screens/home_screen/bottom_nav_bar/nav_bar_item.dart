import 'package:flutter/material.dart';

BottomNavigationBarItem getNavBarItem(
  bool isSelected,
  Widget icon,
  String text,
) {
  return BottomNavigationBarItem(icon: icon, label: isSelected ? text : "null");
}
// class NavBarItem extends StatelessWidget {
//   final bool isSelected;
//   final Widget icon;
//   final Widget text;
//   const NavBarItem(
//       {super.key,
//       required this.isSelected,
//       required this.icon,
//       required this.text});

//   @override
//   Widget build(BuildContext context) {
    
//     // return AnimatedContainer(
//     //   duration: const Duration(milliseconds: 100),
//     //   child: isSelected
//     //       ? icon
//     //       : Row(
//     //           mainAxisSize: MainAxisSize.min,
//     //           children: [icon, text],
//     //         ),
//     // );
//   }
// }
