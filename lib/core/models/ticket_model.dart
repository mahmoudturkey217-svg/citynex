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
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    return TicketModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'Low',
      status: json['status'] ?? 'Open',
      lat: (location['lat'] ?? 0.0).toDouble(),
      lng: (location['lng'] ?? 0.0).toDouble(),
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
    );
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
}

class TicketsResponseModel {
  final bool success;
  final List<TicketModel> data;

  TicketsResponseModel({required this.success, required this.data});

  factory TicketsResponseModel.fromJson(Map<String, dynamic> json) {
    return TicketsResponseModel(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => TicketModel.fromJson(e))
              .toList()
          : [],
    );
  }
}
