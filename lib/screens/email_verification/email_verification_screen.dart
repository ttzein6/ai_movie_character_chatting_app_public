import 'dart:async';
import 'package:ai_char_chat_app/screens/login/components/animated_button.dart';
import 'package:ai_char_chat_app/screens/login/components/auth_background.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isResending = false;
  Timer? _timer;
  int _resendCooldown = 0;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController.forward();

    // Auto-check email verification every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerification();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;
      if (updatedUser?.emailVerified == true) {
        _timer?.cancel();
        if (mounted) {
          CherryToast.success(
            title: const Text(
              "Email Verified!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            description: const Text(
              "Your email has been successfully verified.",
              style: TextStyle(color: Colors.white70),
            ),
            backgroundColor: Colors.grey[900]!,
            animationType: AnimationType.fromTop,
            toastPosition: Position.top,
          ).show(context);

          await Future.delayed(const Duration(milliseconds: 1500));

          if (mounted) {
            // Navigate to root to trigger ApiKeyCheckWrapper rebuild
            // This will check the new verification state and proceed accordingly
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
        }
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_resendCooldown > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        if (mounted) {
          CherryToast.success(
            title: const Text(
              "Email Sent!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            description: const Text(
              "Please check your inbox and spam folder.",
              style: TextStyle(color: Colors.white70),
            ),
            backgroundColor: Colors.grey[900]!,
            animationType: AnimationType.fromTop,
            toastPosition: Position.top,
          ).show(context);

          // Start cooldown timer
          setState(() {
            _resendCooldown = 60;
          });

          Timer.periodic(const Duration(seconds: 1), (timer) {
            if (_resendCooldown > 0) {
              setState(() {
                _resendCooldown--;
              });
            } else {
              timer.cancel();
            }
          });
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
            "Failed to send verification email: ${e.toString()}",
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
          _isResending = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeController,
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
                        // Icon
                        const Icon(
                          Icons.mark_email_unread,
                          size: 80,
                          color: Color(0xFF2196F3),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        const Text(
                          'Verify Your Email',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          'We sent a verification email to:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Email
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0x4D2196F3),
                            ),
                          ),
                          child: Text(
                            user?.email ?? 'No email',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Instructions
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0x1A2196F3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0x4D2196F3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF2196F3),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Please check your inbox and click the verification link.',
                                      style: TextStyle(
                                        color: Colors.grey[300],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Don't forget to check your spam folder!",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Auto-checking indicator
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey[600]!,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Auto-checking verification status...',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Resend button
                        AnimatedButton(
                          text: _resendCooldown > 0
                              ? 'Resend in $_resendCooldown sec'
                              : 'Resend Verification Email',
                          icon: Icons.email,
                          onPressed: () {
                            if (_resendCooldown == 0) {
                              _resendVerificationEmail();
                            }
                          },
                          isLoading: _isResending,
                        ),
                        const SizedBox(height: 16),

                        // Check again button
                        TextButton.icon(
                          onPressed: _checkEmailVerification,
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text('Check Again'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Logout button
                        TextButton(
                          onPressed: _logout,
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
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
    );
  }
}
