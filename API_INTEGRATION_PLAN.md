# API Integration Plan for Movies/TV Shows with Characters

## Overview
This document outlines the complete plan to integrate external APIs for fetching movies, TV shows, and their characters to replace hardcoded data.

---

## Phase 1: API Selection & Setup

### Recommended APIs

#### Option 1: TMDb API (The Movie Database) - **PRIMARY CHOICE**
- **Best for:** Movies with cast information
- **Cost:** FREE (up to 40 requests per 10 seconds)
- **Sign up:** https://www.themoviedb.org/signup
- **Docs:** https://developer.themoviedb.org/reference/intro/getting-started

**Why TMDb:**
- ✅ Free tier is generous
- ✅ Comprehensive movie/TV data
- ✅ Cast and crew information with photos
- ✅ High-quality images
- ✅ Active maintenance
- ✅ Easy to use

**Key Endpoints:**
```
GET /movie/popular - Popular movies
GET /tv/popular - Popular TV shows
GET /movie/{movie_id}/credits - Cast for movie
GET /tv/{tv_id}/credits - Cast for TV show
GET /person/{person_id} - Person details
GET /search/movie - Search movies
GET /search/tv - Search TV shows
```

#### Option 2: TVMaze API - **SECONDARY FOR TV SHOWS**
- **Best for:** TV shows with detailed character data
- **Cost:** 100% FREE, no API key needed
- **Docs:** https://www.tvmaze.com/api

**Why TVMaze:**
- ✅ Completely free
- ✅ No API key required
- ✅ Excellent TV show data
- ✅ Character-level information
- ✅ Episode details

**Key Endpoints:**
```
GET /search/shows - Search TV shows
GET /shows/{id} - Show details
GET /shows/{id}/cast - Cast with characters
GET /people/{id} - Person details
```

---

## Phase 2: Implementation Steps

### Step 1: Add Dependencies
```yaml
# pubspec.yaml
dependencies:
  http: ^1.2.0  # For API calls
  # OR
  dio: ^5.4.0   # More advanced HTTP client (recommended)
```

### Step 2: Create Environment Configuration
```dart
// lib/config/api_config.dart
class ApiConfig {
  // TMDb
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbApiKey = 'YOUR_API_KEY_HERE';  // Add to .env
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  // TVMaze
  static const String tvMazeBaseUrl = 'https://api.tvmaze.com';

  // Image sizes
  static const String posterSizeSmall = 'w342';
  static const String posterSizeLarge = 'w780';
  static const String backdropSize = 'w1280';
  static const String profileSize = 'w185';
}
```

### Step 3: Create Response Models

#### TMDb Movie Model
```dart
// lib/models/api/tmdb_movie.dart
class TmdbMovie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String releaseDate;

  // Convert to MoviesSeries
  MoviesSeries toMoviesSeries(List<CastCharacter> cast) {
    return MoviesSeries(
      name: title,
      imageUrl: getFullImageUrl(posterPath),
      cast: cast,
    );
  }

  String getFullImageUrl(String? path) {
    if (path == null) return '';
    return '${ApiConfig.tmdbImageBaseUrl}/${ApiConfig.posterSizeLarge}$path';
  }
}
```

#### TMDb Cast Model
```dart
// lib/models/api/tmdb_cast.dart
class TmdbCast {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  // Convert to CastCharacter
  CastCharacter toCastCharacter() {
    return CastCharacter(
      name: character.isNotEmpty ? character : name,
      imageUrl: getFullImageUrl(profilePath),
    );
  }
}
```

### Step 4: Create API Service Classes

#### TMDb Service
```dart
// lib/services/tmdb_service.dart
class TmdbService {
  final Dio _dio;

  TmdbService() : _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.tmdbBaseUrl,
    queryParameters: {'api_key': ApiConfig.tmdbApiKey},
  ));

  // Get popular movies
  Future<List<MoviesSeries>> getPopularMovies({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/movie/popular',
        queryParameters: {'page': page},
      );

      final List movies = response.data['results'];
      List<MoviesSeries> moviesList = [];

      // Fetch cast for each movie (first 10 to avoid rate limits)
      for (var i = 0; i < min(10, movies.length); i++) {
        final movie = TmdbMovie.fromJson(movies[i]);
        final cast = await getMovieCast(movie.id);
        moviesList.add(movie.toMoviesSeries(cast));
      }

      return moviesList;
    } catch (e) {
      print('Error fetching popular movies: $e');
      return [];
    }
  }

  // Get movie cast
  Future<List<CastCharacter>> getMovieCast(int movieId) async {
    try {
      final response = await _dio.get('/movie/$movieId/credits');
      final List castList = response.data['cast'];

      // Take top 10 cast members
      return castList
          .take(10)
          .map((json) => TmdbCast.fromJson(json).toCastCharacter())
          .toList();
    } catch (e) {
      print('Error fetching movie cast: $e');
      return [];
    }
  }

  // Get popular TV shows
  Future<List<MoviesSeries>> getPopularTVShows({int page = 1}) async {
    // Similar implementation
  }

  // Search movies
  Future<List<MoviesSeries>> searchMovies(String query) async {
    // Similar implementation
  }
}
```

#### TVMaze Service (Optional)
```dart
// lib/services/tvmaze_service.dart
class TvMazeService {
  final Dio _dio;

  TvMazeService() : _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.tvMazeBaseUrl,
  ));

  Future<List<MoviesSeries>> searchShows(String query) async {
    // Implementation
  }

  Future<List<CastCharacter>> getShowCast(int showId) async {
    // Implementation
  }
}
```

### Step 5: Create a Content Provider (State Management)

