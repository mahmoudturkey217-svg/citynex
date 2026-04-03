import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../core/utils/cache_helper.dart';
import '../../core/models/assignment_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/feedback_states.dart';
import '../assignments/logic/assignment_cubit.dart';
import '../assignments/logic/assignment_state.dart';
import '../notifications/alerts_screen.dart';
import '../profile/profile_screen.dart';
import 'assignment_detail_screen.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  int _currentNavIndex = 0;
  final String _technicianName =
      CacheHelper.getData(key: 'user_name') ?? 'Technician';
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Pending',
    'Open',
    'In Progress',
    'Resolved',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    context.read<AssignmentCubit>().getAssignments();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildDashboard(),
          _buildMyTasks(),
          const AlertsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═══════════════════════════════
  //         BOTTOM NAV
  // ═══════════════════════════════
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
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'Dashboard',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment,
                label: 'Tasks',
                index: 1,
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

  // ═══════════════════════════════
  //       TAB 0: DASHBOARD
  // ═══════════════════════════════
  Widget _buildDashboard() {
    return BlocBuilder<AssignmentCubit, AssignmentState>(
      buildWhen: (previous, current) {
        return current is AssignmentLoading ||
            current is AssignmentSuccess ||
            current is AssignmentError;
      },
      builder: (context, state) {
        List<AssignmentModel> assignments = [];
        if (state is AssignmentSuccess) assignments = state.assignments;

        final pending =
            assignments.where((a) => a.status == 'Pending').length;
        final assigned =
            assignments.where((a) => a.status == 'Assigned' || a.status == 'Accepted').length;
        final inProgress = assignments
            .where(
                (a) => a.status == 'In_Progress' || a.status == 'In Progress')
            .length;
        final completed = assignments
            .where((a) =>
                a.status == 'Completed' ||
                a.status == 'Fixed' ||
                a.status == 'Verified' ||
                a.status == 'Resolved')
            .length;
        final declined =
            assignments.where((a) => a.status == 'Declined' || a.status == 'Closed').length;
        final total = assignments.length;

        final active = pending + assigned + inProgress;
        final done = completed;
        final completionRate =
            total > 0 ? (completed / total * 100).round() : 0;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── HEADER ───
              Container(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.waving_hand_rounded,
                              color: Color(0xFFFFC107), size: 22),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _currentNavIndex = 2),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.notifications_outlined,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _technicianName,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildHeaderBadge(
                            '$active Active', const Color(0xFF4FC3F7)),
                        const SizedBox(width: 8),
                        _buildHeaderBadge(
                            '$done Done', const Color(0xFF66BB6A)),
                        const SizedBox(width: 8),
                        _buildHeaderBadge(
                            '$total Total', const Color(0xFFFFB74D)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── PERFORMANCE CARD ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0A2D4F), Color(0xFF1A4A7A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0D3B66).withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4FC3F7).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '⚡ Performance',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4FC3F7),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Completion Rate',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$total tasks',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CustomPaint(
                          painter: _CircularGaugePainter(
                            percentage: completionRate.toDouble(),
                            backgroundColor:
                                Colors.white.withOpacity(0.15),
                            progressColor: const Color(0xFF4FC3F7),
                          ),
                          child: Center(
                            child: Text(
                              '$completionRate%',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ─── STATUS BREAKDOWN ───
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(title: 'Status Breakdown'),
              ),
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.hourglass_empty,
                            count: pending,
                            label: 'Pending',
                            color: AppColors.pending,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle_outline,
                            count: assigned,
                            label: 'Assigned',
                            color: AppColors.open,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.sync,
                            count: inProgress,
                            label: 'In Progress',
                            color: AppColors.inProgress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.task_alt,
                            count: completed,
                            label: 'Completed',
                            color: AppColors.resolved,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.cancel_outlined,
                            count: declined,
                            label: 'Declined',
                            color: AppColors.declined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.list_alt,
                            count: total,
                            label: 'All Tasks',
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── RECENT ASSIGNMENTS ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Recent Assignments',
                  actionLabel: 'View all →',
                  onAction: () => setState(() => _currentNavIndex = 1),
                ),
              ),
              const SizedBox(height: 12),

              if (state is AssignmentLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state is AssignmentError)
                _buildErrorWidget((state as AssignmentError).error)
              else if (assignments.isEmpty)
                _buildEmptyState()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: assignments
                        .take(4)
                        .map((a) => _buildAssignmentCard(a))
                        .toList(),
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatCard({
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
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color),
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

  // ═══════════════════════════════
  //       TAB 1: MY TASKS
  // ═══════════════════════════════
  Widget _buildMyTasks() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                const Text(
                  'My Assignments',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                BlocBuilder<AssignmentCubit, AssignmentState>(
                  buildWhen: (previous, current) =>
                      current is AssignmentSuccess,
                  builder: (context, state) {
                    int activeCount = 0;
                    if (state is AssignmentSuccess) {
                      activeCount = state.assignments
                        .where((a) =>
                            a.status == 'Pending' ||
                            a.status == 'Assigned' ||
                            a.status == 'In_Progress' ||
                            a.status == 'In Progress')
                        .length;
                    }
                    if (activeCount == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC3F7).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF4FC3F7).withOpacity(0.4)),
                      ),
                      child: Text(
                        '$activeCount Active',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4FC3F7),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Filter chips
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // List body
          Expanded(
            child: BlocConsumer<AssignmentCubit, AssignmentState>(
              listener: (context, state) {
                if (state is AssignmentActionSuccess) {
                  AppSnackbar.show(context, message: state.message, isSuccess: true);
                } else if (state is AssignmentActionError) {
                  AppSnackbar.show(context, message: state.error, isError: true);
                }
              },
              buildWhen: (previous, current) {
                return current is AssignmentLoading ||
                    current is AssignmentSuccess ||
                    current is AssignmentError;
              },
              builder: (context, state) {
                if (state is AssignmentLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AssignmentError) {
                  return _buildErrorWidget(state.error);
                }

                List<AssignmentModel> allAssignments = [];
                if (state is AssignmentSuccess) {
                  allAssignments = state.assignments;
                }

                var filtered = List<AssignmentModel>.from(allAssignments);

                if (_selectedFilter != 'All') {
                  if (_selectedFilter == 'In Progress') {
                    filtered = filtered
                        .where((a) =>
                            a.status == 'In_Progress' ||
                            a.status == 'In Progress')
                        .toList();
                  } else if (_selectedFilter == 'Resolved') {
                    filtered = filtered
                        .where((a) =>
                            a.status == 'Resolved' ||
                            a.status == 'Fixed' ||
                            a.status == 'Verified' ||
                            a.status == 'Completed')
                        .toList();
                  } else if (_selectedFilter == 'Closed') {
                    filtered = filtered
                        .where((a) =>
                            a.status == 'Closed' ||
                            a.status == 'Declined')
                        .toList();
                  } else if (_selectedFilter == 'Open') {
                    filtered = filtered
                        .where((a) =>
                            a.status == 'Open' ||
                            a.status == 'Assigned')
                        .toList();
                  } else {
                    filtered = filtered
                        .where((a) => a.status == _selectedFilter)
                        .toList();
                  }
                }

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () => context
                      .read<AssignmentCubit>()
                      .getAssignments(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _buildAssignmentCard(filtered[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════
  //       WIDGETS / HELPERS
  // ═══════════════════════════════

  Widget _buildErrorWidget(String error) {
    return ErrorState(
      title: 'Failed to load data',
      error: error,
      onRetry: () => context.read<AssignmentCubit>().getAssignments(),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.assignment_turned_in_outlined,
      title: 'No Assignments Found',
      subtitle: 'You have no assignments matching this filter.',
    );
  }

  Widget _buildAssignmentCard(AssignmentModel assignment) {
    final ticket = assignment.ticket;
    Color statusColor;
    IconData statusIcon;

    statusColor = AppColors.statusColor(assignment.status);
    statusIcon = AppColors.statusIcon(assignment.status);

    // Priority color
    final priorityColor = AppColors.priorityColor(ticket.priority);

    // Format date
    String formattedDate = '';
    try {
      final dt = DateTime.parse(assignment.assignedAt);
      formattedDate = DateFormat('MMM dd').format(dt);
    } catch (_) {
      formattedDate = assignment.assignedAt;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<AssignmentCubit>(),
              child: AssignmentDetailScreen(assignment: assignment),
            ),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      style: const TextStyle(
                        fontSize: 15,
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
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Badges row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ticket.priority,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      assignment.displayStatus,
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
                formattedDate,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),

          // Action buttons for pending assignments
          if (assignment.status == 'Pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context
                          .read<AssignmentCubit>()
                          .declineAssignment(assignment.id);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.declined,
                      side: const BorderSide(color: AppColors.declined),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Decline',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<AssignmentCubit>()
                          .acceptAssignment(assignment.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.resolved,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Accept',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Mark as completed button for in-progress assignments
          if (assignment.status == 'In_Progress' ||
              assignment.status == 'In Progress') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<AssignmentCubit>()
                      .updateAssignmentStatus(assignment.id, 'Completed');
                },
                icon: const Icon(Icons.check, size: 18),
                label: const Text(
                  'Mark as Completed',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}

// ═══════════════════════════════
//   CIRCULAR GAUGE PAINTER
// ═══════════════════════════════
class _CircularGaugePainter extends CustomPainter {
  final double percentage;
  final Color backgroundColor;
  final Color progressColor;

  _CircularGaugePainter({
    required this.percentage,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 8.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
