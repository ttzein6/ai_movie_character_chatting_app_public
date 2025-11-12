import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SecondaryCourseCard extends StatelessWidget {
  const SecondaryCourseCard({
    Key? key,
    required this.title,
    this.iconsSrc = "assets/icons/ios.svg",
    this.colorl = const Color(0xFF7553F6),
    this.index,
  }) : super(key: key);

  final String title, iconsSrc;
  final Color colorl;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
          // color: colorl,
          color: Colors.brown[400],
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Walter White",
                  // title,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Breaking bad",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 40,
            child: VerticalDivider(
              // thickness: 5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 8),
          // SvgPicture.asset(iconsSrc)
          ClipOval(
            child: index != null
                ? Hero(
                    tag: "char-chat-icon-$index",
                    child: Image.network(
                      "https://static.wikia.nocookie.net/villains/images/6/65/Walter_White2.jpg/revision/latest/scale-to-width-down/350?cb=20230109113855",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.network(
                    "https://static.wikia.nocookie.net/villains/images/6/65/Walter_White2.jpg/revision/latest/scale-to-width-down/350?cb=20230109113855",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
          )
        ],
      ),
    );
  }
}
