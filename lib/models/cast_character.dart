// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CastCharacter {
  String name;
  String movieName;
  String imageUrl;
  CastCharacter(
      {required this.name, required this.movieName, required this.imageUrl});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'imageUrl': imageUrl,
      'movieName': movieName,
    };
  }

  factory CastCharacter.fromMap(Map<String, dynamic> map) {
    return CastCharacter(
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      movieName: map['movieName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CastCharacter.fromJson(String source) =>
      CastCharacter.fromMap(json.decode(source) as Map<String, dynamic>);
}
