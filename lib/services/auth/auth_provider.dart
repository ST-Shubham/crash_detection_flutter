import 'package:crash_detection_and_analysis/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> intialize();
  AuthUser? get currentUser;
  Future<AuthUser> login({
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> refreshUserCredentials();
}
