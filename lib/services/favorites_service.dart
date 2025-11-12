import 'dart:convert';
import 'dart:developer';
import 'package:ai_char_chat_app/models/movies_series.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage favorite movies/shows locally
class FavoritesService {
  static const String _favoritesKey = 'favorites_list';

  /// Add a movie/show to favorites
  Future<bool> addToFavorites(MoviesSeries movie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();

      // Check if already in favorites
      if (favorites.any((m) => m.name == movie.name)) {
        return false; // Already in favorites
      }

      favorites.add(movie);

      // Save to preferences
      final favoritesJson = favorites.map((m) => m.toMap()).toList();
      await prefs.setString(_favoritesKey, json.encode(favoritesJson));

      return true;
    } catch (e) {
      log('Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove a movie/show from favorites
  Future<bool> removeFromFavorites(String movieName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();

      favorites.removeWhere((m) => m.name == movieName);

      // Save to preferences
      final favoritesJson = favorites.map((m) => m.toMap()).toList();
      await prefs.setString(_favoritesKey, json.encode(favoritesJson));

      return true;
    } catch (e) {
      log('Error removing from favorites: $e');
      return false;
    }
  }

  /// Get all favorites
  Future<List<MoviesSeries>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesString = prefs.getString(_favoritesKey);

      if (favoritesString == null || favoritesString.isEmpty) {
        return [];
      }

      final List<dynamic> favoritesJson = json.decode(favoritesString);
      return favoritesJson
          .map((json) => MoviesSeries.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error getting favorites: $e');
      return [];
    }
  }

  /// Check if a movie/show is in favorites
  Future<bool> isFavorite(String movieName) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((m) => m.name == movieName);
    } catch (e) {
      log('Error checking favorite: $e');
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(MoviesSeries movie) async {
    final isFav = await isFavorite(movie.name);
    if (isFav) {
      return await removeFromFavorites(movie.name);
    } else {
      return await addToFavorites(movie);
    }
  }

  /// Clear all favorites
  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
  }
}
