import 'package:dio/dio.dart';
import '../api/dio_helper.dart';
import '../api/api_endpoints.dart';
import '../models/assignment_model.dart';
import '../utils/cache_helper.dart';
import '../api/error_handler.dart';
import 'package:http_parser/http_parser.dart';

class AssignmentRepository {
  Future<AssignmentsResponseModel> getAssignments({
    String? ticketStatus,
    String? priority,
    int? categoryId,
    int? areaId,
    int? perPage,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      print('🔍 [ASSIGNMENTS] Token present: ${token != null}');
      print('🔍 [ASSIGNMENTS] Token first 20 chars: ${token?.toString().substring(0, 20) ?? 'NULL'}...');

      final Map<String, dynamic> query = {};
      if (ticketStatus != null && ticketStatus.isNotEmpty && ticketStatus != 'All') {
        query['ticket_status'] = ticketStatus;
      }
      if (priority != null && priority.isNotEmpty) {
        query['priority'] = priority;
      }
      if (categoryId != null) query['category_id'] = categoryId;
      if (areaId != null) query['area_id'] = areaId;
      if (perPage != null) query['per_page'] = perPage;

      print('🔍 [ASSIGNMENTS] Calling GET ${ApiEndpoints.technicianAssignments} with query: $query');

      final response = await DioHelper.getData(
        url: ApiEndpoints.technicianAssignments,
        query: query.isNotEmpty ? query : null,
        token: token,
      );

      // Deep debug — what did we actually get back?
      print('🔍 [ASSIGNMENTS] Response status: ${response.statusCode}');
      print('🔍 [ASSIGNMENTS] Response data type: ${response.data.runtimeType}');
      print('🔍 [ASSIGNMENTS] Response keys: ${response.data is Map ? (response.data as Map).keys.toList() : 'NOT A MAP'}');
      
      final data = response.data;
      if (data is Map && data['data'] != null) {
        print('🔍 [ASSIGNMENTS] data["data"] type: ${data['data'].runtimeType}');
        if (data['data'] is Map) {
          print('🔍 [ASSIGNMENTS] data["data"] keys: ${(data['data'] as Map).keys.toList()}');
          if (data['data']['data'] != null) {
            print('🔍 [ASSIGNMENTS] data["data"]["data"] type: ${data['data']['data'].runtimeType}');
            if (data['data']['data'] is List) {
              print('🔍 [ASSIGNMENTS] data["data"]["data"] length: ${(data['data']['data'] as List).length}');
            }
          }
        } else if (data['data'] is List) {
          print('🔍 [ASSIGNMENTS] data["data"] is List, length: ${(data['data'] as List).length}');
        }
      }

      final result = AssignmentsResponseModel.fromJson(response.data);
      print('🔍 [ASSIGNMENTS] Parsed result: success=${result.success}, count=${result.data.length}');

      return result;
    } catch (e, stackTrace) {
      print('❌ [ASSIGNMENTS] Error: $e');
      print('❌ [ASSIGNMENTS] Stack: $stackTrace');
      throw ErrorHandler.handle(e);
    }
  }

  /// Accept an assignment: POST /technician/assignments/{id}/accept
  Future<AssignmentModel> acceptAssignment(int assignmentId) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      final response = await DioHelper.postData(
        url: '${ApiEndpoints.technicianAssignments}/$assignmentId/accept',
        data: {},
        token: token,
      );
      return AssignmentModel.fromJson(response.data['data']);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Decline an assignment: POST /technician/assignments/{id}/decline
  Future<void> declineAssignment(int assignmentId) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      await DioHelper.postData(
        url: '${ApiEndpoints.technicianAssignments}/$assignmentId/decline',
        data: {},
        token: token,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Update assignment status: PATCH /technician/assignments/{id}/status
  Future<AssignmentModel> updateAssignmentStatus(int assignmentId, String status) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      final response = await DioHelper.patchData(
        url: '${ApiEndpoints.technicianAssignments}/$assignmentId/status',
        data: {'status': status},
        token: token,
      );
      return AssignmentModel.fromJson(response.data['data']);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Upload media for a ticket: POST /technician/tickets/{id}/media
  Future<void> uploadTicketMedia({
    required int ticketId,
    required String filePath,
    String beforeAfter = 'After',
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      String fileName = filePath.split('/').last;
      if (fileName.contains('\\')) {
        fileName = fileName.split('\\').last;
      }

      FormData formData = FormData.fromMap({
        'before_after': beforeAfter,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      await DioHelper.postData(
        url: '${ApiEndpoints.technicianTickets}/$ticketId/media',
        data: formData,
        token: token,
        isMultipart: true,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Delete media: DELETE /technician/tickets/{ticketId}/media/{mediaId}
  Future<void> deleteTicketMedia(int ticketId, int mediaId) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      await DioHelper.deleteData(
        url: '${ApiEndpoints.technicianTickets}/$ticketId/media/$mediaId',
        token: token,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Get signed URL: GET /technician/tickets/{ticketId}/media/{mediaId}/url
  Future<String> getMediaSignedUrl(int ticketId, int mediaId) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      final response = await DioHelper.getData(
        url: '${ApiEndpoints.technicianTickets}/$ticketId/media/$mediaId/url',
        query: {'expires_in': 3600},
        token: token,
      );
      return response.data['data']['url'] ?? '';
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
