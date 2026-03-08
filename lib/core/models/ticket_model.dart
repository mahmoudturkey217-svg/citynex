import 'ticket_media_model.dart';

class TicketModel {
  final int id;
  final String title;
  final String description;
  final String priority;
  final String status;
  final double lat;
  final double lng;
  final int confirmedCount;
  final bool emergencyFlag;
  final TicketCategory category;
  final TicketArea area;
  final String createdAt;
  final String updatedAt;
  final List<TicketMediaModel>? media;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.lat,
    required this.lng,
    required this.confirmedCount,
    required this.emergencyFlag,
    required this.category,
    required this.area,
    required this.createdAt,
    required this.updatedAt,
    this.media,
  });

  /// Safely parse a value that may be a String, num, or null into a double.
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    
    // Parse media list if present — skip individual bad items
    List<TicketMediaModel> mediaList = [];
    if (json['media'] != null && json['media'] is List) {
      for (var item in json['media'] as List) {
        try {
          mediaList.add(TicketMediaModel.fromJson(item));
        } catch (e) {
          print('⚠️ Skipping bad media item in ticket ${json['id']}: $e');
        }
      }
    }

    return TicketModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Low',
      status: json['status'] ?? 'Open',
      lat: _parseDouble(location['lat']),
      lng: _parseDouble(location['lng']),
      confirmedCount: json['confirmed_count'] ?? 0,
      emergencyFlag: json['emergency_flag'] ?? false,
      category: json['category'] != null
          ? TicketCategory.fromJson(json['category'])
          : TicketCategory(id: 0, name: 'Unknown'),
      area: json['area'] != null
          ? TicketArea.fromJson(json['area'])
          : TicketArea(id: 0, name: 'Unknown'),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      media: mediaList ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'location': {
        'lat': lat,
        'lng': lng,
      },
      'confirmed_count': confirmedCount,
      'emergency_flag': emergencyFlag,
      'category': category.toJson(),
      'area': area.toJson(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      // media serialization omitted for brevity as it's mostly used for reading
    };
  }
}

class TicketCategory {
  final int id;
  final String name;

  TicketCategory({required this.id, required this.name});

  factory TicketCategory.fromJson(Map<String, dynamic> json) {
    return TicketCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TicketArea {
  final int id;
  final String name;

  TicketArea({required this.id, required this.name});

  factory TicketArea.fromJson(Map<String, dynamic> json) {
    return TicketArea(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TicketsResponseModel {
  final bool success;
  final List<TicketModel> data;

  TicketsResponseModel({required this.success, required this.data});

  factory TicketsResponseModel.fromJson(Map<String, dynamic> json) {
    // Parse each ticket individually — skip bad ones instead of crashing the whole list
    final List<TicketModel> tickets = [];
    if (json['data'] != null && json['data'] is List) {
      for (var item in json['data'] as List) {
        try {
          tickets.add(TicketModel.fromJson(item));
        } catch (e) {
          print('⚠️ Skipping bad ticket (id=${item['id']}): $e');
        }
      }
    }
    return TicketsResponseModel(
      success: json['success'] ?? false,
      data: tickets,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}
