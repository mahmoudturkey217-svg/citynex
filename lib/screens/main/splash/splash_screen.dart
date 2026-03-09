import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/utils/cache_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Check authentication first
    final token = CacheHelper.getData(key: 'token');
    final isAuthenticated = token != null && token != '';

    if (!isAuthenticated) {
      // If not logged in, go directly to onboarding/login
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    // Only check location permissions if the user is logged in
    bool hasPermission = false;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          hasPermission = true;
        }
      }
    } catch (e) {
      // Ignore initial test failures
    }

    if (!hasPermission) {
      Navigator.pushReplacementNamed(context, '/location-permission');
      return;
    }

    // Permission granted and authenticated, proceed to home
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'assets/images/splash_screen.png',
              width: 280,
              height: 280,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.location_city,
                size: 100,
                color: Color(0xFF0D3B66),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
