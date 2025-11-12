import 'dart:math';
import 'package:ai_char_chat_app/models/api/tmdb_cast.dart';
import 'package:ai_char_chat_app/models/api/tmdb_movie.dart';
import 'package:ai_char_chat_app/models/cast_character.dart';
import 'package:ai_char_chat_app/models/movies_series.dart';
import 'package:ai_char_chat_app/services/api_key_service.dart';
import 'package:dio/dio.dart';

class TmdbService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  final Dio _dio = Dio();
  final ApiKeyService _apiKeyService = ApiKeyService();

  TmdbService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  /// Get API key from storage
  Future<String?> _getApiKey() async {
    return await _apiKeyService.getTmdbApiKey();
  }

  /// Get popular movies
  Future<List<MoviesSeries>> getPopularMovies({int page = 1}) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null) {
        throw Exception('TMDb API key not found');
      }

      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {
          'api_key': apiKey,
          'page': page,
          'language': 'en-US',
        },
      );

      final List results = response.data['results'] ?? [];
      List<MoviesSeries> moviesList = [];

      // Fetch cast for first 10 movies to avoid rate limits
      for (var i = 0; i < min(10, results.length); i++) {
        final movie = TmdbMovie.fromJson(results[i]);
        final cast = await getMovieCast(movie.id);
        if (cast.isNotEmpty) {
          moviesList.add(movie.toMoviesSeries(cast));
        }
      }

      return moviesList;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to fetch popular movies: $e');
    }
  }

  /// Get top rated movies
  Future<List<MoviesSeries>> getTopRatedMovies({int page = 1}) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null) {
        throw Exception('TMDb API key not found');
      }

      final response = await _dio.get(
        '/movie/top_rated',
        queryParameters: {
          'api_key': apiKey,
          'page': page,
          'language': 'en-US',
        },
      );

      final List results = response.data['results'] ?? [];
      List<MoviesSeries> moviesList = [];

      for (var i = 0; i < min(10, results.length); i++) {
        final movie = TmdbMovie.fromJson(results[i]);
        final cast = await getMovieCast(movie.id);
        if (cast.isNotEmpty) {
          moviesList.add(movie.toMoviesSeries(cast));
        }
      }

      return moviesList;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to fetch top rated movies: $e');
    }
  }

  /// Get now playing movies
  Future<List<MoviesSeries>> getNowPlayingMovies({int page = 1}) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null) {
        throw Exception('TMDb API key not found');
      }

      final response = await _dio.get(
        '/movie/now_playing',
        queryParameters: {
          'api_key': apiKey,
          'page': page,
          'language': 'en-US',
        },
      );

      final List results = response.data['results'] ?? [];
      List<MoviesSeries> moviesList = [];

      for (var i = 0; i < min(10, results.length); i++) {
        final movie = TmdbMovie.fromJson(results[i]);
        final cast = await getMovieCast(movie.id);
        if (cast.isNotEmpty) {
          moviesList.add(movie.toMoviesSeries(cast));
        }
      }

      return moviesList;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to fetch now playing movies: $e');
    }
  }

  /// Get movie cast
  Future<List<CastCharacter>> getMovieCast(int movieId) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null) {
        throw Exception('TMDb API key not found');
      }

      final response = await _dio.get(
        '/movie/$movieId/credits',
        queryParameters: {
          'api_key': apiKey,
          'language': 'en-US',
        },
      );

      final List castList = response.data['cast'] ?? [];

      // Take top 10 cast members and convert to CastCharacter
      return castList
          .take(10)
          .map((json) => TmdbCast.fromJson(json).toCastCharacter())
          .toList();
    } on DioException catch (e) {
      // Return empty list on error to avoid blocking movie loading
      print('Error fetching cast for movie $movieId: $e');
      return [];
    } catch (e) {
      print('Error fetching cast for movie $movieId: $e');
      return [];
    }
  }

  /// Get popular TV shows
  Future<List<MoviesSeries>> getPopularTVShows({int page = 1}) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null) {
        throw Exception('TMDb API key not found');
      }

      final response = await _dio.get(
        '/tv/popular',
        queryParameters: {
          'api_key': apiKey,
          'page': page,
          'language': 'en-US',
        },
      );

      final List results = response.data['results'] ?? [];
      List<MoviesSeries> tvShowsList = [];

      for (var i = 0; i < min(10, results.length); i++) {
        final show = results[i];
        final cast = await getTVShowCast(show['id']);
        if (cast.isNotEmpty) {
          final showName = show['name'] ?? 'Unknown';
          // Update each character's movieName
          for (var character in cast) {
            character.movieName = showName;
          }
          tvShowsList.add(MoviesSeries(
            name: showName,
            imageUrl: _getFullImageUrl(show['poster_path']),
            cast: cast,
            id: show['id'],
            mediaType: 'tv',
          ));
        }
      }

      return tvShowsList;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to fetch popular TV shows: $e');
    }
  }

  /// Get top rated TV shows
  Future<List<MoviesSeries>> getTopRatedTVShows({int page = 1}) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null) {
        throw Exception('TMDb API key not found');
      }

      final response = await _dio.get(
        '/tv/top_rated',
        queryParameters: {
          'api_key': apiKey,
          'page': page,
          'language': 'en-US',
        },
      );

      final List results = response.data['results'] ?? [];
      List<MoviesSeries> tvShowsList = [];

      for (var i = 0; i < min(10, results.length); i++) {
        final show = results[i];
        final cast = await getTVShowCast(show['id']);
        if (cast.isNotEmpty) {
          final showName = show['name'] ?? 'Unknown';
          // Update each character's movieName
          for (var character in cast) {
            character.movieName = showName;
          }
          tvShowsList.add(MoviesSeries(
            name: showName,
            imageUrl: _getFullImageUrl(show['poster_path']),
            cast: cast,
            id: show['id'],
            mediaType: 'tv',
          ));
        }
      }

      return tvShowsList;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to fetch top rated TV shows: $e');
    }
  }

  /// Get TV show cast
  Future<List<CastCharacter>> getTVShowCast(int tvId) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null) {
        throw Exception('TMDb API key not found');
      }

      final response = await _dio.get(
        '/tv/$tvId/credits',
        queryParameters: {
          'api_key': apiKey,
          'language': 'en-US',
        },
      );

      final List castList = response.data['cast'] ?? [];

      return castList
          .take(10)
          .map((json) => TmdbCast.fromJson(json).toCastCharacter())
          .toList();
    } on DioException catch (e) {
      print('Error fetching cast for TV show $tvId: $e');
      return [];
    } catch (e) {
      print('Error fetching cast for TV show $tvId: $e');
      return [];
    }
  }

  /// Search movies and TV shows using multi-search endpoint
  Future<List<MoviesSeries>> searchMovies(String query) async {
    try {
      if (query.isEmpty) return [];

      final apiKey = await _getApiKey();
      if (apiKey == null) {
        throw Exception('TMDb API key not found');
      }

      // Use multi-search to search both movies and TV shows
      final response = await _dio.get(
        '/search/multi',
        queryParameters: {
          'api_key': apiKey,
          'query': query,
          'language': 'en-US',
          'page': 1,
          'include_adult': false,
        },
      );

      final List results = response.data['results'] ?? [];
      List<MoviesSeries> mediaList = [];

      for (var i = 0; i < min(20, results.length); i++) {
        final item = results[i];
        final mediaType = item['media_type'];

        // Skip person results, only process movies and TV shows
        if (mediaType != 'movie' && mediaType != 'tv') continue;

        try {
          if (mediaType == 'movie') {
            final movie = TmdbMovie.fromJson(item);
            final cast = await getMovieCast(movie.id);
            if (cast.isNotEmpty) {
              mediaList.add(movie.toMoviesSeries(cast));
            }
          } else if (mediaType == 'tv') {
            final tvId = item['id'];
            final cast = await getTVShowCast(tvId);
            if (cast.isNotEmpty) {
              final showName = item['name'] ?? 'Unknown';
              // Update each character's movieName
              for (var character in cast) {
                character.movieName = showName;
              }
              mediaList.add(MoviesSeries(
                name: showName,
                imageUrl: _getFullImageUrl(item['poster_path']),
                cast: cast,
                id: tvId,
                mediaType: 'tv',
              ));
            }
          }
        } catch (e) {
          // Skip this item if there's an error
          print('Error processing search result: $e');
          continue;
        }
      }

      return mediaList;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Failed to search: $e');
    }
  }

  String _getFullImageUrl(String? path, {String size = 'w780'}) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/500x750?text=No+Image';
    }
    return 'https://image.tmdb.org/t/p/$size$path';
  }

  /// Rate a movie (value between 0.5 and 10.0)
  Future<bool> rateMovie(int movieId, double rating) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null) {
        throw Exception('TMDb API key not found');
      }

      // Rating must be between 0.5 and 10.0
      if (rating < 0.5 || rating > 10.0) {
        throw Exception('Rating must be between 0.5 and 10.0');
      }

      final response = await _dio.post(
        '/movie/$movieId/rating',
        queryParameters: {
          'api_key': apiKey,
        },
        data: {
          'value': rating,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('Error rating movie: $e');
      return false;
    } catch (e) {
      print('Error rating movie: $e');
      return false;
    }
  }

  /// Rate a TV show (value between 0.5 and 10.0)
  Future<bool> rateTVShow(int tvId, double rating) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null) {
        throw Exception('TMDb API key not found');
      }

      // Rating must be between 0.5 and 10.0
      if (rating < 0.5 || rating > 10.0) {
        throw Exception('Rating must be between 0.5 and 10.0');
      }

      final response = await _dio.post(
        '/tv/$tvId/rating',
        queryParameters: {
          'api_key': apiKey,
        },
        data: {
          'value': rating,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('Error rating TV show: $e');
      return false;
    } catch (e) {
      print('Error rating TV show: $e');
      return false;
    }
  }

  /// Delete movie rating
  Future<bool> deleteMovieRating(int movieId) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null) {
        throw Exception('TMDb API key not found');
      }

      final response = await _dio.delete(
        '/movie/$movieId/rating',
        queryParameters: {
          'api_key': apiKey,
        },
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error deleting movie rating: $e');
      return false;
    } catch (e) {
      print('Error deleting movie rating: $e');
      return false;
    }
  }

  /// Delete TV show rating
  Future<bool> deleteTVShowRating(int tvId) async {
    try {
      final apiKey = await _getApiKey();
      if (apiKey == null) {
        throw Exception('TMDb API key not found');
      }

      final response = await _dio.delete(
        '/tv/$tvId/rating',
        queryParameters: {
          'api_key': apiKey,
        },
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      print('Error deleting TV show rating: $e');
      return false;
    } catch (e) {
      print('Error deleting TV show rating: $e');
      return false;
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return 'Invalid TMDb API key. Please check your API key in settings.';
        }
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error. Please check your connection.';
    }
  }
}
