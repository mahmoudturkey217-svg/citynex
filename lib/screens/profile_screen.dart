import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../mock_data.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/utils/cache_helper.dart';
import '../screens/main/tickets/logic/ticket_cubit.dart';
import '../screens/main/tickets/logic/ticket_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = UserModel(
      uid: CacheHelper.getData(key: 'token') ?? '',
      name: CacheHelper.getData(key: 'user_name') ?? MockUser.name,
      email: CacheHelper.getData(key: 'user_email') ?? MockUser.email,
      role: CacheHelper.getData(key: 'user_role') ?? MockUser.role,
    );

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
              .where((t) => t.status == 'Resolved' || t.status == 'Fixed' || t.status == 'Verified')
              .length;
          rate = totalTickets > 0
              ? (resolvedTickets / totalTickets * 100).round()
              : 0;
        }
    return SingleChildScrollView(
      child: Column(
        children: [
          // ─── PROFILE HEADER ───
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A2D4F), Color(0xFF1565C0)],
              ),
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
                // Avatar
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: CacheHelper.getData(key: 'user_avatar_local') != null 
                      ? FileImage(File(CacheHelper.getData(key: 'user_avatar_local'))) 
                      : null,
                  child: CacheHelper.getData(key: 'user_avatar_local') == null 
                      ? Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
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
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    user.role == 'admin' ? 'Admin' : 'Citizen',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat('$totalTickets', 'Tickets'),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withOpacity(0.3),
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                    ),
                    _buildStat('$resolvedTickets', 'Resolved'),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withOpacity(0.3),
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                    ),
                    _buildStat('$rate', 'Rate'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── ACCOUNT SECTION ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
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
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        label: 'Personal Information',
                        onTap: () =>
                            Navigator.pushNamed(context, '/personal-info'),
                      ),
                      Divider(
                        height: 1,
                        indent: 56,
                        color: Colors.grey.shade100,
                      ),
                      if (_authService.isEmailPasswordUser)
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          label: 'Change Password',
                          onTap: () =>
                              Navigator.pushNamed(context, '/change-password'),
                        ),
                      if (_authService.isEmailPasswordUser)
                        Divider(
                          height: 1,
                          indent: 56,
                          color: Colors.grey.shade100,
                        ),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notification Preferences',
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/notification-preferences',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ─── SUPPORT SECTION ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Support',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
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
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        onTap: () =>
                            Navigator.pushNamed(context, '/help-support'),
                      ),
                      Divider(
                        height: 1,
                        indent: 56,
                        color: Colors.grey.shade100,
                      ),
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        label: 'About CityNex',
                        onTap: () => Navigator.pushNamed(context, '/about'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── SIGN OUT ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await CacheHelper.clearData();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
      },
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
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
          color: const Color(0xFF0D3B66).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF0D3B66), size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A1D26),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
