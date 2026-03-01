import '../models/report_model.dart';
import '../mock_data.dart';

class ReportService {
  Stream<List<ReportModel>> getAllReports() => MockReports.allStream;

  Stream<List<ReportModel>> getUserReports(String userId) =>
      MockReports.userStream;

  Future<void> saveReport(ReportModel report) async {
    // no-op in UI mode
  }

  Future<void> updateReportStatus(String reportId, String newStatus) async {
    // no-op in UI mode
  }

  Future<void> deleteReport(String reportId) async {
    // no-op in UI mode
  }
}
