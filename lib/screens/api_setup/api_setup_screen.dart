import 'package:ai_char_chat_app/screens/login/components/animated_button.dart';
import 'package:ai_char_chat_app/screens/login/components/auth_background.dart';
import 'package:ai_char_chat_app/screens/login/components/custom_text_field.dart';
import 'package:ai_char_chat_app/screens/main_screen.dart';
import 'package:ai_char_chat_app/services/api_key_service.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiSetupScreen extends StatefulWidget {
  final bool isRequired;
  const ApiSetupScreen({super.key, this.isRequired = true});

  @override
  State<ApiSetupScreen> createState() => _ApiSetupScreenState();
}

class _ApiSetupScreenState extends State<ApiSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tmdbKeyController = TextEditingController();
  final TextEditingController _geminiKeyController = TextEditingController();
  final ApiKeyService _apiKeyService = ApiKeyService();
  bool _isLoading = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController.forward();
    _loadExistingKeys();
  }

  Future<void> _loadExistingKeys() async {
    final tmdbKey = await _apiKeyService.getTmdbApiKey();
    final geminiKey = await _apiKeyService.getGeminiApiKey();

    if (tmdbKey != null) {
      _tmdbKeyController.text = tmdbKey;
    }
    if (geminiKey != null) {
      _geminiKeyController.text = geminiKey;
    }
  }

  @override
  void dispose() {
    _tmdbKeyController.dispose();
    _geminiKeyController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiKeyService.saveTmdbApiKey(_tmdbKeyController.text.trim());
      await _apiKeyService.saveGeminiApiKey(_geminiKeyController.text.trim());
      await _apiKeyService.markSetupComplete();

      if (mounted) {
        CherryToast.success(
          title: const Text(
            "API Keys Saved!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          description: const Text(
            "Your keys are stored securely on your device.",
            style: TextStyle(color: Colors.white70),
          ),
          backgroundColor: Colors.grey[900]!,
          animationType: AnimationType.fromTop,
          toastPosition: Position.top,
        ).show(context);

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          if (widget.isRequired) {
            // Initial setup - navigate to main screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          } else {
            // Coming from settings - just go back
            Navigator.pop(context);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        CherryToast.error(
          title: const Text(
            "Error",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          description: Text(
            "Failed to save API keys: $e",
            style: const TextStyle(color: Colors.white70),
          ),
          backgroundColor: Colors.grey[900]!,
          animationType: AnimationType.fromTop,
          toastPosition: Position.top,
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isRequired ? null : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: !widget.isRequired,
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeController,
                child: Form(
                  key: _formKey,
                  child: AnimationLimiter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 600),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: widget,
                          ),
                        ),
                        children: [
                          // Title
                          const Icon(
                            Icons.key,
                            size: 64,
                            color: Color(0xFF2196F3),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'API Keys Required',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'This app is 100% free. Please provide your own API keys to get started.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Privacy notice
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF2196F3).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lock,
                                  color: Color(0xFF2196F3),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your API keys are stored ONLY on your device. We never send them to any server.',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // TMDb API Key section
                          Text(
                            '1. TMDb API Key',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[200],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'For fetching movies and TV shows',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 12),

                          CustomTextField(
                            controller: _tmdbKeyController,
                            hintText: 'Enter your TMDb API key',
                            label: 'TMDb API Key',
                            icon: Icons.movie,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your TMDb API key';
                              }
                              if (!_apiKeyService
                                  .isValidTmdbKey(value.trim())) {
                                return 'Invalid TMDb API key format (should be 32 characters)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextButton.icon(
                            onPressed: () => _launchUrl(
                                'https://www.themoviedb.org/settings/api'),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Get TMDb API Key (Free)'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2196F3),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Gemini API Key section
                          Text(
                            '2. Gemini API Key',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[200],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'For AI character conversations',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 12),

                          CustomTextField(
                            controller: _geminiKeyController,
                            hintText: 'Enter your Gemini API key',
                            label: 'Gemini API Key',
                            icon: Icons.psychology,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Gemini API key';
                              }
                              if (!_apiKeyService
                                  .isValidGeminiKey(value.trim())) {
                                return 'Invalid Gemini API key format (should start with AIza)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          TextButton.icon(
                            onPressed: () => _launchUrl(
                                'https://aistudio.google.com/app/api-keys'),
                            icon: const Icon(Icons.open_in_new, size: 16),
                            label: const Text('Get Gemini API Key (Free)'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF2196F3),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Save button
                          AnimatedButton(
                            text: 'Save & Continue',
                            icon: Icons.check,
                            onPressed: _saveAndContinue,
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: 24),

                          // Help text
                          Text(
                            'Both API keys are free. Click the links above to get yours.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
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
