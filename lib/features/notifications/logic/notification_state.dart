import '../../../core/models/notification_model.dart';
import '../../../core/models/notification_preference_model.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationPreferencesLoaded extends NotificationState {
  final List<NotificationPreferenceModel> preferences;

  NotificationPreferencesLoaded({required this.preferences});
}

class NotificationHistoryLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int? currentPage;
  final int? lastPage;

  NotificationHistoryLoaded({
    required this.notifications,
    this.currentPage,
    this.lastPage,
  });
}

class NotificationError extends NotificationState {
  final String error;

  NotificationError({required this.error});
}

class NotificationActionSuccess extends NotificationState {
  final String message;

  NotificationActionSuccess({required this.message});
}

class NotificationActionError extends NotificationState {
  final String error;

  NotificationActionError({required this.error});
}
