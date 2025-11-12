import 'dart:developer';
import 'dart:ui';

import 'package:ai_char_chat_app/models/cast_character.dart';
import 'package:ai_char_chat_app/models/movies_series.dart';
import 'package:ai_char_chat_app/screens/chats/bloc/chat_bloc.dart';
import 'package:ai_char_chat_app/screens/chats/chat_screen.dart';
import 'package:ai_char_chat_app/services/favorites_service.dart';
import 'package:ai_char_chat_app/services/tmdb_service.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MovieScreen extends StatefulWidget {
  final MoviesSeries movie;
  const MovieScreen({super.key, required this.movie});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  late AnimationController _animationController;
  final TmdbService _tmdbService = TmdbService();
  final FavoritesService _favoritesService = FavoritesService();
  double _userRating = 0.0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.movie.name);
    setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    final success = await _favoritesService.toggleFavorite(widget.movie);
    if (success || !_isFavorite) {
      setState(() => _isFavorite = !_isFavorite);

      if (mounted) {
        CherryToast(
          icon: Icons.favorite,
          iconColor: _isFavorite ? Colors.red : Colors.grey,
          themeColor: _isFavorite ? Colors.red : Colors.grey,
          title: Text(
            _isFavorite ? 'Added to Favorites!' : 'Removed from Favorites',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          description: Text(
            _isFavorite
                ? '${widget.movie.name} has been added to your favorites'
                : '${widget.movie.name} has been removed from your favorites',
            style: const TextStyle(color: Colors.white70),
          ),
          backgroundColor: Colors.grey[900]!,
          animationType: AnimationType.fromTop,
          toastPosition: Position.top,
        ).show(context);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showRatingDialog() {
    double tempRating = _userRating > 0 ? _userRating : 5.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFD700), size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Rate ${widget.movie.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rating display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tempRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Slider
              Row(
                children: [
                  const Text(
                    '0.5',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Expanded(
                    child: Slider(
                      value: tempRating,
                      min: 0.5,
                      max: 10.0,
                      divisions: 19,
                      activeColor: const Color(0xFFFFD700),
                      inactiveColor: Colors.grey[700],
                      onChanged: (value) {
                        setState(() => tempRating = value);
                      },
                    ),
                  ),
                  const Text(
                    '10.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Star indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = (index + 1) * 2.0;
                  return Icon(
                    tempRating >= starValue ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFD700),
                    size: 32,
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = widget.movie.mediaType == 'tv'
                    ? await _tmdbService.rateTVShow(widget.movie.id!, tempRating)
                    : await _tmdbService.rateMovie(widget.movie.id!, tempRating);

                if (mounted) {
                  Navigator.pop(context);

                  if (success) {
                    this.setState(() => _userRating = tempRating);

                    CherryToast.success(
                      title: const Text(
                        "Rating Submitted!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      description: Text(
                        "You rated this ${widget.movie.mediaType == 'tv' ? 'show' : 'movie'} ${tempRating.toStringAsFixed(1)}/10",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      backgroundColor: Colors.grey[900]!,
                      animationType: AnimationType.fromTop,
                      toastPosition: Position.top,
                    ).show(context);
                  } else {
                    CherryToast.error(
                      title: const Text(
                        "Rating Failed",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      description: const Text(
                        "Failed to submit rating. Please try again.",
                        style: TextStyle(color: Colors.white70),
                      ),
                      backgroundColor: Colors.grey[900]!,
                      animationType: AnimationType.fromTop,
                      toastPosition: Position.top,
                    ).show(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit Rating',
                style: TextStyle(fontWeight: FontWeight.bold),
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Animated app bar with parallax effect
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.6,
                pinned: true,
                backgroundColor: Colors.black,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _scrollOffset > 200 ? 1.0 : 0.0,
                    child: Text(
                      widget.movie.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(1, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Parallax image effect with Hero animation
                      Hero(
                        tag: 'movie-${widget.movie.name}',
                        child: Transform.translate(
                          offset: Offset(0, _scrollOffset * 0.5),
                          child: CachedNetworkImage(
                            imageUrl: widget.movie.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[900],
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.9),
                            ],
                            stops: const [0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Movie details section with fade-in animation
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _animationController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        TweenAnimationBuilder<Offset>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(
                            begin: const Offset(-50, 0),
                            end: Offset.zero,
                          ),
                          curve: Curves.easeOutCubic,
                          builder: (context, offset, child) {
                            return Transform.translate(
                              offset: offset,
                              child: child,
                            );
                          },
                          child: Text(
                            widget.movie.name,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Character count badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.people,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.movie.cast.length} Characters Available',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Rating button (only show if movie has an ID)
                        if (widget.movie.id != null) ...[
                          GestureDetector(
                            onTap: _showRatingDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFFA500),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withAlpha(77),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _userRating > 0
                                        ? 'Your Rating: ${_userRating.toStringAsFixed(1)}'
                                        : 'Rate This ${widget.movie.mediaType == "tv" ? "Show" : "Movie"}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),

                        // Characters title
                        Text(
                          'Meet the Characters',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              // Character grid with staggered animation
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 600),
                        child: SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                            child: CastButton(
                              index: index,
                              cast: widget.movie.cast.elementAt(index),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: widget.movie.cast.length,
                  ),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 50),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CastButton extends StatefulWidget {
  final int index;
  final CastCharacter cast;
  const CastButton({super.key, required this.index, required this.cast});

  @override
  State<CastButton> createState() => _CastButtonState();
}

class _CastButtonState extends State<CastButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "char-chat-icon-movie-screen-${widget.cast.name}-${widget.index}",
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _pressController.forward();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _pressController.reverse();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _pressController.reverse();
          },
          onTap: () async {
            await Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    BlocProvider(
                  create: (context) => ChatBloc(),
                  child: Chat(
                    char: widget.cast,
                    heroTag:
                        "char-chat-icon-movie-screen-${widget.cast.name}-${widget.index}",
                  ),
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOutCubic;
                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.grey[850]!,
                  Colors.grey[900]!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  await Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          BlocProvider(
                        create: (context) => ChatBloc(),
                        child: Chat(
                          char: widget.cast,
                          heroTag:
                              "char-chat-icon-movie-screen-${widget.cast.name}-${widget.index}",
                        ),
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOutCubic;
                        var tween = Tween(begin: begin, end: end).chain(
                          CurveTween(curve: curve),
                        );
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Character avatar with glow effect
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2196F3).withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.cast.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white54,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Character info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.cast.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Chat with ${widget.cast.name}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Arrow icon
                      Icon(
                        Icons.chat_bubble_outline,
                        color: const Color(0xFF2196F3),
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
