import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/ticket_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/feedback_states.dart';
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
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter chips
          FilterChipBar(
            filters: _filters,
            selected: _selectedFilter,
            onSelected: (filter) {
              setState(() => _selectedFilter = filter);
            },
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
                  return Skeletonizer(
                    enabled: true,
                    child: ListView.builder(
                      padding: AppDimensions.screenPadding,
                      itemCount: 5,
                      itemBuilder: (_, __) => _buildSkeletonTicket(),
                    ),
                  );
                }

                if (state is TicketError) {
                  return ErrorState(
                    error: state.error,
                    onRetry: () => TicketCubit.get(context).getTickets(),
                  );
                }

                if (state is TicketSuccess) {
                  final allTickets = state.tickets;
                  final tickets = _selectedFilter == 'All' 
                      ? allTickets 
                      : allTickets.where((t) => t.status.toLowerCase().replaceAll(' ', '_') == _selectedFilter.toLowerCase()).toList();

                  if (tickets.isEmpty) {
                    return EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No tickets found',
                      subtitle: _selectedFilter == 'All'
                          ? 'You haven\'t submitted any tickets yet'
                          : 'No ${_selectedFilter.replaceAll('_', ' ')} tickets',
                      actionLabel: 'Create Ticket',
                      onAction: () =>
                          Navigator.pushNamed(context, '/create-report'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      TicketCubit.get(context).getTickets();
                      await Future.delayed(
                          const Duration(milliseconds: 500));
                    },
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: AppDimensions.screenPadding,
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        return _buildTicketCard(tickets[index]);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonTicket() {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: AppDimensions.borderRadiusSm,
            ),
            child: const Icon(Icons.report_outlined, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 160, height: 14, color: AppColors.surfaceLight),
                const SizedBox(height: 6),
                Container(width: 120, height: 10, color: AppColors.surfaceLight),
                const SizedBox(height: 8),
                Container(width: 80, height: 18, color: AppColors.surfaceLight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(TicketModel ticket) {
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
}
