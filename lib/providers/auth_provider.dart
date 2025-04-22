import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  final DatabaseService _databaseService = DatabaseService.instance;

  Future<bool> signUp(String username, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Check if user already exists
      final existingUser = await _databaseService.getUserByEmail(email);
      if (existingUser != null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create a new user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        email: email,
        password: password,
      );

      final userId = await _databaseService.insertUser(user);

      _currentUser = user.copyWith(id: userId);
      _isAuthenticated = true;
      _isLoading = false;

      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final isAuthenticated = await _databaseService.authenticateUser(email, password);

      if (isAuthenticated) {
        final user = await _databaseService.getUserByEmail(email);
        _currentUser = user;
        _isAuthenticated = true;
      }

      _isLoading = false;
      notifyListeners();

      return isAuthenticated;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
