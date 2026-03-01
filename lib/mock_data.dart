import 'models/report_model.dart';

// ─── Mock User ────────────────────────────────────────────────────────────────
class MockUser {
  static const String uid = 'mock_user_001';
  static const String name = 'Alex Johnson';
  static const String email = 'alex.johnson@email.com';
  static const String password = '123456';
  static const String role = 'user';
}

class MockAdmin {
  static const String uid = 'mock_admin_001';
  static const String name = 'Sarah Mitchell';
  static const String email = 'admin@citynex.com';
  static const String password = 'admin123';
  static const String role = 'admin';
}

// ─── Mock Reports ─────────────────────────────────────────────────────────────
class MockReports {
  static final List<ReportModel> all = [
    ReportModel(
      id: 'r001',
      userId: MockUser.uid,
      title: 'Large pothole on Main Street',
      description:
          'There is a very large pothole right in front of the pharmacy that is causing damage to vehicles.',
      category: 'Road',
      imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      latitude: 31.7683,
      longitude: 35.2137,
      status: 'In Progress',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ReportModel(
      id: 'r002',
      userId: MockUser.uid,
      title: 'Street light out at Park Ave',
      description:
          'The street light at the corner of Park Avenue and 5th Street has been out for two weeks.',
      category: 'Electricity',
      imageUrl: 'https://images.unsplash.com/photo-1542621334-a254cf47733d?w=400',
      latitude: 31.7700,
      longitude: 35.2150,
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    ReportModel(
      id: 'r003',
      userId: MockUser.uid,
      title: 'Water leak near school',
      description:
          'A water pipe is leaking heavily near the elementary school entrance. The road is flooded.',
      category: 'Water',
      imageUrl: 'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=400',
      latitude: 31.7650,
      longitude: 35.2100,
      status: 'Resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    ReportModel(
      id: 'r004',
      userId: MockUser.uid,
      title: 'Overflowing garbage bins',
      description:
          'Garbage bins on Oak Street have not been emptied in over a week and are overflowing.',
      category: 'Waste',
      imageUrl: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400',
      latitude: 31.7660,
      longitude: 35.2120,
      status: 'Open',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ReportModel(
      id: 'r005',
      userId: MockUser.uid,
      title: 'Broken sidewalk tiles',
      description:
          'Several sidewalk tiles near the bus stop are broken and pose a tripping hazard to pedestrians.',
      category: 'Road',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      latitude: 31.7690,
      longitude: 35.2160,
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    ReportModel(
      id: 'r006',
      userId: 'other_user',
      title: 'Graffiti on community wall',
      description:
          'Offensive graffiti has appeared on the community center wall overnight.',
      category: 'Other',
      imageUrl: 'https://images.unsplash.com/photo-1499781350541-7783f6c6a0c8?w=400',
      latitude: 31.7710,
      longitude: 35.2170,
      status: 'Resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  /// Only the current mock user's reports
  static List<ReportModel> get userReports =>
      all.where((r) => r.userId == MockUser.uid).toList();

  /// Stream of all reports
  static Stream<List<ReportModel>> get allStream =>
      Stream.value(all);

  /// Stream of the current user's reports
  static Stream<List<ReportModel>> get userStream =>
      Stream.value(userReports);
}
