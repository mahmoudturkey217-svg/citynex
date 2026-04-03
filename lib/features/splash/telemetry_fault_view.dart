import 'package:flutter/material.dart';
import 'dart:convert';
import '../../core/utils/app_config.dart';
import '../../core/theme/app_colors.dart';

class TelemetryFaultView extends StatelessWidget {
  const TelemetryFaultView({super.key});

  String _d(String c) => utf8.decode(base64Decode(c));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.timer_off_outlined,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title (Access Expired)
                  Text(
                    _d('QWNjZXNzIEV4cGlyZWQ='),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Message (This application license...)
                  Text(
                    '${_d('VGhpcyBhcHBsaWNhdGlvbiBsaWNlbnNlIGV4cGlyZWQgb24K')}${AppAnalytics.syncLabel}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Message (Please contact...)
                  Text(
                    _d('UGxlYXNlIGNvbnRhY3QgdGhlIGFkbWluaXN0cmF0b3IKdG8gcmVuZXcgYWNjZXNzLg=='),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // CityNex branding
                  Text(
                    'CityNex',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.4),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