#### Using Provider Pattern
```dart
// lib/providers/content_provider.dart
class ContentProvider extends ChangeNotifier {
  final TmdbService _tmdbService = TmdbService();

  List<MoviesSeries> _popularMovies = [];
  List<MoviesSeries> _trendingMovies = [];
  List<MoviesSeries> _tvShows = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<MoviesSeries> get popularMovies => _popularMovies;
  List<MoviesSeries> get trendingMovies => _trendingMovies;
  List<MoviesSeries> get tvShows => _tvShows;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all content
  Future<void> fetchContent() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch in parallel
      final results = await Future.wait([
        _tmdbService.getPopularMovies(page: 1),
        _tmdbService.getPopularMovies(page: 2),
        _tmdbService.getPopularTVShows(page: 1),
      ]);

      _popularMovies = results[0];
      _trendingMovies = results[1];
      _tvShows = results[2];

    } catch (e) {
      _error = 'Failed to load content: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search
  Future<List<MoviesSeries>> search(String query) async {
    return await _tmdbService.searchMovies(query);
  }
}
```

### Step 6: Update HomePage to Use API Data

```dart
// lib/screens/home/home_page.dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ContentProvider _contentProvider = ContentProvider();

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    await _contentProvider.fetchContent();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_contentProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_contentProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_contentProvider.error!),
            ElevatedButton(
              onPressed: _loadContent,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      // ... existing scaffold code
      body: CustomScrollView(
        slivers: [
          // Featured from first page
          SliverToBoxAdapter(
            child: FeaturedHeroSection(
              featuredMovies: _contentProvider.popularMovies.take(5).toList(),
            ),
          ),

          // Content rows
          SliverToBoxAdapter(
            child: Column(
              children: [
                ContentRow(
                  title: 'Popular Movies',
                  movies: _contentProvider.popularMovies,
                  rowIndex: 0,
                ),
                ContentRow(
                  title: 'Trending Now',
                  movies: _contentProvider.trendingMovies,
                  rowIndex: 1,
                ),
                ContentRow(
                  title: 'TV Shows',
                  movies: _contentProvider.tvShows,
                  rowIndex: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Phase 3: Caching & Performance

### Local Caching Strategy

```dart
// lib/services/cache_service.dart
class CacheService {
  static const String _cacheKey = 'movies_cache';
  static const Duration _cacheExpiry = Duration(hours: 6);

  // Save to cache
  Future<void> cacheMovies(List<MoviesSeries> movies) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'movies': movies.map((m) => m.toJson()).toList(),
    };
    await prefs.setString(_cacheKey, jsonEncode(data));
  }

  // Load from cache
  Future<List<MoviesSeries>?> getCachedMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);

    if (cached == null) return null;

    final data = jsonDecode(cached);
    final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);

    // Check if cache is expired
    if (DateTime.now().difference(timestamp) > _cacheExpiry) {
      return null;
    }

    return (data['movies'] as List)
        .map((m) => MoviesSeries.fromJson(m))
        .toList();
  }
}
```

### Image Caching
Already handled by `cached_network_image` package ✅

---

## Phase 4: Error Handling & Edge Cases

### Error Handling
```dart
// lib/utils/api_error_handler.dart
class ApiErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.connectionTimeout:
          return 'Connection timeout. Please check your internet.';
        case DioErrorType.sendTimeout:
          return 'Send timeout. Please try again.';
        case DioErrorType.receiveTimeout:
          return 'Receive timeout. Server is slow.';
        case DioErrorType.badResponse:
          return 'Server error: ${error.response?.statusCode}';
        case DioErrorType.cancel:
          return 'Request cancelled.';
        default:
          return 'Network error. Please check your connection.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
```

### Retry Logic
```dart
Future<T> retryRequest<T>(
  Future<T> Function() request, {
  int maxAttempts = 3,
  Duration delay = const Duration(seconds: 2),
}) async {
  int attempts = 0;

  while (attempts < maxAttempts) {
    try {
      return await request();
    } catch (e) {
      attempts++;
      if (attempts >= maxAttempts) rethrow;
      await Future.delayed(delay * attempts);
    }
  }

  throw Exception('Max retry attempts reached');
}
```

---

## Phase 5: Testing

### Test Cases
1. ✅ API connection test
2. ✅ Movie fetching
3. ✅ Cast fetching
4. ✅ Error handling
5. ✅ Cache loading/saving
6. ✅ Offline mode
7. ✅ Rate limiting

---

## Phase 6: Migration Checklist

- [ ] Sign up for TMDb API key
- [ ] Add http/dio dependency
- [ ] Create API config file
- [ ] Create response models
- [ ] Implement TMDb service
- [ ] Create content provider
- [ ] Update HomePage to use API
- [ ] Implement caching
- [ ] Add error handling
- [ ] Add loading states
- [ ] Test with real data
- [ ] Remove hardcoded movies list
- [ ] Add pull-to-refresh
- [ ] Add search functionality

---

## Estimated Timeline

- **Phase 1 (Setup):** 1 hour
- **Phase 2 (Implementation):** 3-4 hours
- **Phase 3 (Caching):** 1 hour
- **Phase 4 (Error Handling):** 1 hour
- **Phase 5 (Testing):** 1 hour
- **Total:** ~8 hours

---

## Benefits

✅ Real, up-to-date content
✅ High-quality images
✅ Thousands of movies/shows
✅ Professional character data
✅ Search functionality
✅ Always fresh content
✅ Scalable solution

---

## Next Steps

1. **Get TMDb API Key:** Go to https://www.themoviedb.org/settings/api
2. **Create `.env` file:** Store API key securely
3. **Add dependencies:** Add dio and flutter_dotenv
4. **Start implementation:** Follow Phase 2 steps

Ready to start implementation? 🚀
