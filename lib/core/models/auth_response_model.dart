class AuthResponseModel {
  bool? success;
  String? message;
  AuthData? data;

  AuthResponseModel({this.success, this.message, this.data});

  AuthResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? AuthData.fromJson(json['data']) : null;
  }
}

class AuthData {
  UserModel? user;
  String? token;

  AuthData({this.user, this.token});

  AuthData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
    token = json['token'];
  }
}

class UserModel {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? avatarUrl;
  List<String>? roles;
  String? locale;
  String? rating;
  bool? emailVerified;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    this.roles,
    this.locale,
    this.rating,
    this.emailVerified,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone']?.toString();
    avatarUrl = json['avatar_url'];
    if (json['roles'] != null) {
      roles = [];
      json['roles'].forEach((v) {
        roles!.add(v.toString());
      });
    }
    locale = json['locale'];
    rating = json['rating']?.toString();
    emailVerified = json['email_verified'];
  }
}
