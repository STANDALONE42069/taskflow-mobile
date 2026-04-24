import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String fullName, String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<List<UserEntity>> getAllUsers();
}