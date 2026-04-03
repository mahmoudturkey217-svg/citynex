import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/widgets/shared_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('About CityNex'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: AppDimensions.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_city, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'CityNex',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 48),
            const AppCard(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                   Text(
                    'Our Mission',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'CityNex bridges the gap between citizens and administration. We believe that empowering residents with the right tools creates safer, cleaner, and highly optimized communities.\n\nFrom potholes to malfunctioning street lights, CityNex allows you to report issues in seconds, track their status, and engage with administrators to resolve them quickly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Developed by ', style: TextStyle(color: AppColors.textSecondary)),
                Text('Zeyad Mahmoud', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              '© ${DateTime.now().year} CityNex. All rights reserved.',
              style: const TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
