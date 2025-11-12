import 'package:ai_char_chat_app/models/movies_series.dart';
import 'package:ai_char_chat_app/services/tmdb_service.dart';
import 'package:ai_char_chat_app/widgets/shimmer_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'components/featured_hero_section.dart';
import 'components/content_row.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarBackground = false;
  late AnimationController _fabController;
  final TmdbService _tmdbService = TmdbService();

  // Loading and data states
  bool _isLoading = true;
  String? _errorMessage;
  List<MoviesSeries> _popularMovies = [];
  List<MoviesSeries> _topRatedMovies = [];
  List<MoviesSeries> _topRatedTVShows = [];
  List<MoviesSeries> _tvShows = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadMovies();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show app bar background when scrolled past hero section
    if (_scrollController.offset > 100 && !_showAppBarBackground) {
      setState(() {
        _showAppBarBackground = true;
      });
      _fabController.forward();
    } else if (_scrollController.offset <= 100 && _showAppBarBackground) {
      setState(() {
        _showAppBarBackground = false;
      });
      _fabController.reverse();
    }
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch all categories in parallel
      final results = await Future.wait([
        _tmdbService.getPopularMovies(),
        _tmdbService.getTopRatedMovies(),
        _tmdbService.getTopRatedTVShows(),
        _tmdbService.getPopularTVShows(),
      ]);

      setState(() {
        _popularMovies = results[0];
        _topRatedMovies = results[1];
        _topRatedTVShows = results[2];
        _tvShows = results[3];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Group movies into different categories
  List<MoviesSeries> get featuredMovies {
    // Mix popular and top rated for featured section
    final combined = [..._popularMovies, ..._topRatedMovies];
    return combined.take(5).toList();
  }

  List<MoviesSeries> get popularMovies => _popularMovies;
  List<MoviesSeries> get topRatedMoviesList => _topRatedMovies;
  List<MoviesSeries> get topRatedTVShowsList => _topRatedTVShows;
  List<MoviesSeries> get popularTVShows => _tvShows;

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const ShimmerHeroSection(),
          const SizedBox(height: 20),
          const ShimmerContentRow(),
          const SizedBox(height: 20),
          const ShimmerContentRow(),
          const SizedBox(height: 20),
          const ShimmerContentRow(),
          const SizedBox(height: 20),
          const ShimmerContentRow(),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFF2196F3),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load content',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMovies,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: _showAppBarBackground
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.0),
                    ],
                  )
                : null,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: null,
          ),
        ),
      ),
      body: Container(
        color: Colors.black,
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Featured Hero Section
                      SliverToBoxAdapter(
                        child: FeaturedHeroSection(
                          featuredMovies: featuredMovies,
                        ),
                      ),

                      // Content Rows with staggered animations
                      SliverToBoxAdapter(
                        child: AnimationLimiter(
                          child: Column(
                            children: AnimationConfiguration.toStaggeredList(
                              duration: const Duration(milliseconds: 600),
                              childAnimationBuilder: (widget) => SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: widget,
                                ),
                              ),
                              children: [
                                const SizedBox(height: 20),
                                if (popularMovies.isNotEmpty)
                                  ContentRow(
                                    title: 'Popular Movies',
                                    movies: popularMovies,
                                    rowIndex: 0,
                                  ),
                                if (topRatedMoviesList.isNotEmpty)
                                  ContentRow(
                                    title: 'Top Rated Movies',
                                    movies: topRatedMoviesList,
                                    rowIndex: 1,
                                  ),
                                if (topRatedTVShowsList.isNotEmpty)
                                  ContentRow(
                                    title: 'Top Rated TV Shows',
                                    movies: topRatedTVShowsList,
                                    rowIndex: 2,
                                  ),
                                if (popularTVShows.isNotEmpty)
                                  ContentRow(
                                    title: 'Popular TV Shows',
                                    movies: popularTVShows,
                                    rowIndex: 3,
                                  ),
                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
      // Floating scroll to top button
      floatingActionButton: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabController.value,
            child: Opacity(
              opacity: _fabController.value,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00F5FF),
                Color(0xFF0066FF),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F5FF).withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOutCubic,
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
