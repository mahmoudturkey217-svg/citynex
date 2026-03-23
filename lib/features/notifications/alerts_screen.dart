import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'logic/notification_cubit.dart';
import 'logic/notification_state.dart';
import '../../core/models/notification_model.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _unreadOnly = false;

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotificationHistory();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── HEADER ───
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D3B66),
                  ),
                ),
                const Spacer(),
                // Settings button
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, '/notification-preferences'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D3B66).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Color(0xFF0D3B66),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── FILTER CHIPS ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildFilterChip('All', !_unreadOnly),
                const SizedBox(width: 8),
                _buildFilterChip('Unread', _unreadOnly),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── NOTIFICATION LIST ───
          Expanded(
            child: BlocConsumer<NotificationCubit, NotificationState>(
              listener: (context, state) {
                if (state is NotificationActionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error),
                      backgroundColor: Colors.red.shade400,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              buildWhen: (previous, current) {
                return current is NotificationLoading ||
                    current is NotificationHistoryLoaded ||
                    current is NotificationError;
              },
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is NotificationError) {
                  return _buildErrorWidget(state.error);
                }

                if (state is NotificationHistoryLoaded) {
                  final notifications = _unreadOnly
                      ? state.notifications.where((n) => !n.isRead).toList()
                      : state.notifications;

                  if (notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () => context
                        .read<NotificationCubit>()
                        .loadNotificationHistory(
                            unreadOnly: _unreadOnly ? true : null),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 0),
                      itemBuilder: (context, index) =>
                          _buildNotificationCard(notifications[index]),
                    ),
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

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _unreadOnly = label == 'Unread';
        });
        context.read<NotificationCubit>().loadNotificationHistory(
              unreadOnly: _unreadOnly ? true : null,
            );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D3B66) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D3B66) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final bool isUnread = !notification.isRead;

    // Pick icon based on notification type
    IconData notifIcon;
    Color notifColor;
    if (notification.type.contains('assigned') ||
        notification.type.contains('assignment')) {
      notifIcon = Icons.assignment_outlined;
      notifColor = const Color(0xFF4A90D9);
    } else if (notification.type.contains('resolved') ||
        notification.type.contains('completed')) {
      notifIcon = Icons.check_circle_outline;
      notifColor = const Color(0xFF2ECC71);
    } else if (notification.type.contains('declined') ||
        notification.type.contains('closed')) {
      notifIcon = Icons.cancel_outlined;
      notifColor = const Color(0xFFE74C3C);
    } else if (notification.type.contains('media') ||
        notification.type.contains('upload')) {
      notifIcon = Icons.image_outlined;
      notifColor = const Color(0xFF9B59B6);
    } else if (notification.type.contains('voted') ||
        notification.type.contains('confirm')) {
      notifIcon = Icons.thumb_up_outlined;
      notifColor = const Color(0xFFF39C12);
    } else {
      notifIcon = Icons.notifications_outlined;
      notifColor = const Color(0xFF0D3B66);
    }

    // Format date
    String formattedDate = '';
    try {
      final dt = DateTime.parse(notification.createdAt);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) {
        formattedDate = 'Just now';
      } else if (diff.inMinutes < 60) {
        formattedDate = '${diff.inMinutes}m ago';
      } else if (diff.inHours < 24) {
        formattedDate = '${diff.inHours}h ago';
      } else if (diff.inDays < 7) {
        formattedDate = '${diff.inDays}d ago';
      } else {
        formattedDate = DateFormat('MMM dd').format(dt);
      }
    } catch (_) {
      formattedDate = notification.createdAt;
    }

    return GestureDetector(
      onTap: () {
        if (isUnread) {
          context.read<NotificationCubit>().markAsRead(notification.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread
              ? const Color(0xFF0D3B66).withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isUnread
              ? Border.all(
                  color: const Color(0xFF0D3B66).withOpacity(0.12), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: notifColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notifIcon, color: notifColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w500,
                            color: const Color(0xFF1A1D26),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A90D9),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notification.message.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF0D3B66).withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: Color(0xFF0D3B66),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _unreadOnly ? 'All caught up!' : 'No notifications yet',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D26),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _unreadOnly
                ? 'You have no unread notifications.'
                : 'Your notifications will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline,
                  size: 48, color: Colors.red.shade300),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load notifications',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.red.shade400),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context
                  .read<NotificationCubit>()
                  .loadNotificationHistory(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B66),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
