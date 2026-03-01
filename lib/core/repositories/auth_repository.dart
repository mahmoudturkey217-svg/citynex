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
      }

      return model;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
