import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'logic/notification_cubit.dart';
import 'logic/notification_state.dart';
import '../../core/models/notification_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/widgets/shared_widgets.dart';
import '../../core/widgets/feedback_states.dart';

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
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                // Mark all read
                GestureDetector(
                  onTap: () {
                    context.read<NotificationCubit>().markAllAsRead();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.done_all,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Settings button
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, '/notification-preferences'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.primary,
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
                  AppSnackbar.show(context,
                      message: state.error, isError: true);
                }
              },
              buildWhen: (previous, current) {
                return current is NotificationLoading ||
                    current is NotificationHistoryLoaded ||
                    current is NotificationError;
              },
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return Skeletonizer(
                    enabled: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 5,
                      itemBuilder: (_, __) => _buildSkeletonNotification(),
                    ),
                  );
                }

                if (state is NotificationError) {
                  return ErrorState(
                    title: 'Failed to load notifications',
                    error: state.error,
                    onRetry: () => context
                        .read<NotificationCubit>()
                        .loadNotificationHistory(),
                  );
                }

                if (state is NotificationHistoryLoaded) {
                  final notifications = _unreadOnly
                      ? state.notifications
                          .where((n) => !n.isRead)
                          .toList()
                      : state.notifications;

                  if (notifications.isEmpty) {
                    return EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: _unreadOnly
                          ? 'All caught up!'
                          : 'No notifications yet',
                      subtitle: _unreadOnly
                          ? 'You have no unread notifications'
                          : 'Your notifications will appear here',
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context
                        .read<NotificationCubit>()
                        .loadNotificationHistory(
                            unreadOnly: _unreadOnly ? true : null),
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 0),
                      itemBuilder: (context, index) =>
                          _buildNotificationCard(notifications[index]),
                    ),
                  );
                }

                return EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'No notifications yet',
                  subtitle: 'Your notifications will appear here',
                );
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
        setState(() => _unreadOnly = label == 'Unread');
        context.read<NotificationCubit>().loadNotificationHistory(
              unreadOnly: _unreadOnly ? true : null,
            );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonNotification() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: AppDimensions.borderRadiusMd,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 160, height: 14, color: AppColors.surfaceLight),
                const SizedBox(height: 6),
                Container(width: 120, height: 10, color: AppColors.surfaceLight),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final bool isUnread = !notification.isRead;

    IconData notifIcon;
    Color notifColor;
    if (notification.type.contains('assigned') ||
        notification.type.contains('assignment')) {
      notifIcon = Icons.assignment_outlined;
      notifColor = AppColors.open;
    } else if (notification.type.contains('resolved') ||
        notification.type.contains('completed')) {
      notifIcon = Icons.check_circle_outline;
      notifColor = AppColors.resolved;
    } else if (notification.type.contains('declined') ||
        notification.type.contains('closed')) {
      notifIcon = Icons.cancel_outlined;
      notifColor = AppColors.declined;
    } else if (notification.type.contains('media') ||
        notification.type.contains('upload')) {
      notifIcon = Icons.image_outlined;
      notifColor = AppColors.inProgress;
    } else if (notification.type.contains('voted') ||
        notification.type.contains('confirm')) {
      notifIcon = Icons.thumb_up_outlined;
      notifColor = AppColors.pending;
    } else {
      notifIcon = Icons.notifications_outlined;
      notifColor = AppColors.primary;
    }

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
              ? AppColors.primary.withOpacity(0.04)
              : AppColors.cardBg,
          borderRadius: AppDimensions.borderRadiusMd,
          border: isUnread
              ? Border.all(color: AppColors.primary.withOpacity(0.12))
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
                            color: AppColors.textPrimary,
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
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notification.message.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
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
}
