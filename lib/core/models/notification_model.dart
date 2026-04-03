class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? json['data']?['title'] ?? 'Notification',
      message: json['message'] ?? json['data']?['message'] ?? '',
      isRead: json['read_at'] != null,
      createdAt: json['created_at'] ?? '',
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }

  /// Display-friendly event type
  String get displayType => type
      .replaceAll('_', ' ')
      .replaceAll('App\\\\Notifications\\\\', '')
      .split('\\')
      .last
      .replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => ' ${match.group(0)}',
      )
      .trim();
}

class NotificationHistoryResponseModel {
  final bool success;
  final List<NotificationModel> notifications;
  final int? currentPage;
  final int? lastPage;

  NotificationHistoryResponseModel({
    required this.success,
    required this.notifications,
    this.currentPage,
    this.lastPage,
  });

  factory NotificationHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final List<NotificationModel> items = [];

    dynamic rawData = json['data'];
    List? itemsList;

    if (rawData is List) {
      itemsList = rawData;
    } else if (rawData is Map) {
      final nested = rawData['data'];
      if (nested is List) {
        itemsList = nested;
      }
    }

    if (itemsList != null) {
      for (var item in itemsList) {
        try {
          items.add(NotificationModel.fromJson(item));
        } catch (e) {
          print('⚠️ Skipping bad notification: $e');
        }
      }
    }

    int? currentPage;
    int? lastPage;
    if (rawData is Map) {
      currentPage = rawData['current_page'];
      lastPage = rawData['last_page'];
    }

    return NotificationHistoryResponseModel(
      success: json['success'] ?? false,
      notifications: items,
      currentPage: currentPage,
      lastPage: lastPage,
    );
  }
}
