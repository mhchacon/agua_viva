import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agua_viva/services/api_service.dart';
import 'package:agua_viva/utils/logger.dart';

enum UserRole { admin, evaluator, owner, proprietario }

class AuthService extends ChangeNotifier {
  // Current User state
  String? _currentUserId;
  String? _currentUserEmail;
  String? _currentUserName;
  UserRole? _currentUserRole;
  bool _isAuthenticated = false;
  
  // For simulating stream of auth state changes
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  final _logger = AppLogger();
  final _apiService = ApiService();
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserId => _currentUserId;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;
  UserRole? get currentUserRole => _currentUserRole;
  Stream<bool> get authStateChanges => _authStateController.stream;
  
  AuthService() {
    // Try to restore session at initialization
    _restoreSession();
  }
  
  // Restore user session from SharedPreferences
  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('currentUser');
    
    if (userData != null) {
      final user = jsonDecode(userData);
      _currentUserId = user['id'];
      _currentUserEmail = user['email'];
      _currentUserName = user['name'] ?? user['nomeCompleto'];
      _currentUserRole = _stringToUserRole(user['role'] ?? user['tipo']);
      _isAuthenticated = true;
      _authStateController.add(true);
      notifyListeners();
    }
  }
  
  // Sign in with email and password for regular users
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      
      if (response['user'] != null) {
        final user = response['user'];
        _currentUserId = user['id'];
        _currentUserEmail = user['email'];
        _currentUserName = user['name'];
        _currentUserRole = _stringToUserRole(user['role']);
        _isAuthenticated = true;
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUser', jsonEncode({
          'id': _currentUserId,
          'email': _currentUserEmail,
          'name': _currentUserName,
          'role': user['role'],
        }));
        
        _authStateController.add(true);
        notifyListeners();
        return true;
      }
      
      _logger.error('Falha na autenticação: credenciais inválidas');
      return false;
    } catch (e) {
      _logger.error('Erro ao fazer login: $e');
      return false;
    }
  }

  // Sign in for proprietários
  Future<bool> signInProprietario(String email, String senha) async {
    try {
      final response = await _apiService.post('/proprietarios/login', {
        'email': email,
        'senha': senha,
      });
      
      if (response['proprietario'] != null) {
        final proprietario = response['proprietario'];
        _currentUserId = proprietario['id'];
        _currentUserEmail = proprietario['email'];
        _currentUserName = proprietario['nomeCompleto'];
        _currentUserRole = UserRole.proprietario;
        _isAuthenticated = true;
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUser', jsonEncode({
          'id': _currentUserId,
          'email': _currentUserEmail,
          'nomeCompleto': _currentUserName,
          'tipo': 'proprietario',
        }));
        
        _authStateController.add(true);
        notifyListeners();
        return true;
      }
      
      _logger.error('Falha na autenticação: credenciais inválidas');
      return false;
    } catch (e) {
      _logger.error('Erro ao fazer login como proprietário: $e');
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      _currentUserId = null;
      _currentUserEmail = null;
      _currentUserName = null;
      _currentUserRole = null;
      _isAuthenticated = false;
      
      // Clear from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUser');
      
      _apiService.logout();
      
      _authStateController.add(false);
      notifyListeners();
    } catch (e) {
      _logger.error('Erro ao fazer logout: $e');
    }
  }
  
  // Helper method to convert string to UserRole enum
  UserRole? _stringToUserRole(String? role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'evaluator':
        return UserRole.evaluator;
      case 'owner':
        return UserRole.owner;
      case 'proprietario':
        return UserRole.proprietario;
      default:
        return null;
    }
  }
  
  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (!_isAuthenticated) return null;
    
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('currentUser');
    
    if (userData == null) return null;
    
    return jsonDecode(userData);
  }
  
  // Clean up resources
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
