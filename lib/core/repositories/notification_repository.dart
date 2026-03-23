import '../api/dio_helper.dart';
import '../api/api_endpoints.dart';
import '../models/notification_model.dart';
import '../models/notification_preference_model.dart';
import '../utils/cache_helper.dart';
import '../api/error_handler.dart';

class NotificationRepository {
  String get _role => CacheHelper.getData(key: 'user_role') ?? 'citizen';

  String get _prefsUrl => _role == 'technician'
      ? ApiEndpoints.technicianNotificationPrefs
      : ApiEndpoints.citizenNotificationPrefs;

  String get _historyUrl => _role == 'technician'
      ? ApiEndpoints.technicianNotificationHistory
      : ApiEndpoints.citizenNotificationHistory;

  String get _notifUrl => _role == 'technician'
      ? ApiEndpoints.technicianNotifications
      : ApiEndpoints.citizenNotifications;

  /// GET all notification preferences
  Future<List<NotificationPreferenceModel>> getAllPreferences() async {
    try {
      final token = CacheHelper.getData(key: 'token');
      final response = await DioHelper.getData(
        url: _prefsUrl,
        token: token,
      );

      final List<NotificationPreferenceModel> preferences = [];
      final rawData = response.data['data'];

      if (rawData is List) {
        for (var item in rawData) {
          try {
            preferences.add(NotificationPreferenceModel.fromJson(item));
          } catch (e) {
            print('⚠️ Skipping bad preference: $e');
          }
        }
      }

      return preferences;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// GET preference for a specific event type
  Future<NotificationPreferenceModel> getPreferenceForEventType(
      String eventType) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      final response = await DioHelper.getData(
        url: '$_prefsUrl/$eventType',
        token: token,
      );

      return NotificationPreferenceModel.fromJson(response.data['data']);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// PUT update notification preference for a specific event type
  Future<NotificationPreferenceModel> updatePreference(
    String eventType, {
    bool? broadcastEnabled,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? emailEnabled,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      final Map<String, dynamic> body = {};
      if (broadcastEnabled != null) body['broadcast_enabled'] = broadcastEnabled;
      if (pushEnabled != null) body['push_enabled'] = pushEnabled;
      if (smsEnabled != null) body['sms_enabled'] = smsEnabled;
      if (emailEnabled != null) body['email_enabled'] = emailEnabled;

      final response = await DioHelper.putData(
        url: '$_prefsUrl/$eventType',
        data: body,
        token: token,
      );

      return NotificationPreferenceModel.fromJson(response.data['data']);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// GET paginated notification history
  Future<NotificationHistoryResponseModel> getNotificationHistory({
    int? perPage,
    bool? unreadOnly,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      final Map<String, dynamic> query = {};
      if (perPage != null) query['per_page'] = perPage;
      if (unreadOnly != null) query['unread_only'] = unreadOnly.toString();

      final response = await DioHelper.getData(
        url: _historyUrl,
        query: query.isNotEmpty ? query : null,
        token: token,
      );

      return NotificationHistoryResponseModel.fromJson(response.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// POST mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      await DioHelper.postData(
        url: '$_notifUrl/$notificationId/mark-read',
        data: {},
        token: token,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
