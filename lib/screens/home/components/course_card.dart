import 'package:ai_char_chat_app/models/cast_character.dart';
import 'package:ai_char_chat_app/models/movies_series.dart';
import 'package:ai_char_chat_app/screens/movie_screen/movie_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    Key? key,
    required this.movie,
    this.color = const Color(0xFF7553F6),
  }) : super(key: key);

  final Color color;
  final MoviesSeries movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => MovieScreen(
                    movie: MoviesSeries(
                  name: movie.name,
                  // cast: List.generate(
                  //   10,
                  //   (index) =>
                  //       CastCharacter(name: "Walter White", imageUrl: ""),
                  // ),
                  cast: movie.cast,
                  imageUrl: movie.imageUrl,
                ))));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),

        // height: 500,
        // width: 260,
        width: MediaQuery.of(context).size.width * 0.35,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 230, 175, 50), //color,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: "title-image-${movie.name}",
                child: ClipOval(
                  child: Image.network(
                    movie.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.fill,
                    // width: 100,
                    // height: 100,
                    // width: MediaQuery.of(context).size.width,
                    // opacity: AlwaysStoppedAnimation(0.4),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                movie.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Text(
              "${movie.cast.length} Characters",
              style: const TextStyle(
                color: Colors.white70,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 25,
              width: double.infinity,
              child: ListView.builder(
                itemCount: movie.cast.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Transform.translate(
                    offset: Offset((-10 * index).toDouble(), 0),
                    child: CircleAvatar(
                      radius: 15,
                      // backgroundImage: AssetImage(
                      //   "assets/avaters/Avatar ${index + 1}.jpg",
                      // ),
                      backgroundImage: NetworkImage(movie.cast[index].imageUrl),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
