import 'package:dio/dio.dart';
import '../api/dio_helper.dart';
import '../api/api_endpoints.dart';
import '../models/ticket_model.dart';
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
      final data = {
        'title': title,
        'description': description,
        'category_id': categoryId,
        'area_id': areaId,
        'latitude': lat,
        'longitude': lng,
        'priority': priority,
        'emergency_flag': emergencyFlag ? 1 : 0,
      };

      final response = await DioHelper.postData(
        url: ApiEndpoints.citizenTickets,
        data: data,
        token: token,
      );

      return TicketModel.fromJson(response.data['data']);
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
}
