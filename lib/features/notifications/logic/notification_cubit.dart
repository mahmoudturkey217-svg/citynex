import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/notification_repository.dart';
import '../../../core/models/notification_model.dart';
import '../../../core/models/notification_preference_model.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationCubit(this.notificationRepository) : super(NotificationInitial());

  /// Cached data for restoring after action states
  List<NotificationPreferenceModel> _cachedPreferences = [];
  List<NotificationModel> _cachedNotifications = [];

  /// Load all notification preferences
  Future<void> loadPreferences() async {
    emit(NotificationLoading());
    try {
      final preferences = await notificationRepository.getAllPreferences();
      _cachedPreferences = List.from(preferences);
      emit(NotificationPreferencesLoaded(preferences: _cachedPreferences));
    } catch (e) {
      emit(NotificationError(error: e.toString()));
    }
  }

  /// Update a single preference and refresh
  Future<void> updatePreference(
    String eventType, {
    bool? broadcastEnabled,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? emailEnabled,
  }) async {
    try {
      await notificationRepository.updatePreference(
        eventType,
        broadcastEnabled: broadcastEnabled,
        pushEnabled: pushEnabled,
        smsEnabled: smsEnabled,
        emailEnabled: emailEnabled,
      );

      // Update local cache
      final idx = _cachedPreferences.indexWhere((p) => p.eventType == eventType);
      if (idx >= 0) {
        if (broadcastEnabled != null) {
          _cachedPreferences[idx].broadcastEnabled = broadcastEnabled;
        }
        if (pushEnabled != null) {
          _cachedPreferences[idx].pushEnabled = pushEnabled;
        }
        if (smsEnabled != null) {
          _cachedPreferences[idx].smsEnabled = smsEnabled;
        }
        if (emailEnabled != null) {
          _cachedPreferences[idx].emailEnabled = emailEnabled;
        }
      }

      emit(NotificationPreferencesLoaded(
        preferences: List.from(_cachedPreferences),
      ));
    } catch (e) {
      emit(NotificationActionError(error: e.toString()));
      // Restore cached state
      emit(NotificationPreferencesLoaded(preferences: _cachedPreferences));
    }
  }

  /// Load notification history
  Future<void> loadNotificationHistory({
    int? perPage,
    bool? unreadOnly,
  }) async {
    emit(NotificationLoading());
    try {
      final response = await notificationRepository.getNotificationHistory(
        perPage: perPage ?? 30,
        unreadOnly: unreadOnly,
      );

      _cachedNotifications = List.from(response.notifications);
      emit(NotificationHistoryLoaded(
        notifications: _cachedNotifications,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
      ));
    } catch (e) {
      emit(NotificationError(error: e.toString()));
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await notificationRepository.markNotificationAsRead(notificationId);

      // Update local cache
      final idx = _cachedNotifications.indexWhere((n) => n.id == notificationId);
      if (idx >= 0) {
        _cachedNotifications[idx] = NotificationModel(
          id: _cachedNotifications[idx].id,
          type: _cachedNotifications[idx].type,
          title: _cachedNotifications[idx].title,
          message: _cachedNotifications[idx].message,
          isRead: true,
          createdAt: _cachedNotifications[idx].createdAt,
          data: _cachedNotifications[idx].data,
        );
      }

      emit(NotificationHistoryLoaded(
        notifications: List.from(_cachedNotifications),
      ));
    } catch (e) {
      emit(NotificationActionError(error: e.toString()));
      emit(NotificationHistoryLoaded(notifications: _cachedNotifications));
    }
  }

  /// Mark all unread notifications as read
  Future<void> markAllAsRead() async {
    try {
      final unreadNotifications = _cachedNotifications.where((n) => n.isRead == false).toList();
      
      for (var notification in unreadNotifications) {
        if (notification.id != null) {
          // If the backend doesn't have a bulk 'markAllAsRead' endpoint, we loop through them
          await notificationRepository.markNotificationAsRead(notification.id!);
          
          final idx = _cachedNotifications.indexWhere((n) => n.id == notification.id);
          if (idx >= 0) {
            _cachedNotifications[idx] = NotificationModel(
              id: _cachedNotifications[idx].id,
              type: _cachedNotifications[idx].type,
              title: _cachedNotifications[idx].title,
              message: _cachedNotifications[idx].message,
              isRead: true,
              createdAt: _cachedNotifications[idx].createdAt,
              data: _cachedNotifications[idx].data,
            );
          }
        }
      }

      emit(NotificationHistoryLoaded(
        notifications: List.from(_cachedNotifications),
      ));
    } catch (e) {
      emit(NotificationActionError(error: e.toString()));
      emit(NotificationHistoryLoaded(notifications: _cachedNotifications));
    }
  }
}
