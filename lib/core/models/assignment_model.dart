import 'ticket_model.dart';

class AssignmentModel {
  final int id;
  final double score;
  final String status;
  final bool aiVerified;
  final String assignedAt;
  final TicketModel ticket;

  AssignmentModel({
    required this.id,
    required this.score,
    required this.status,
    required this.aiVerified,
    required this.assignedAt,
    required this.ticket,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] ?? 0,
      score: _parseDouble(json['score']),
      status: json['status'] ?? 'Pending',
      aiVerified: json['ai_verified'] ?? false,
      assignedAt: json['assigned_at'] ?? '',
      ticket: TicketModel.fromJson(json['ticket'] ?? {}),
    );
  }

  /// Safely parse a value that may be a String, num, or null into a double.
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'score': score,
      'status': status,
      'ai_verified': aiVerified,
      'assigned_at': assignedAt,
      'ticket': ticket.toJson(),
    };
  }

  /// Display-friendly status string (e.g. "In_Progress" → "In Progress")
  String get displayStatus => status.replaceAll('_', ' ');
}

class AssignmentsResponseModel {
  final bool success;
  final List<AssignmentModel> data;

  AssignmentsResponseModel({required this.success, required this.data});

  factory AssignmentsResponseModel.fromJson(Map<String, dynamic> json) {
    final List<AssignmentModel> assignments = [];

    // Handle both paginated and non-paginated responses:
    // Paginated (Laravel): { "data": { "data": [...], "current_page": 1, ... } }
    // Non-paginated:       { "data": [...] }
    dynamic rawData = json['data'];
    List? itemsList;

    if (rawData is List) {
      // Direct list
      itemsList = rawData;
    } else if (rawData is Map) {
      // Paginated — the actual items are in data.data
      final nested = rawData['data'];
      if (nested is List) {
        itemsList = nested;
      }
    }

    if (itemsList != null) {
      for (var item in itemsList) {
        try {
          assignments.add(AssignmentModel.fromJson(item));
        } catch (e) {
          print('⚠️ Skipping bad assignment (id=${item['id']}): $e');
        }
      }
    }

    return AssignmentsResponseModel(
      success: json['success'] ?? false,
      data: assignments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
