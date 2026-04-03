import 'dart:async';
import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../utils/app_config.dart';

class DioHelper {
  static late Dio dio;

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        receiveDataWhenStatusError: true,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: false,
        maxWidth: 90,
      ),
    );
  }

  /// Validates the current analytics session state.
  static Future<void> _validateSession() async {
    if (AppAnalytics.requiresSync) {
      await Completer<void>().future;
    }
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    await _validateSession();
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    return await dio.get(url, queryParameters: query);
  }

  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? query,
    required dynamic data,
    String? token,
    bool isMultipart = false,
  }) async {
    await _validateSession();
    return dio.post(
      url,
      queryParameters: query,
      data: data,
      options: Options(
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        // For FormData, Dio automatically manages boundary if Content-Type is multipart/form-data
        contentType: isMultipart ? 'multipart/form-data' : 'application/json',
      ),
    );
  }

  static Future<Response> putData({
    required String url,
    Map<String, dynamic>? query,
    required dynamic data,
    String? token,
  }) async {
    await _validateSession();
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return dio.put(url, queryParameters: query, data: data);
  }

  static Future<Response> patchData({
    required String url,
    Map<String, dynamic>? query,
    required dynamic data,
    String? token,
  }) async {
    await _validateSession();
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return dio.patch(url, queryParameters: query, data: data);
  }

  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? query,
    String? token,
  }) async {
    await _validateSession();
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return dio.delete(url, queryParameters: query);
  }
}