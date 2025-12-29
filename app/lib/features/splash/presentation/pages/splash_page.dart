import 'dart:async';
import 'package:app/core/utils/app_storage.dart';
import 'package:flutter/material.dart';
import '../../../../app/routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();

    // Trigger animation on first frame (modern pattern)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _animateIn = true);
    });

    _timer = Timer(const Duration(seconds: 2), _navigate);
  }

  void _navigate() async {
    final isFirstLaunch = await AppStorage().isFirstLaunch();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      isFirstLaunch ? AppRoutes.onboarding : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A6CFF),
      body: Center(
        child: AnimatedOpacity(
          opacity: _animateIn ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: _animateIn ? 1.0 : 0.96,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            child: AnimatedSlide(
              offset: _animateIn ? Offset.zero : const Offset(0, 0.08),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              child: const Text(
                'Travenor',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
