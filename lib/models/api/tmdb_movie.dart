import 'package:ai_char_chat_app/models/cast_character.dart';
import 'package:ai_char_chat_app/models/movies_series.dart';

class TmdbMovie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;

  TmdbMovie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory TmdbMovie.fromJson(Map<String, dynamic> json) {
    return TmdbMovie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? '',
    );
  }

  String getFullImageUrl(String? path, {String size = 'w780'}) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/500x750?text=No+Image';
    }
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  MoviesSeries toMoviesSeries(List<CastCharacter> cast) {
    // Update each character's movieName
    for (var character in cast) {
      character.movieName = title;
    }

    return MoviesSeries(
      name: title,
      imageUrl: getFullImageUrl(posterPath),
      cast: cast,
      id: id,
      mediaType: 'movie',
    );
  }
}
