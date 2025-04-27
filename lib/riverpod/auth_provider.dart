import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? username;
  final String? errorMessage;
  final bool isLoading;

  AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.username,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? username,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return AuthState();
  }

  void login(String username, String password) async {
    state = state.copyWith(
      isAuthenticated: false,
      errorMessage: null,
      isLoading: true,
    );

    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation - in a real app you would validate against an API or database
    if (username == 'user' && password == 'password') {
      state = state.copyWith(
        isAuthenticated: true,
        userId: '1',
        username: username,
        errorMessage: null,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isAuthenticated: false,
        errorMessage: 'Invalid username or password',
        isLoading: false,
      );
    }
  }

  void signup(String username, String password) async {
    state = state.copyWith(
      isAuthenticated: false,
      errorMessage: null,
      isLoading: true,
    );

    // Simulate API call with delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple validation - in a real app you would validate against an API or database
    if (username.length >= 3 && password.length >= 6) {
      state = state.copyWith(
        isAuthenticated: true,
        userId: '1',
        username: username,
        errorMessage: null,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isAuthenticated: false,
        errorMessage: 'Username must be at least 3 characters and password must be at least 6 characters',
        isLoading: false,
      );
    }
  }

  void logout() {
    state = AuthState();
  }
} 