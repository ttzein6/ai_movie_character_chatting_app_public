// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:ai_char_chat_app/models/cast_character.dart';

class MoviesSeries {
  String name;
  List<CastCharacter> cast;
  String imageUrl;
  int? id; // TMDb ID for rating
  String? mediaType; // 'movie' or 'tv'

  MoviesSeries({
    required this.name,
    required this.cast,
    required this.imageUrl,
    this.id,
    this.mediaType,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'cast': cast.map((x) => x.toMap()).toList(),
      'imageUrl': imageUrl,
      'id': id,
      'mediaType': mediaType,
    };
  }

  factory MoviesSeries.fromMap(Map<String, dynamic> map) {
    return MoviesSeries(
      name: map['name'] as String,
      cast: List<CastCharacter>.from(
        (map['cast'] as List).map<CastCharacter>(
          (x) => CastCharacter.fromMap(x as Map<String, dynamic>),
        ),
      ),
      imageUrl: map['imageUrl'] as String,
      id: map['id'] as int?,
      mediaType: map['mediaType'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory MoviesSeries.fromJson(String source) =>
      MoviesSeries.fromMap(json.decode(source) as Map<String, dynamic>);
}

List<MoviesSeries> movies = [
  MoviesSeries(
      name: "Breaking Bad",
      cast: [
        CastCharacter(
            name: "Walter White",
            movieName: 'Breaking Bad',
            imageUrl:
                "https://static.wikia.nocookie.net/villains/images/6/65/Walter_White2.jpg/revision/latest/scale-to-width-down/350?cb=20230109113855"),
        CastCharacter(
            name: "Jesse Pinkman",
            movieName: 'Breaking Bad',
            imageUrl:
                "https://static.wikia.nocookie.net/breakingbad/images/9/95/JesseS5.jpg/revision/latest/scale-to-width/360?cb=20120620012441"),
        CastCharacter(
            name: "Hank Schrader",
            movieName: 'Breaking Bad',
            imageUrl:
                "https://upload.wikimedia.org/wikipedia/en/thumb/d/db/Hank_Schrader_S5B.png/220px-Hank_Schrader_S5B.png"),
        CastCharacter(
            name: "Gus Fring",
            movieName: 'Breaking Bad',
            imageUrl:
                "https://static.wikia.nocookie.net/villains/images/7/75/Pollos2.png/revision/latest?cb=20230321121053"),
      ],
      imageUrl:
          "https://fr.web.img5.acsta.net/pictures/19/06/18/12/11/3956503.jpg"),
  MoviesSeries(
      name: "Better Caul Saul",
      cast: [
        CastCharacter(
            name: "Saul Goodman",
            movieName: "Better Caul Saul",
            imageUrl:
                "https://www.meme-arsenal.com/memes/97b2309df99907a2f8f7ba99f9871d94.jpg"),
        CastCharacter(
            name: "Kim Wexler",
            movieName: "Better Caul Saul",
            imageUrl:
                "https://static.wikia.nocookie.net/breakingbad/images/4/48/Kim_Wexler_infobox.png/revision/latest/scale-to-width/360?cb=20220823082914"),
        CastCharacter(
            name: "Gus Fring",
            movieName: "Better Caul Saul",
            imageUrl:
                "https://static.wikia.nocookie.net/villains/images/7/75/Pollos2.png/revision/latest?cb=20230321121053"),
      ],
      imageUrl:
          "https://m.media-amazon.com/images/M/MV5BZDA4YmE0OTYtMmRmNS00Mzk2LTlhM2MtNjk4NzBjZGE1MmIyXkEyXkFqcGdeQXVyMTMzNDExODE5._V1_FMjpg_UX1000_.jpg"),
  MoviesSeries(
    name: "Oppenheimer",
    cast: [
      CastCharacter(
          name: "J. Robert Oppenheimer",
          movieName: "Oppenheimer",
          imageUrl:
              "https://images.immediate.co.uk/production/volatile/sites/3/2023/07/Cillian-Murphy-Oppenheimer-19a28a1.jpg?quality=90&resize=620,414"),
      CastCharacter(
          name: "Harry S. Truman",
          movieName: "Oppenheimer",
          imageUrl:
              "https://img6.fresherslive.com/latestnews/2023/07/who-plays-harry-truman-in-oppenheimer-64bfa74264ba52049067-900.webp"),
      CastCharacter(
          name: "Jean Tatlock",
          movieName: "Oppenheimer",
          imageUrl:
              "https://hips.hearstapps.com/hmg-prod/images/oppenheimer-and-tatlock-64c27b76d18f3.png?crop=0.473xw:0.778xh;0,0.0897xh&resize=1200:*"),
    ],
    imageUrl: "https://wallpapercave.com/wp/wp12552479.jpg",
  ),
  MoviesSeries(
      name: "Vikings",
      cast: [
        CastCharacter(
            name: "Ragnar",
            movieName: "Vikings",
            imageUrl:
                "https://grimfrost.com/cdn/shop/articles/ragnar_vikings_grimfrost.jpg?v=1481295297")
      ],
      imageUrl: "https://flxt.tmsimg.com/assets/p10467242_b_v8_aa.jpg"),
  MoviesSeries(
      name: "The Shawshank Redemption",
      cast: [
        CastCharacter(
            name: "Andy Dufresne",
            movieName: "The Shawshank Redemption",
            imageUrl:
                "https://static.wikia.nocookie.net/p__/images/3/3b/AndyDufresne.jpg/revision/latest?cb=20210307052356&path-prefix=protagonist"),
        CastCharacter(
            name: "Warden Norton",
            movieName: "The Shawshank Redemption",
            imageUrl:
                "https://static.wixstatic.com/media/1c0cc6_d3718d697a74486dafee9fa59233202e~mv2.png/v1/fill/w_600,h_464,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/1c0cc6_d3718d697a74486dafee9fa59233202e~mv2.png")
      ],
      imageUrl:
          "https://w0.peakpx.com/wallpaper/979/854/HD-wallpaper-shawshank-redemption-redemption-shawshank-the-shawshank-redemption.jpg"),
  MoviesSeries(
      name: "Elite",
      cast: [
        CastCharacter(
            name: "Carla Rosón Caleruega",
            movieName: "Elite",
            imageUrl:
                "https://static.wikia.nocookie.net/elite/images/c/cc/Carla_T3.jpg/revision/latest?cb=20200313115222&path-prefix=es")
      ],
      imageUrl:
          "https://static.wikia.nocookie.net/netflix/images/f/f4/Elite_Season_4_Poster.jpg/revision/latest?cb=20210621041557"),

  ///[To be deleted]
  ///
  MoviesSeries(
      name: "Breaking Bad2",
      cast: [
        CastCharacter(
            name: "Walter White2",
            movieName: "Breaking Bad2",
            imageUrl:
                "https://static.wikia.nocookie.net/villains/images/6/65/Walter_White2.jpg/revision/latest/scale-to-width-down/350?cb=20230109113855"),
        CastCharacter(
            name: "Jesse Pinkman2",
            movieName: "Breaking Bad2",
            imageUrl:
                "https://static.wikia.nocookie.net/breakingbad/images/9/95/JesseS5.jpg/revision/latest/scale-to-width/360?cb=20120620012441"),
        CastCharacter(
            name: "Hank Schrader2",
            movieName: "Breaking Bad2",
            imageUrl:
                "https://upload.wikimedia.org/wikipedia/en/thumb/d/db/Hank_Schrader_S5B.png/220px-Hank_Schrader_S5B.png"),
        CastCharacter(
            name: "Gus Fring2",
            movieName: "Breaking Bad2",
            imageUrl:
                "https://static.wikia.nocookie.net/villains/images/7/75/Pollos2.png/revision/latest?cb=20230321121053"),
      ],
      imageUrl:
          "https://fr.web.img5.acsta.net/pictures/19/06/18/12/11/3956503.jpg"),
  MoviesSeries(
      name: "Better Caul Saul2",
      cast: [
        CastCharacter(
            name: "Saul Goodman2",
            movieName: "Better Caul Saul2",
            imageUrl:
                "https://www.meme-arsenal.com/memes/97b2309df99907a2f8f7ba99f9871d94.jpg"),
        CastCharacter(
            name: "Kim Wexler2",
            movieName: "Better Caul Saul2",
            imageUrl:
                "https://static.wikia.nocookie.net/breakingbad/images/4/48/Kim_Wexler_infobox.png/revision/latest/scale-to-width/360?cb=20220823082914"),
        CastCharacter(
            name: "Gus Fring2",
            movieName: "Better Caul Saul2",
            imageUrl:
                "https://static.wikia.nocookie.net/villains/images/7/75/Pollos2.png/revision/latest?cb=20230321121053"),
      ],
      imageUrl:
          "https://m.media-amazon.com/images/M/MV5BZDA4YmE0OTYtMmRmNS00Mzk2LTlhM2MtNjk4NzBjZGE1MmIyXkEyXkFqcGdeQXVyMTMzNDExODE5._V1_FMjpg_UX1000_.jpg"),
  MoviesSeries(
    name: "Oppenheimer2",
    cast: [
      CastCharacter(
          name: "J. Robert Oppenheimer2",
          movieName: "Oppenheimer2",
          imageUrl:
              "https://images.immediate.co.uk/production/volatile/sites/3/2023/07/Cillian-Murphy-Oppenheimer-19a28a1.jpg?quality=90&resize=620,414"),
      CastCharacter(
          name: "Harry S. Truman2",
          movieName: "Oppenheimer2",
          imageUrl:
              "https://img6.fresherslive.com/latestnews/2023/07/who-plays-harry-truman-in-oppenheimer-64bfa74264ba52049067-900.webp"),
      CastCharacter(
          name: "Jean Tatlock2",
          movieName: "Oppenheimer2",
          imageUrl:
              "https://hips.hearstapps.com/hmg-prod/images/oppenheimer-and-tatlock-64c27b76d18f3.png?crop=0.473xw:0.778xh;0,0.0897xh&resize=1200:*"),
    ],
    imageUrl: "https://wallpapercave.com/wp/wp12552479.jpg",
  ),
  MoviesSeries(
      name: "The Shawshank Redemption2",
      cast: [
        CastCharacter(
            name: "Andy Dufresne2",
            movieName: "The Shawshank Redemption2",
            imageUrl:
                "https://static.wikia.nocookie.net/p__/images/3/3b/AndyDufresne.jpg/revision/latest?cb=20210307052356&path-prefix=protagonist"),
        CastCharacter(
            name: "Warden Norton2",
            movieName: "The Shawshank Redemption2",
            imageUrl:
                "https://static.wixstatic.com/media/1c0cc6_d3718d697a74486dafee9fa59233202e~mv2.png/v1/fill/w_600,h_464,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/1c0cc6_d3718d697a74486dafee9fa59233202e~mv2.png")
      ],
      imageUrl:
          "https://w0.peakpx.com/wallpaper/979/854/HD-wallpaper-shawshank-redemption-redemption-shawshank-the-shawshank-redemption.jpg"),
];
