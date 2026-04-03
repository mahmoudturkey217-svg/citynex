import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/widgets/shared_widgets.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            iconTheme: IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: GradientHeader(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Icon(Icons.help_outline_rounded, size: 60, color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'Help & Support',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppDimensions.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Contact Us'),
                  const SizedBox(height: 16),
                  _buildContactCard(
                    icon: Icons.email_outlined,
                    title: 'Email Support',
                    subtitle: 'support@citynex.app',
                    color: AppColors.primary,
                    onTap: () => _launchUrl('mailto:support@citynex.app'),
                  ),
                  const SizedBox(height: 12),
                  _buildContactCard(
                    icon: Icons.language_outlined,
                    title: 'Website',
                    subtitle: 'www.citynex.app',
                    color: AppColors.resolved,
                    onTap: () => _launchUrl('https://www.citynex.app'),
                  ),
                  const SizedBox(height: 32),
                  const SectionHeader(title: 'About CityNex'),
                  const SizedBox(height: 16),
                  const AppCard(
                    child: Text(
                      'CityNex is a premium Smart Neighborhood Reporting App designed to bridge the gap between citizens and local administration. Our goal is to empower residents to easily report issues like broken streetlights, road damage, and waste management problems, ensuring a safer and highly optimized neighborhood for everyone.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const SectionHeader(title: 'Frequently Asked Questions'),
                  const SizedBox(height: 16),
                  _buildFaqItem(
                    'How do I report a new issue?',
                    'You can report an issue by tapping the "+" button on the bottom navigation bar. Make sure to provide a clear photo and accurate location!',
                  ),
                  _buildFaqItem(
                    'What does the "Vote" button do?',
                    'Voting on an existing ticket lets the administration know that you are also experiencing the same issue, bumping up its priority without creating duplicate reports.',
                  ),
                  _buildFaqItem(
                    'How long does it take for an issue to be resolved?',
                    'This depends on the priority and category of the ticket. Emergency tickets are prioritized, while general maintenance might take a few business days.',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.surfaceLight.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              question,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            iconColor: AppColors.primary,
            collapsedIconColor: AppColors.textHint,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
