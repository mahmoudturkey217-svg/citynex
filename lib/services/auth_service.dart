import '../models/user_model.dart';
import '../mock_data.dart';

class AuthService {
  bool get isEmailPasswordUser => true;

  Future<UserModel> registerUser(
      String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return UserModel(
      uid: MockUser.uid,
      name: name,
      email: email,
      role: 'user',
    );
  }

  Future<UserModel> loginUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return UserModel(
      uid: MockUser.uid,
      name: MockUser.name,
      email: MockUser.email,
      role: MockUser.role,
    );
  }

  Future<UserModel?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return UserModel(
      uid: MockUser.uid,
      name: MockUser.name,
      email: MockUser.email,
      role: MockUser.role,
    );
  }

  Future<void> logoutUser() async {}

  Future<UserModel> getCurrentUser(String uid) async {
    return UserModel(
      uid: MockUser.uid,
      name: MockUser.name,
      email: MockUser.email,
      role: MockUser.role,
    );
  }

  Future<String> getUserRole() async => MockUser.role;

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // no-op in UI mode
  }

  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // no-op in UI mode
  }
}
