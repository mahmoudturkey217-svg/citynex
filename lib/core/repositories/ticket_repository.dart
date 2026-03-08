import 'package:dio/dio.dart';
import '../api/dio_helper.dart';
import '../api/api_endpoints.dart';
import '../models/ticket_model.dart';
import '../models/ticket_media_model.dart';
import '../utils/cache_helper.dart';
import '../api/error_handler.dart';
import 'package:http_parser/http_parser.dart';

class TicketRepository {
  Future<TicketsResponseModel> getTickets({
    String? status,
    String? priority,
    int? categoryId,
    int? areaId,
    int? perPage,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      final Map<String, dynamic> query = {};
      if (status != null && status.isNotEmpty && status != 'All') {
        query['status'] = status;
      }
      if (priority != null && priority.isNotEmpty) {
        query['priority'] = priority;
      }
      if (categoryId != null) query['category_id'] = categoryId;
      if (areaId != null) query['area_id'] = areaId;
      if (perPage != null) query['per_page'] = perPage;

      final response = await DioHelper.getData(
        url: ApiEndpoints.citizenTickets,
        query: query.isNotEmpty ? query : null,
        token: token,
      );

      return TicketsResponseModel.fromJson(response.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required int categoryId,
    required int areaId,
    required double lat,
    required double lng,
    required String priority,
    bool emergencyFlag = false,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      // Debug: verify location values before sending
      print('📍 Sending location: lat=$lat, lng=$lng');

      // Send location as flat fields so the backend can parse them correctly.
      // Using location_lat / location_lng instead of nested location[lat] / location[lng].
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'category_id': categoryId.toString(),
        'area_id': areaId.toString(),
        'location_lat': lat.toStringAsFixed(8),
        'location_lng': lng.toStringAsFixed(8),
        'priority': priority,
        'emergency_flag': emergencyFlag ? '1' : '0',
      });

      final response = await DioHelper.postData(
        url: ApiEndpoints.citizenTickets,
        data: formData,
        token: token,
        isMultipart: true,
      );

      // The create-ticket response nests the ticket under data.ticket
      final data = response.data['data'];
      final ticketJson = data is Map && data.containsKey('ticket')
          ? data['ticket']
          : data;
      final ticket = TicketModel.fromJson(ticketJson);
      // Debug: verify location values from API response
      print('📍 Response location: lat=${ticket.lat}, lng=${ticket.lng}');
      return ticket;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<TicketModel> confirmTicket(int ticketId) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      final response = await DioHelper.postData(
        url: '${ApiEndpoints.citizenTickets}/$ticketId/confirm',
        data: {},
        token: token,
      );

      return TicketModel.fromJson(response.data['data']);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> uploadTicketMedia({
    required int ticketId,
    required String filePath,
    String beforeAfter = 'Before',
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      
      String fileName = filePath.split('/').last;
      
      FormData formData = FormData.fromMap({
        'before_after': beforeAfter,
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      await DioHelper.postData(
        url: '${ApiEndpoints.citizenTickets}/$ticketId/media',
        data: formData,
        token: token,
        isMultipart: true,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Fetch a single ticket's details (which includes its media array).
  Future<Map<String, dynamic>> getTicketDetails(int ticketId) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      final response = await DioHelper.getData(
        url: '${ApiEndpoints.citizenTickets}/$ticketId',
        token: token,
      );

      final data = response.data['data'];
      // The response may nest the ticket under 'ticket' key or return it directly
      final ticketJson = data is Map && data.containsKey('ticket')
          ? data['ticket']
          : data;

      final ticket = TicketModel.fromJson(ticketJson);

      // Parse media list if present
      final List<TicketMediaModel> mediaList = [];
      final mediaJson = ticketJson['media'] ?? data['media'];
      if (mediaJson != null && mediaJson is List) {
        for (var item in mediaJson) {
          mediaList.add(TicketMediaModel.fromJson(item));
        }
      }

      return {'ticket': ticket, 'media': mediaList};
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Get a signed URL for a specific media item.
  Future<String> getMediaSignedUrl(int ticketId, int mediaId) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      final response = await DioHelper.getData(
        url: '${ApiEndpoints.citizenTickets}/$ticketId/media/$mediaId/url',
        query: {'expires_in': 3600},
        token: token,
      );

      return response.data['data']['url'] ?? '';
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> deleteTicketMedia(int ticketId, int mediaId) async {
    try {
      final token = CacheHelper.getData(key: 'token');
      await DioHelper.deleteData(
        url: '${ApiEndpoints.citizenTickets}/$ticketId/media/$mediaId',
        token: token,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}

