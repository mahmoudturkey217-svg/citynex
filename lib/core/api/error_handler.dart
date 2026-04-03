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
                if (error.response?.data['errors'] != null) {
                  final errors = error.response?.data['errors'];
                  if (errors is Map && errors.isNotEmpty) {
                    final firstError = errors.values.first;
                    if (firstError is List && firstError.isNotEmpty) {
                      message = firstError.first.toString();
                    } else {
                      message = firstError.toString();
                    }
                  } else {
                    message = error.response?.data['message'] ?? 'Validation failed';
                  }
                } else if (error.response?.data['message'] != null) {
                  message = error.response?.data['message'];
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
