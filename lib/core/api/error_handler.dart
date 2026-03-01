import 'package:dio/dio.dart';

class ErrorHandler {
  static String handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "Connection timeout";
        case DioExceptionType.sendTimeout:
          return "Send timeout";
        case DioExceptionType.receiveTimeout:
          return "Receive timeout";
        case DioExceptionType.badResponse:
          if (error.response != null && error.response?.data != null) {
            String message = '';
            try {
              if (error.response?.data is Map) {
                if (error.response?.data['message'] != null) {
                  message = error.response?.data['message'];
                } else if (error.response?.data['errors'] != null) {
                  // Example logic for Laravel validation errors
                  final errors = error.response?.data['errors'] as Map;
                  message = errors.values.first[0].toString();
                } else {
                  message = 'Something went wrong';
                }
              }
            } catch (e) {
              message = 'Bad response from server';
            }
            return message;
          }
          return "Bad response";
        case DioExceptionType.cancel:
          return "Request cancelled";
        case DioExceptionType.connectionError:
          return "No internet connection";
        case DioExceptionType.badCertificate:
          return "Bad certificate";
        case DioExceptionType.unknown:
          return "Unexpected error occurred";
      }
    } else {
      return "Unexpected error occurred";
    }
  }
}
