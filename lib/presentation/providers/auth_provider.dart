import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/di/injection.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? error;
  final List<UserEntity> allUsers;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.allUsers = const [],
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? error,
    List<UserEntity>? allUsers,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      allUsers: allUsers ?? this.allUsers,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final AuthRepositoryImpl _authRepository;

  AuthNotifier(this._loginUseCase, this._registerUseCase, this._authRepository)
      : super(const AuthState()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      final map = json.decode(userJson);
      state = state.copyWith(
        user: UserEntity(
          id: map['id'],
          fullName: map['fullName'],
          email: map['email'],
        ),
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _loginUseCase(email, password);
      await _saveUser(user);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString().replaceAll('Exception:', '').trim());
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _registerUseCase(fullName, email, password);
      await _saveUser(user);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString().replaceAll('Exception:', '').trim());
      return false;
    }
  }

  Future<void> loadAllUsers() async {
    try {
      final users = await _authRepository.getAllUsers();
      state = state.copyWith(allUsers: users);
    } catch (_) {}
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState();
  }

  Future<void> _saveUser(UserEntity user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode({
      'id': user.id,
      'fullName': user.fullName,
      'email': user.email,
    }));
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    sl<LoginUseCase>(),
    sl<RegisterUseCase>(),
    sl<AuthRepositoryImpl>(), 
  );
});