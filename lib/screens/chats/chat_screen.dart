import 'dart:math' as math;

import 'package:ai_char_chat_app/models/cast_character.dart';
import 'package:ai_char_chat_app/models/message.dart';
import 'package:ai_char_chat_app/screens/chats/bloc/chat_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Chat extends StatefulWidget {
  String heroTag;
  CastCharacter? char;
  Chat({super.key, required this.heroTag, this.char});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  bool showScrollBottomButton = false;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge == true &&
          _scrollController.position.pixels == 0 &&
          showScrollBottomButton == true) {
        setState(() => showScrollBottomButton = false);
      } else if (!(_scrollController.position.atEdge == true &&
              _scrollController.position.pixels == 0) &&
          showScrollBottomButton == false) {
        setState(() => showScrollBottomButton = true);
      }
    });

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),

          // Particle effects
          _buildParticleEffect(),

          // Main chat content
          SafeArea(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is ChatInitial || state is ChatLoading) {
                  context
                      .read<ChatBloc>()
                      .add(InitializeChat(character: widget.char!));
                  return _buildLoadingState();
                } else if (state is ChatLoaded) {
                  List<Message> messages = state.chat.messages ?? [];
                  messages = messages.reversed.toList();
                  return Column(
                    children: [
                      Expanded(
                        child: messages.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 20,
                                ),
                                controller: _scrollController,
                                reverse: true,
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  return _buildMessageBubble(
                                    messages[index],
                                    index,
                                    messages.first.isSending == true,
                                  );
                                },
                              ),
                      ),
                      _buildMessageInput(
                        messages.isNotEmpty && messages.first.isSending == true,
                      ),
                    ],
                  );
                }
                return Container();
              },
            ),
          ),

          // Scroll to bottom button
          _buildScrollToBottomButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.3),
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Row(
        children: [
          Hero(
            tag: widget.heroTag,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F5FF).withOpacity(0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  widget.char?.imageUrl ??
                      "https://via.placeholder.com/50",
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey[800],
                    child: const Icon(Icons.person, color: Colors.white54),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.char?.name ?? "AI Character",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.char?.movieName ?? "",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_vert, color: Colors.white),
          ),
          onSelected: (value) {
            if (value == 'clear') {
              context.read<ChatBloc>().add(ClearChat());
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_sweep, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Clear Chat'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF0A0E27),
                  const Color(0xFF1A1A40),
                  (_backgroundController.value * 2) % 1,
                )!,
                Color.lerp(
                  const Color(0xFF1A1A40),
                  const Color(0xFF2D1B69),
                  (_backgroundController.value * 2) % 1,
                )!,
                Color.lerp(
                  const Color(0xFF2D1B69),
                  const Color(0xFF0A0E27),
                  (_backgroundController.value * 2) % 1,
                )!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleEffect() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            progress: _particleController.value,
          ),
          child: Container(),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00F5FF).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00F5FF)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Connecting to ${widget.char?.name ?? "AI"}...',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00F5FF).withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 80,
              color: Color(0xFF00F5FF),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start chatting with ${widget.char?.name ?? "AI"}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Send a message to begin the conversation',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, int index, bool isSending) {
    final isUser = message.sender == true;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            bottom: 12,
            left: isUser ? 60 : 0,
            right: isUser ? 0 : 60,
          ),
          child: Column(
            crossAxisAlignment:
                isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: isUser
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF00F5FF),
                            Color(0xFF0066FF),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isUser
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isUser
                          ? const Color(0xFF00F5FF).withOpacity(0.3)
                          : Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: isUser ? 2 : 0,
                    ),
                  ],
                ),
                child: Text(
                  message.messageText ?? "",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
              if (isUser && isSending && index == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ThreeDotsLoadingIndicator(
                        dotColor: const Color(0xFF00F5FF),
                        dotSize: 4,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Sending',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isSending) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 10,
        top: 10,
        right: 16,
        left: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: TextField(
                readOnly: isSending,
                controller: _textController,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
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
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: isSending
                    ? null
                    : () {
                        if (_textController.text.trim().isNotEmpty) {
                          context
                              .read<ChatBloc>()
                              .add(SendMessage(text: _textController.text.trim()));
                          _textController.clear();
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return Positioned(
      bottom: 100,
      right: 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: showScrollBottomButton ? 1 : 0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: showScrollBottomButton ? 1 : 0,
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
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  _scrollController.animateTo(
                    0.0,
                    curve: Curves.easeOutCubic,
                    duration: const Duration(milliseconds: 300),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(
                    Icons.keyboard_double_arrow_down_rounded,
                    color: Colors.white,
                    size: 24,
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

class ParticlePainter extends CustomPainter {
  final double progress;

  ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final yBase = random.nextDouble() * size.height;
      final y = (yBase + (progress * size.height * 0.3)) % size.height;
      final radius = random.nextDouble() * 2 + 1;

      paint.color = Color.lerp(
        const Color(0xFF00F5FF),
        const Color(0xFF0066FF),
        random.nextDouble(),
      )!.withOpacity(0.3);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class ThreeDotsLoadingIndicator extends StatefulWidget {
  final Color dotColor;
  final double dotSpacing;
  final double dotSize;

  const ThreeDotsLoadingIndicator({
    super.key,
    this.dotColor = Colors.blueGrey,
    this.dotSpacing = 2.0,
    this.dotSize = 5.0,
  });

  @override
  _ThreeDotsLoadingIndicatorState createState() =>
      _ThreeDotsLoadingIndicatorState();
}

class _ThreeDotsLoadingIndicatorState extends State<ThreeDotsLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildDot(0),
        SizedBox(width: widget.dotSpacing),
        _buildDot(1),
        SizedBox(width: widget.dotSpacing),
        _buildDot(2),
      ],
    );
  }

  Widget _buildDot(int index) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.5,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          (index / 3),
          (index / 3) + 0.3,
          curve: Curves.easeInOut,
        ),
      )),
      child: Container(
        width: widget.dotSize,
        height: widget.dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.dotColor,
          boxShadow: [
            BoxShadow(
              color: widget.dotColor.withOpacity(0.5),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
