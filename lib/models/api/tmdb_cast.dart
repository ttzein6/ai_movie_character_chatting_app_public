import 'package:ai_char_chat_app/models/cast_character.dart';

class TmdbCast {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  TmdbCast({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
  });

  factory TmdbCast.fromJson(Map<String, dynamic> json) {
    return TmdbCast(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
      order: json['order'] ?? 0,
    );
  }

  String getFullImageUrl(String? path, {String size = 'w185'}) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/185x278?text=No+Image';
    }
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  CastCharacter toCastCharacter({String movieName = ''}) {
    return CastCharacter(
      name: character.isNotEmpty ? character : name,
      imageUrl: getFullImageUrl(profilePath),
      movieName: movieName,
    );
  }
}
