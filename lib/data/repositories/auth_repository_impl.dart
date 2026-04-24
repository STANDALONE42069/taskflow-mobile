import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<UserEntity> register(String fullName, String email, String password) {
    return remoteDataSource.register(fullName, email, password);
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return null;
  }

  @override
  Future<List<UserEntity>> getAllUsers() {
    return remoteDataSource.getAllUsers();
  }
}