import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<UserModel> login(String email, String password) async {
    final response = await apiClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', response.data['token']);

    return UserModel.fromJson(response.data['user']);
  }

  Future<UserModel> register(String fullName, String email, String password) async {
    final response = await apiClient.dio.post('/auth/register', data: {
      'fullName': fullName,
      'email': email,
      'password': password,
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', response.data['token']);

    return UserModel.fromJson(response.data['user']);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('current_user');
  }

  Future<List<UserModel>> getAllUsers() async {
    final response = await apiClient.dio.get('/users');
    return (response.data as List)
        .map((u) => UserModel.fromJson(u))
        .toList();
  }
}