import 'dart:math';

import 'package:ai_char_chat_app/screens/home/home_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key, required this.animation, required this.scalAnimation});
  Animation<double> scalAnimation;
  Animation<double> animation;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // AnimatedPositioned(
          //   width: 288,
          //   height: MediaQuery.of(context).size.height,
          //   duration: const Duration(milliseconds: 200),
          //   curve: Curves.fastOutSlowIn,
          //   left: isSideBarOpen ? 0 : -288,
          //   top: 0,
          //   child: const SideBar(),
          // ),

          ///[Uncomment for removing bottom nav padding]
          // Transform(
          //   alignment: Alignment.center,
          //   transform: Matrix4.identity()
          //     ..setEntry(3, 2, 0.001)
          //     ..rotateY(
          //         1 * animation.value - 30 * (animation.value) * pi / 180),
          //   child: Transform.translate(
          //     offset: Offset(animation.value * 265, 0),
          //     child: Transform.scale(
          //       scale: scalAnimation.value,
          //       child: const ClipRRect(
          //         borderRadius: BorderRadius.all(
          //           Radius.circular(24),
          //         ),
          //         child: HomePage(),
          //       ),
          //     ),
          //   ),
          // ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            height: MediaQuery.of(context).size.height - 100,
            width: MediaQuery.of(context).size.width,
            bottom: 100,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(
                    1 * animation.value - 30 * (animation.value) * pi / 180),
              child: Transform.translate(
                offset: Offset(animation.value * 265, 0),
                child: Transform.scale(
                  scale: scalAnimation.value,
                  child: const ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(24),
                    ),
                    child: HomePage(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // body: SafeArea(
      // child: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
      //   child: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         "Hi Tamer !",
      //         style: Theme.of(context).textTheme.headlineMedium,
      //       ),
      //       Text(
      //         "Popular",
      //         style: Theme.of(context).textTheme.bodyMedium,
      //       ),
      //     ],
      //   ),
      // ),
      // ),
    );
  }
}
