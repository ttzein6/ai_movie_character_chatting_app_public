import 'package:ai_char_chat_app/models/movies_series.dart';
import 'package:ai_char_chat_app/screens/home/components/netflix_movie_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ContentRow extends StatefulWidget {
  final String title;
  final List<MoviesSeries> movies;
  final int rowIndex;

  const ContentRow({
    Key? key,
    required this.title,
    required this.movies,
    this.rowIndex = 0,
  }) : super(key: key);

  @override
  State<ContentRow> createState() => _ContentRowState();
}

class _ContentRowState extends State<ContentRow> {
  bool _isVisible = false;
  final ScrollController _scrollController = ScrollController();
  bool _showLeftArrow = false;
  bool _showRightArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateArrows);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateArrows);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateArrows() {
    setState(() {
      _showLeftArrow = _scrollController.offset > 0;
      _showRightArrow = _scrollController.offset <
          _scrollController.position.maxScrollExtent;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 600,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 600,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    return VisibilityDetector(
      key: Key('content-row-${widget.rowIndex}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_isVisible) {
          setState(() {
            _isVisible = true;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with fade-in animation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _isVisible ? 1.0 : 0.0,
                child: TweenAnimationBuilder<Offset>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(
                    begin: const Offset(-50, 0),
                    end: Offset.zero,
                  ),
                  curve: Curves.easeOutCubic,
                  builder: (context, offset, child) {
                    return Transform.translate(
                      offset: _isVisible ? offset : const Offset(-50, 0),
                      child: child,
                    );
                  },
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            ),

            // Scrollable content with navigation arrows
            SizedBox(
              height: 240,
              child: Stack(
                children: [
                  // Movie cards
                  AnimationLimiter(
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: widget.movies.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          delay: Duration(milliseconds: 50 * index),
                          child: SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                              child: NetflixMovieCard(
                                movie: widget.movies[index],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Left navigation arrow
                  if (_showLeftArrow)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: _buildNavigationArrow(
                        icon: Icons.chevron_left,
                        onPressed: _scrollLeft,
                        isLeft: true,
                      ),
                    ),

                  // Right navigation arrow
                  if (_showRightArrow)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: _buildNavigationArrow(
                        icon: Icons.chevron_right,
                        onPressed: _scrollRight,
                        isLeft: false,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationArrow({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isLeft,
  }) {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
