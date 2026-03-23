import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'About CityNex',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D2137),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // App Logo / Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0D2137).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_city_rounded,
                size: 56,
                color: Color(0xFF0D2137),
              ),
            ),
            const SizedBox(height: 16),

            // App name
            const Text(
              'CityNex',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2137),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Smart Neighborhood Reporting',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),

            // Version badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2ECC71),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Description card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About the App',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D26),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'CityNex empowers citizens to report neighborhood issues '
                    'like potholes, broken street lights, water leaks, and more. '
                    'Our AI-powered platform helps classify and prioritize issues '
                    'so they are resolved faster.\n\n'
                    'Together, we build smarter, safer neighborhoods.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Features list
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Key Features',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1D26),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFeatureRow(
                    Icons.camera_alt_outlined,
                    'Photo-based issue reporting',
                  ),
                  _buildFeatureRow(
                    Icons.auto_awesome,
                    'AI-powered category detection',
                  ),
                  _buildFeatureRow(
                    Icons.my_location_rounded,
                    'GPS location tagging',
                  ),
                  _buildFeatureRow(
                    Icons.sync_alt_rounded,
                    'Real-time status tracking',
                  ),
                  _buildFeatureRow(
                    Icons.admin_panel_settings_outlined,
                    'Admin management dashboard',
                  ),
                  _buildFeatureRow(
                    Icons.shield_outlined,
                    'Secure authentication',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info cards
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow('Developer', 'CityNex Team'),
                  Divider(height: 24, color: Colors.grey.shade100),
                  _buildInfoRow('Platform', 'Android & iOS'),
                  Divider(height: 24, color: Colors.grey.shade100),
                  _buildInfoRow('Built with', 'Flutter & Firebase'),
                  Divider(height: 24, color: Colors.grey.shade100),
                  _buildInfoRow('License', 'All rights reserved'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Copyright
            Text(
              '© 2026 CityNex. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF0D3B66).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF0D3B66)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1D26),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D26),
          ),
        ),
      ],
    );
  }
}
