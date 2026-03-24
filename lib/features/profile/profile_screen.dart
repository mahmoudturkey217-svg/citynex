import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/models/user_model.dart';
import '../../core/utils/cache_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/widgets/shared_widgets.dart';
import '../tickets/logic/ticket_cubit.dart';
import '../tickets/logic/ticket_state.dart';
import '../assignments/logic/assignment_cubit.dart';
import '../assignments/logic/assignment_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = UserModel(
      uid: CacheHelper.getData(key: 'token') ?? '',
      name: CacheHelper.getData(key: 'user_name') ?? 'Citizen',
      email: CacheHelper.getData(key: 'user_email') ?? 'citizen@example.com',
      role: CacheHelper.getData(key: 'user_role') ?? 'citizen',
    );

    final bool isTechnician = user.role == 'technician';

    if (isTechnician) {
      return BlocBuilder<AssignmentCubit, AssignmentState>(
        buildWhen: (previous, current) {
          return current is AssignmentLoading ||
              current is AssignmentSuccess ||
              current is AssignmentError;
        },
        builder: (context, state) {
          int totalTickets = 0;
          int resolvedTickets = 0;
          int rate = 0;

          if (state is AssignmentSuccess) {
            totalTickets = state.assignments.length;
            resolvedTickets = state.assignments
                .where((a) =>
                    a.status == 'Completed' ||
                    a.status == 'Fixed' ||
                    a.status == 'Verified')
                .length;
            rate = totalTickets > 0
                ? (resolvedTickets / totalTickets * 100).round()
                : 0;
          }
          return _buildProfileContent(
              context, user, totalTickets, resolvedTickets, rate);
        },
      );
    }

    return BlocBuilder<TicketCubit, TicketState>(
      buildWhen: (previous, current) {
        return current is TicketLoading ||
            current is TicketSuccess ||
            current is TicketError;
      },
      builder: (context, state) {
        int totalTickets = 0;
        int resolvedTickets = 0;
        int rate = 0;

        if (state is TicketSuccess) {
          totalTickets = state.tickets.length;
          resolvedTickets = state.tickets
              .where((t) =>
                  t.status == 'Resolved' ||
                  t.status == 'Fixed' ||
                  t.status == 'Verified')
              .length;
          rate = totalTickets > 0
              ? (resolvedTickets / totalTickets * 100).round()
              : 0;
        }
        return _buildProfileContent(
            context, user, totalTickets, resolvedTickets, rate);
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel user,
      int totalTickets, int resolvedTickets, int rate) {
    final bool isTechnician = user.role == 'technician';
    return SingleChildScrollView(
      child: Column(
        children: [
          // ─── PROFILE HEADER ───
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + 20,
              24,
              28,
            ),
            child: Column(
              children: [
                // Avatar with gradient ring
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: AppDimensions.avatarRadius,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage:
                        CacheHelper.getData(key: 'user_avatar_local') != null
                            ? FileImage(File(
                                CacheHelper.getData(key: 'user_avatar_local')))
                            : null,
                    child: CacheHelper.getData(key: 'user_avatar_local') == null
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 14),

                // Name
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),

                // Role badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    isTechnician
                        ? 'Technician'
                        : (user.role == 'admin' ? 'Admin' : 'Citizen'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Stats row with animated counts
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat(
                        totalTickets, isTechnician ? 'Assigned' : 'Tickets'),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withOpacity(0.3),
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                    ),
                    _buildStat(resolvedTickets,
                        isTechnician ? 'Completed' : 'Resolved'),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withOpacity(0.3),
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                    ),
                    _buildStatPercent(rate, 'Rate'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── ACCOUNT SECTION ───
          _buildMenuSection('Account', [
            _MenuItem(
              icon: Icons.person_outline,
              label: 'Personal Information',
              onTap: () => Navigator.pushNamed(context, '/personal-info'),
            ),
            _MenuItem(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: () => Navigator.pushNamed(context, '/change-password'),
            ),
            _MenuItem(
              icon: Icons.notifications_outlined,
              label: 'Notification Preferences',
              onTap: () =>
                  Navigator.pushNamed(context, '/notification-preferences'),
            ),
          ]),

          const SizedBox(height: 20),

          // ─── SUPPORT SECTION ───
          _buildMenuSection('Support', [
            _MenuItem(
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () => Navigator.pushNamed(context, '/help-support'),
            ),
            _MenuItem(
              icon: Icons.info_outline,
              label: 'About CityNex',
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
          ]),

          const SizedBox(height: 24),

          // ─── SIGN OUT ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Sign Out',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withOpacity(0.08),
                  foregroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusMd,
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),

          // App version
          const SizedBox(height: 16),
          Text(
            'CityNex v1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLg,
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Sign Out', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out of your account?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await CacheHelper.clearData();
              if (!context.mounted) return;
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textHint,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: AppDimensions.borderRadiusLg,
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
                for (int i = 0; i < items.length; i++) ...[
                  _buildMenuItem(
                    icon: items[i].icon,
                    label: items[i].label,
                    onTap: items[i].onTap,
                  ),
                  if (i < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: AppColors.divider,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(int value, String label) {
    return Column(
      children: [
        AnimatedCount(
          value: value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildStatPercent(int value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedCount(
              value: value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text('%',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textHint,
        size: 20,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
