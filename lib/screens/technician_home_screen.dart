import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../mock_data.dart';
import '../core/utils/cache_helper.dart';
import '../core/models/ticket_model.dart';
import 'main/tickets/logic/ticket_cubit.dart';
import 'main/tickets/logic/ticket_state.dart';
import 'profile_screen.dart';

class TechnicianHomeScreen extends StatefulWidget {
  const TechnicianHomeScreen({super.key});

  @override
  State<TechnicianHomeScreen> createState() => _TechnicianHomeScreenState();
}

class _TechnicianHomeScreenState extends State<TechnicianHomeScreen> {
  int _currentNavIndex = 0;
  final String _technicianName = CacheHelper.getData(key: 'user_name') ?? 'Technician Max';
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Open',
    'In Progress',
    'Resolved',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch tickets that might be assigned to this technician
    // Assuming backend returns tickets this user is assigned to
    context.read<TicketCubit>().getTickets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildDashboard(),     // Index 0: Dashboard overview
          _buildMyTasks(),       // Index 1: Tasks list
          const ProfileScreen(), // Index 2: Profile mapping
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ═══════════════════════════════
  //         BOTTOM NAV
  // ═══════════════════════════════
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment,
                label: 'My Tasks',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 2,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D3B66).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFF0D3B66) : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF0D3B66) : Colors.grey.shade400,
              ),
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
    return BlocConsumer<TicketCubit, TicketState>(
      listener: (context, state) {},
      builder: (context, state) {
        List<TicketModel> tickets = [];
        if (state is TicketSuccess) tickets = state.tickets;

        final open = tickets.where((t) => t.status == 'Open').length;
        final inProgress = tickets.where((t) => t.status == 'In_Progress' || t.status == 'In Progress').length;
        final resolved = tickets.where((t) => t.status == 'Resolved' || t.status == 'Fixed' || t.status == 'Verified').length;
        final total = open + inProgress + resolved;

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
                    colors: [Color(0xFF0D3B66), Color(0xFF1565C0)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Technician Panel',
                                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.65)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Welcome, \$_technicianName',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.build, color: Colors.blueAccent, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Technician',
                                style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── PERFORMANCE SUMMARY ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text('My Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26))),
              ),
              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPerformanceStat('$total', 'Assigned\nTotal', Colors.black87),
                      Container(width: 1, height: 40, color: Colors.grey.shade300),
                      _buildPerformanceStat('$inProgress', 'In\nProgress', const Color(0xFF9B59B6)),
                      Container(width: 1, height: 40, color: Colors.grey.shade300),
                      _buildPerformanceStat('$resolved', 'Jobs\nCompleted', const Color(0xFF2ECC71)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ─── STATUS CARDS ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard('📂', open, 'Open', const Color(0xFF4A90D9))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('👥', inProgress, 'In Progress', const Color(0xFF9B59B6))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('✅', resolved, 'Completed', const Color(0xFF2ECC71))),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── RECENT ASSIGNMENTS ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Assignments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1D26))),
                    GestureDetector(
                      onTap: () => setState(() => _currentNavIndex = 1), // Go to Tasks Tab
                      child: const Text('→ View all', style: TextStyle(fontSize: 13, color: Color(0xFF4A90D9), fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (state is TicketLoading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              else if (tickets.isEmpty)
                _buildEmptyState()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: tickets.take(4).map((r) => _buildTicketCard(r)).toList(),
                  ),
                ),
                
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceStat(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valueColor)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatCard(String emoji, int count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text('\$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
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
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text('My Tasks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D3B66))),
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
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0D3B66) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? const Color(0xFF0D3B66) : Colors.grey.shade300),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
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
            child: BlocConsumer<TicketCubit, TicketState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is TicketLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<TicketModel> allTasks = [];
                if (state is TicketSuccess) {
                  allTasks = state.tickets;
                }
                
                // Exclude Pending since technicians are only assigned Open/In-progress tickets
                var tasks = allTasks.where((t) => t.status != 'Pending').toList();
                
                if (_selectedFilter != 'All') {
                   // Map UI filter to backend status strings if needed
                   if (_selectedFilter == 'Resolved') {
                      tasks = tasks.where((r) => r.status == 'Resolved' || r.status == 'Fixed' || r.status == 'Verified').toList();
                   } else if (_selectedFilter == 'In Progress') {
                      tasks = tasks.where((r) => r.status == 'In_Progress' || r.status == 'In Progress').toList();
                   } else {
                      tasks = tasks.where((r) => r.status == _selectedFilter).toList();
                   }
                }

                if (tasks.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) => _buildTicketCard(tasks[index]),
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
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF0D3B66).withOpacity(0.08), shape: BoxShape.circle),
              child: const Icon(Icons.assignment_turned_in_outlined, size: 48, color: Color(0xFF0D3B66)),
            ),
            const SizedBox(height: 20),
            const Text('No Tasks Found', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A1D26))),
            const SizedBox(height: 8),
            Text('You have no tickets currently assigned matching this filter.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(statusIcon, color: statusColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1D26)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF0D3B66).withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                        child: Text(ticket.category.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF0D3B66))),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 11, color: statusColor),
                            const SizedBox(width: 4),
                            Text(ticket.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                          ],
                        ),
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
}
