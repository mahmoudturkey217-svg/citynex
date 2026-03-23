import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../tickets/tickets_screen.dart';
import '../notifications/alerts_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/utils/cache_helper.dart';
import '../../core/models/ticket_model.dart';
import '../tickets/logic/ticket_cubit.dart';
import '../tickets/logic/ticket_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentNavIndex = 0;
  final String _userName = CacheHelper.getData(key: 'user_name') ?? 'Citizen';

  @override
  void initState() {
    super.initState();
    TicketCubit.get(context).getTickets();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildHomeContent(),
          const TicketsScreen(),
          const AlertsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── BOTTOM NAV ───
  Widget _buildBottomNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFF0D2137),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D2137).withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'Tickets',
                index: 1,
              ),
              // Center + Button
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/create-report'),
                child: Container(
                  width: 52,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF0D2137),
                    size: 26,
                  ),
                ),
              ),
              _buildNavItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications_rounded,
                label: 'Alerts',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.45),
                size: isSelected ? 24 : 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.45),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════
  //        HOME TAB CONTENT
  // ══════════════════════════════
  Widget _buildHomeContent() {
    return BlocConsumer<TicketCubit, TicketState>(
      listener: (context, state) {},
      buildWhen: (previous, current) {
        return current is TicketLoading ||
               current is TicketSuccess ||
               current is TicketError;
      },
      builder: (context, state) {
        List<TicketModel> tickets = [];
        if (state is TicketSuccess) {
          tickets = state.tickets;
        }

        final pending = tickets.where((t) => t.status == 'Pending').length;
        final open = tickets.where((t) => t.status == 'Open').length;
        final inProgress = tickets.where((t) => t.status == 'In_Progress' || t.status == 'In Progress').length;
        final resolved = tickets.where((t) => t.status == 'Resolved' || t.status == 'Fixed' || t.status == 'Verified').length;
        final total = tickets.length;
        final resolvedPercent = total > 0 ? (resolved / total * 100).round() : 0;
        final remainingPercent = total > 0 ? 100 - resolvedPercent : 0;

        if (state is TicketLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TicketError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 12),
                Text((state as TicketError).error, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => TicketCubit.get(context).getTickets(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildQuickActionsSection(),
              _buildActivitySection(
                total, pending, open, inProgress, resolved,
                resolvedPercent, remainingPercent,
              ),
              _buildRecentTicketsSection(tickets),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // ─── HEADER ───
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2D4F), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getGreeting()},',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userName.isNotEmpty ? _userName : 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.search,
                    color: Colors.white.withOpacity(0.6), size: 20),
                const SizedBox(width: 10),
                Text(
                  'Search tickets, city...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── QUICK ACTIONS ───
  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D26),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.add_circle_outline,
                  label: 'New Ticket',
                  subtitle: 'Report a ticket',
                  color: const Color(0xFF0D3B66),
                  onTap: () =>
                      Navigator.pushNamed(context, '/create-report'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.receipt_long_outlined,
                  label: 'My Tickets',
                  subtitle: 'Track Status',
                  color: const Color(0xFF4A90D9),
                  onTap: () => setState(() => _currentNavIndex = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.check_circle_outline,
                  label: 'Confirm Fix',
                  subtitle: 'Ticket Resolved',
                  color: const Color(0xFF2ECC71),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D26),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── ACTIVITY SECTION ───
  Widget _buildActivitySection(
    int total, int pending, int open, int inProgress, int resolved,
    int resolvedPercent, int remainingPercent,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1D26),
            ),
          ),
          const SizedBox(height: 14),

          // ── Top row: Total Tickets + Resolution Rate ──
          Row(
            children: [
              // Total Tickets — gradient card
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0A2D4F), Color(0xFF1565C0)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D3B66).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$total',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Total Tickets',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'All time submissions',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Resolution Rate
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resolution Rate',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D26),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: resolvedPercent / 100,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF2ECC71)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                '$resolved',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2ECC71),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Resolved',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '${total - resolved}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF39C12),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Remaining',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Status cards row ──
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.hourglass_empty,
                  count: pending,
                  label: 'Pending',
                  color: const Color(0xFFE5A100),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.folder_open_outlined,
                  count: open,
                  label: 'Open',
                  color: const Color(0xFF4A90D9),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.groups_outlined,
                  count: inProgress,
                  label: 'In Progress',
                  color: const Color(0xFF9B59B6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.check_circle_outline,
                  count: resolved,
                  label: 'Resolved',
                  color: const Color(0xFF2ECC71),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── RECENT TICKETS ───
  Widget _buildRecentTicketsSection(List<TicketModel> tickets) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        const Text(
                            'Recent Tickets',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1D26),
                            ),
                        ),
                        if (tickets.isNotEmpty)
                            GestureDetector(
                                onTap: () => setState(() => _currentNavIndex = 1),
                                child: const Text(
                                    '→ View all',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF4A90D9),
                                        fontWeight: FontWeight.w600,
                                    ),
                                ),
                            ),
                    ],
                ),
                const SizedBox(height: 12),
                if (tickets.isEmpty)
                    _buildEmptyState()
                else
                    ...tickets.take(5).map((t) => _buildTicketCard(t)),
            ],
        ),
    );
  }

  Widget _buildTicketCard(TicketModel ticket) {
      Color statusColor;
      IconData statusIcon;
      switch (ticket.status) {
          case 'Pending':
              statusColor = const Color(0xFFE5A100);
              statusIcon = Icons.hourglass_empty;
              break;
          case 'Open':
              statusColor = const Color(0xFF4A90D9);
              statusIcon = Icons.folder_open_outlined;
              break;
          case 'In_Progress':
          case 'In Progress':
              statusColor = const Color(0xFF9B59B6);
              statusIcon = Icons.groups_outlined;
              break;
          case 'Fixed':
          case 'Verified':
          case 'Resolved':
              statusColor = const Color(0xFF2ECC71);
              statusIcon = Icons.check_circle_outline;
              break;
          default:
              statusColor = Colors.grey;
              statusIcon = Icons.info_outline;
      }

      return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/report-details', arguments: ticket),
          child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
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
              child: Row(
                  children: [
                      Container(
                          width: 60, height: 60,
                          decoration: BoxDecoration(
                              color: const Color(0xFF0D3B66).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                              _getCategoryIcon(ticket.category.name),
                              color: const Color(0xFF0D3B66),
                              size: 28,
                          ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                      ticket.title,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A1D26),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      ticket.description,
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                      children: [
                                          Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                  color: const Color(0xFF0D3B66).withOpacity(0.08),
                                                  borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                  ticket.category.name,
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF0D3B66),
                                                  ),
                                              ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                  color: statusColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                      Icon(statusIcon, size: 11, color: statusColor),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                          ticket.status,
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.w600,
                                                              color: statusColor,
                                                          ),
                                                      ),
                                                  ],
                                              ),
                                          ),
                                          const Spacer(),
                                          Text(
                                              ticket.createdAt.length >= 10 ? ticket.createdAt.substring(0, 10) : ticket.createdAt,
                                              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                                          ),
                                      ],
                                  ),
                              ],
                          ),
                      ),
                  ],
              ),
          ),
      );
  }

  IconData _getCategoryIcon(String categoryName) {
      switch (categoryName.toLowerCase()) {
          case 'road damage':
              return Icons.warning_rounded;
          case 'public safety':
              return Icons.shield_outlined;
          case 'water':
              return Icons.water_drop_outlined;
          case 'electricity':
              return Icons.electric_bolt_outlined;
          case 'waste':
              return Icons.delete_outline;
          default:
              return Icons.report_outlined;
      }
  }

  Widget _buildEmptyState() {
      return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                  Icon(Icons.campaign_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 14),
                  const Text(
                      'No Tickets yet',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D26),
                      ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                      'Help improve your city by reporting an issue',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/create-report'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D3B66),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                          ),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          elevation: 0,
                      ),
                      child: const Text(
                          'Create First Ticket',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                  ),
              ],
          ),
      );
  }
}
