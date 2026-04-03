import 'package:dio/dio.dart';
import '../api/api_endpoints.dart';
import '../api/dio_helper.dart';
import '../api/error_handler.dart';
import '../models/auth_response_model.dart';
import '../utils/cache_helper.dart';

class AuthRepository {
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'locale': 'en',
      });

      final response = await DioHelper.postData(
        url: ApiEndpoints.register,
        data: formData,
      );

      final model = AuthResponseModel.fromJson(response.data);

      if (model.success == true && model.data?.token != null) {
        await CacheHelper.saveData(key: 'token', value: model.data!.token);
        final user = model.data!.user;
        if (user != null) {
          await CacheHelper.saveData(key: 'user_name', value: user.name ?? '');
          await CacheHelper.saveData(key: 'user_email', value: user.email ?? '');
          await CacheHelper.saveData(key: 'user_phone', value: user.phone ?? '');
          await CacheHelper.saveData(key: 'user_role', value: (user.roles != null && user.roles!.isNotEmpty) ? user.roles!.first.toLowerCase() : 'citizen');
          await CacheHelper.saveData(key: 'user_rating', value: user.rating ?? '0');
          await CacheHelper.saveData(key: 'user_avatar', value: user.avatarUrl ?? '');
        }
      }

      return model;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'email': email,
        'password': password,
      });

      final response = await DioHelper.postData(
        url: ApiEndpoints.login,
        data: formData,
      );

      final model = AuthResponseModel.fromJson(response.data);

      if (model.success == true && model.data?.token != null) {
        await CacheHelper.saveData(key: 'token', value: model.data!.token);
        final user = model.data!.user;
        if (user != null) {
          await CacheHelper.saveData(key: 'user_name', value: user.name ?? '');
          await CacheHelper.saveData(key: 'user_email', value: user.email ?? '');
          await CacheHelper.saveData(key: 'user_phone', value: user.phone ?? '');
          await CacheHelper.saveData(key: 'user_role', value: (user.roles != null && user.roles!.isNotEmpty) ? user.roles!.first.toLowerCase() : 'citizen');
          await CacheHelper.saveData(key: 'user_rating', value: user.rating ?? '0');
          await CacheHelper.saveData(key: 'user_avatar', value: user.avatarUrl ?? '');
        }
      }

      return model;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<AuthResponseModel> forgotPassword({required String email}) async {
    try {
      FormData formData = FormData.fromMap({
        'email': email,
      });

      final response = await DioHelper.postData(
        url: ApiEndpoints.forgotPassword,
        data: formData,
      );

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<AuthResponseModel> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      final response = await DioHelper.postData(
        url: ApiEndpoints.resetPassword,
        data: formData,
      );

      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// PUT auth/profile – update name (and optionally phone)
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      FormData formData = FormData.fromMap({
        '_method': 'PUT', // Laravel form‐method spoofing
        'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });

      final response = await DioHelper.postData(
        url: ApiEndpoints.updateProfile,
        data: formData,
        token: token,
        isMultipart: true,
      );

      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        final user = data['data'];
        await CacheHelper.saveData(key: 'user_name', value: user['name'] ?? '');
        if (user['phone'] != null) {
          await CacheHelper.saveData(key: 'user_phone', value: user['phone'].toString());
        }
        if (user['avatar_url'] != null) {
          await CacheHelper.saveData(key: 'user_avatar', value: user['avatar_url']);
        }
      }

      return data;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// POST auth/profile/avatar – upload profile picture
  Future<Map<String, dynamic>> uploadAvatar({
    required String filePath,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      FormData formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: 'avatar.jpg'),
      });

      final response = await DioHelper.postData(
        url: ApiEndpoints.profileAvatar,
        data: formData,
        token: token,
        isMultipart: true,
      );

      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        final user = data['data'];
        if (user['avatar_url'] != null) {
          await CacheHelper.saveData(key: 'user_avatar', value: user['avatar_url']);
        }
      }

      return data;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// PUT auth/change-password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      FormData formData = FormData.fromMap({
        '_method': 'PUT',
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      final response = await DioHelper.postData(
        url: ApiEndpoints.changePassword,
        data: formData,
        token: token,
        isMultipart: true,
      );

      return response.data;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
