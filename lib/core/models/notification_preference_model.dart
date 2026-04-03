class NotificationPreferenceModel {
  final String eventType;
  bool broadcastEnabled;
  bool pushEnabled;
  bool smsEnabled;
  bool emailEnabled;

  NotificationPreferenceModel({
    required this.eventType,
    this.broadcastEnabled = true,
    this.pushEnabled = true,
    this.smsEnabled = false,
    this.emailEnabled = true,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      eventType: json['event_type'] ?? '',
      broadcastEnabled: json['broadcast_enabled'] ?? true,
      pushEnabled: json['push_enabled'] ?? true,
      smsEnabled: json['sms_enabled'] ?? false,
      emailEnabled: json['email_enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'broadcast_enabled': broadcastEnabled,
      'push_enabled': pushEnabled,
      'sms_enabled': smsEnabled,
      'email_enabled': emailEnabled,
    };
  }

  /// Display-friendly event type name (e.g. "ticket_assigned" → "Ticket Assigned")
  String get displayName {
    return eventType
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  /// Icon description hint based on event type
  String get iconHint {
    if (eventType.contains('ticket_created')) return 'New ticket created';
    if (eventType.contains('ticket_updated')) return 'Ticket info updated';
    if (eventType.contains('ticket_assigned')) return 'Ticket assigned to you';
    if (eventType.contains('ticket_resolved')) return 'Ticket marked resolved';
    if (eventType.contains('assignment_accepted')) return 'Assignment was accepted';
    if (eventType.contains('assignment_declined')) return 'Assignment was declined';
    if (eventType.contains('assignment_status')) return 'Assignment status changed';
    if (eventType.contains('ticket_voted')) return 'Someone voted on a ticket';
    if (eventType.contains('media_uploaded')) return 'Media file uploaded';
    return 'Notification event';
  }
}
