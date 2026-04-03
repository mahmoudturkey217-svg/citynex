import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../tickets/tickets_screen.dart';
import '../notifications/alerts_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/utils/cache_helper.dart';
import '../../core/models/ticket_model.dart';
import '../tickets/logic/ticket_cubit.dart';
import '../tickets/logic/ticket_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/feedback_states.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final String _userName = CacheHelper.getData(key: 'user_name') ?? 'Citizen';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      backgroundColor: AppColors.scaffoldBg,
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
          height: AppDimensions.bottomNavHeight,
          decoration: BoxDecoration(
            color: AppColors.navBar,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.navBar.withOpacity(0.35),
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
                    color: AppColors.navBar,
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
          color:
              isSelected ? Colors.white.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? Colors.white : Colors.white54,
                size: isSelected ? 24 : 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.white54,
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

        final pending =
            tickets.where((t) => t.status == 'Pending').length;
        final open = tickets.where((t) => t.status == 'Open').length;
        final inProgress = tickets
            .where(
                (t) => t.status == 'In_Progress' || t.status == 'In Progress')
            .length;
        final resolved = tickets
            .where((t) =>
                t.status == 'Resolved' ||
                t.status == 'Fixed' ||
                t.status == 'Verified')
            .length;
        final total = tickets.length;
        final resolvedPercent =
            total > 0 ? (resolved / total * 100).round() : 0;
        final remainingPercent = total > 0 ? 100 - resolvedPercent : 0;

        // Skeleton loading state
        if (state is TicketLoading) {
          return Skeletonizer(
            enabled: true,
            child: _buildScrollContent(
              total: 12, pending: 3, open: 4, inProgress: 3, resolved: 2,
              resolvedPercent: 17, remainingPercent: 83, tickets: [],
              isLoading: true,
            ),
          );
        }

        if (state is TicketError) {
          return ErrorState(
            error: (state).error,
            onRetry: () => TicketCubit.get(context).getTickets(),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            TicketCubit.get(context).getTickets();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: AppColors.primary,
          child: _buildScrollContent(
            total: total, pending: pending, open: open,
            inProgress: inProgress, resolved: resolved,
            resolvedPercent: resolvedPercent,
            remainingPercent: remainingPercent,
            tickets: tickets, isLoading: false,
          ),
        );
      },
    );
  }

  Widget _buildScrollContent({
    required int total, required int pending, required int open,
    required int inProgress, required int resolved,
    required int resolvedPercent, required int remainingPercent,
    required List<TicketModel> tickets, required bool isLoading,
  }) {
    final searchQuery = _searchController.text.toLowerCase().trim();
    final isSearching = searchQuery.isNotEmpty;
    final displayTickets = isSearching
        ? tickets.where((t) =>
            t.title.toLowerCase().contains(searchQuery) ||
            t.description.toLowerCase().contains(searchQuery) ||
            t.status.toLowerCase().contains(searchQuery) ||
            t.category.name.toLowerCase().contains(searchQuery)).toList()
        : tickets;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (isSearching) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Search Results (${displayTickets.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
            if (displayTickets.isEmpty)
              _buildEmptyState()
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: displayTickets.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTicketItem(t),
                  )).toList(),
                ),
              ),
          ] else ...[
            _buildQuickActionsSection(),
            _buildActivitySection(
              total, pending, open, inProgress, resolved,
              resolvedPercent, remainingPercent, isLoading,
            ),
            _buildRecentTicketsSection(displayTickets, isLoading),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── HEADER ───
  Widget _buildHeader() {
    return GradientHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
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
                  ],
                ),
              ),
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Search tickets, city...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 15,
                ),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withOpacity(0.8), size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, color: Colors.white.withOpacity(0.8), size: 20),
                      onPressed: () {
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                        setState(() {});
                      },
                    )
                  : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
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
          const SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.add_circle_outline,
                  label: 'New Ticket',
                  subtitle: 'Report a ticket',
                  color: AppColors.primary,
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
                  color: AppColors.primarySoft,
                  onTap: () => setState(() => _currentNavIndex = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.check_circle_outline,
                  label: 'Confirm Fix',
                  subtitle: 'Ticket Resolved',
                  color: AppColors.resolved,
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
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
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
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.textHint),
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
    int resolvedPercent, int remainingPercent, bool isLoading,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'My Activity'),
          const SizedBox(height: 14),

          // ── Top row: Total Tickets + Resolution Rate ──
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppDimensions.borderRadiusLg,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedCount(
                        value: total,
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
              Expanded(
                flex: 3,
                child: AppCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AnimatedCount(
                            value: resolvedPercent,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.resolved,
                            ),
                          ),
                          const Text(
                            '%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.resolved,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Resolution Rate',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: resolvedPercent / 100,
                          backgroundColor: AppColors.surfaceLight,
                          color: AppColors.resolved,
                          minHeight: 5,
                        ),
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
              _buildStatusCard('Pending', pending, AppColors.pending),
              const SizedBox(width: 8),
              _buildStatusCard('Open', open, AppColors.open),
              const SizedBox(width: 8),
              _buildStatusCard(
                  'In Progress', inProgress, AppColors.inProgress),
              const SizedBox(width: 8),
              _buildStatusCard('Resolved', resolved, AppColors.resolved),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, int count, Color color) {
    return Expanded(
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedCount(
              value: count,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─── RECENT TICKETS ───
  Widget _buildRecentTicketsSection(
      List<TicketModel> tickets, bool isLoading) {
    final recent = tickets.take(5).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Recent Tickets',
            actionLabel: tickets.length > 5 ? 'View all →' : null,
            onAction:
                tickets.length > 5 ? () => setState(() => _currentNavIndex = 1) : null,
          ),
          const SizedBox(height: 14),
          if (!isLoading && tickets.isEmpty)
            _buildEmptyState()
          else
            ...recent.map((ticket) => _buildTicketItem(ticket)),
        ],
      ),
    );
  }

  Widget _buildTicketItem(TicketModel ticket) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/report-details', arguments: ticket),
      child: AppCard(
        child: Row(
          children: [
            // Priority color strip
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.statusColor(ticket.status),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            // Category icon or Image thumbnail
            if (ticket.media != null && ticket.media!.isNotEmpty && ticket.media!.first.mediaUrl != null)
              ClipRRect(
                borderRadius: AppDimensions.borderRadiusSm,
                child: CachedNetworkImage(
                  imageUrl: ticket.media!.first.mediaUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) => Container(
                    width: 48,
                    height: 48,
                    color: AppColors.surfaceLight,
                    child: const Center(
                      child: SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 48,
                    height: 48,
                    color: AppColors.surfaceLight,
                    child: const Icon(Icons.broken_image, size: 20, color: AppColors.textHint),
                  ),
                ),
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: AppDimensions.borderRadiusSm,
                ),
                child: Center(
                  child: Icon(
                    AppColors.categoryIcon(ticket.category.name),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ticket.description,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textHint),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StatusBadge(status: ticket.status, fontSize: 10),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ticket.category.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        ticket.createdAt.length >= 10
                            ? ticket.createdAt.substring(0, 10)
                            : ticket.createdAt,
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textHint),
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

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.campaign_outlined,
      title: 'No Tickets yet',
      subtitle: 'Help improve your city by reporting an issue',
      actionLabel: 'Create First Ticket',
      onAction: () => Navigator.pushNamed(context, '/create-report'),
    );
  }
}
