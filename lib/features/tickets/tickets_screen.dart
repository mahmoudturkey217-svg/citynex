import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/ticket_model.dart';
import 'logic/ticket_cubit.dart';
import 'logic/ticket_state.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Open',
    'Assigned',
    'In_Progress',
    'Fixed',
    'Verified',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'My Tickets',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D3B66),
              ),
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
                  onTap: () {
                    setState(() => _selectedFilter = filter);
                    if (filter == 'All') {
                      TicketCubit.get(context).getTickets();
                    } else {
                      TicketCubit.get(context).getTickets(status: filter);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0D3B66)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0D3B66)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      filter.replaceAll('_', ' '),
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

          // Tickets list
          Expanded(
            child: BlocBuilder<TicketCubit, TicketState>(
              buildWhen: (previous, current) {
                return current is TicketLoading ||
                       current is TicketSuccess ||
                       current is TicketError;
              },
              builder: (context, state) {
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
                        Text(state.error, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => TicketCubit.get(context).getTickets(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is TicketSuccess) {
                  final tickets = state.tickets;
                  if (tickets.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      return _buildTicketItem(tickets[index]);
                    },
                  );
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketItem(TicketModel ticket) {
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
      onTap: () =>
          Navigator.pushNamed(context, '/report-details', arguments: ticket),
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
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF0D3B66).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ticket.media != null && ticket.media!.isNotEmpty && ticket.media!.first.mediaUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        ticket.media!.first.mediaUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          _getCategoryIcon(ticket.category.name),
                          color: const Color(0xFF0D3B66),
                          size: 26,
                        ),
                      ),
                    )
                  : Icon(
                      _getCategoryIcon(ticket.category.name),
                      color: const Color(0xFF0D3B66),
                      size: 26,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1D26),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
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
                              ticket.status.replaceAll('_', ' '),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(ticket.priority).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ticket.priority,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getPriorityColor(ticket.priority),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        ticket.createdAt.length >= 10 ? ticket.createdAt.substring(0, 10) : ticket.createdAt,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Medium':
        return Colors.amber.shade700;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D3B66).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Color(0xFF0D3B66),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No tickets found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D26),
            ),
          ),
        ],
      ),
    );
  }
}
