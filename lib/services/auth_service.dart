import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum UserRole { admin, evaluator, owner }

class AuthService extends ChangeNotifier {
  // Current User state
  String? _currentUserId;
  String? _currentUserEmail;
  UserRole? _currentUserRole;
  bool _isAuthenticated = false;
  
  // For simulating stream of auth state changes
  final StreamController<bool> _authStateController = StreamController<bool>.broadcast();
  
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get currentUserId => _currentUserId;
  String? get currentUserEmail => _currentUserEmail;
  UserRole? get currentUserRole => _currentUserRole;
  Stream<bool> get authStateChanges => _authStateController.stream;
  
  // Demo credentials for MVP
  static const Map<String, Map<String, dynamic>> _demoUsers = {
    'teste@psa.com': {
      'password': '12345',
      'role': UserRole.admin,
      'name': 'Administrador Demo'
    },
    'avaliador@psa.com': {
      'password': '12345',
      'role': UserRole.evaluator,
      'name': 'Avaliador Demo'
    },
    'proprietario@psa.com': {
      'password': '12345',
      'role': UserRole.owner,
      'name': 'Proprietário Demo'
    },
  };
  
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
      _currentUserRole = _stringToUserRole(user['role']);
      _isAuthenticated = true;
      _authStateController.add(true);
      notifyListeners();
    }
  }
  
  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Check if this is a demo user
      if (_demoUsers.containsKey(email) && _demoUsers[email]!['password'] == password) {
        _currentUserId = const Uuid().v4(); // Generate random ID
        _currentUserEmail = email;
        _currentUserRole = _demoUsers[email]!['role'];
        _isAuthenticated = true;
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUser', jsonEncode({
          'id': _currentUserId,
          'email': _currentUserEmail,
          'role': _currentUserRole.toString().split('.').last,
          'name': _demoUsers[email]!['name'],
        }));
        
        _authStateController.add(true);
        notifyListeners();
        return true;
      }
      
      // Add user registration logic for custom users here
      
      return false;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      _currentUserId = null;
      _currentUserEmail = null;
      _currentUserRole = null;
      _isAuthenticated = false;
      
      // Clear from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('currentUser');
      
      _authStateController.add(false);
      notifyListeners();
    } catch (e) {
      print('Sign out error: $e');
    }
  }
  
  // Helper method to convert string to UserRole enum
  UserRole? _stringToUserRole(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'evaluator':
        return UserRole.evaluator;
      case 'owner':
        return UserRole.owner;
      default:
        return null;
    }
  }
  
  // For demo purposes, provide a method to get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    return _demoUsers.entries.map((entry) {
      return {
        'id': const Uuid().v4(),
        'email': entry.key,
        'name': entry.value['name'],
        'role': entry.value['role'].toString().split('.').last,
      };
    }).toList();
  }
  
  // Clean up resources
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
