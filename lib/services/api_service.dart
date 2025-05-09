import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:agua_viva/utils/logger.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = ApiConfig.baseUrl;
  final _logger = AppLogger();
  String? _authToken;

  // Headers padrão
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Autenticação
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        return data;
      } else {
        throw Exception('Falha no login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  // Usuários
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: _headers,
      body: jsonEncode(userData),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getUser(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$id'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // Nascentes
  Future<Map<String, dynamic>> createSpring(Map<String, dynamic> springData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/springs'),
      headers: _headers,
      body: jsonEncode(springData),
    );
    return _handleResponse(response);
  }

  Future<List<Map<String, dynamic>>> getSprings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/springs'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> getSpring(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/springs/$id'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateSpring(String id, Map<String, dynamic> springData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/springs/$id'),
      headers: _headers,
      body: jsonEncode(springData),
    );
    return _handleResponse(response);
  }

  Future<void> deleteSpring(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/springs/$id'),
      headers: _headers,
    );
    _handleResponse(response);
  }

  Future<List<Map<String, dynamic>>> getSpringsByOwner(String ownerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/springs/owner/$ownerId'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  // Avaliações
  Future<Map<String, dynamic>> createAssessment(Map<String, dynamic> assessmentData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assessments'),
      headers: _headers,
      body: jsonEncode(assessmentData),
    );
    return _handleResponse(response);
  }

  Future<List<Map<String, dynamic>>> getAssessments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/assessments'),
      headers: _headers,
    );
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> updateAssessment(String id, Map<String, dynamic> assessmentData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/assessments/$id'),
      headers: _headers,
      body: jsonEncode(assessmentData),
    );
    return _handleResponse(response);
  }

  // Métodos auxiliares
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro na requisição: ${response.body}');
    }
  }

  List<Map<String, dynamic>> _handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erro na requisição: ${response.body}');
    }
  }

  // Logout
  void logout() {
    _authToken = null;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      _logger.error('Erro na requisição GET: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      _logger.error('Erro na requisição POST: $e');
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      _logger.error('Erro na requisição PUT: $e');
      rethrow;
    }
  }

  Future<void> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      _handleResponse(response);
    } catch (e) {
      _logger.error('Erro na requisição DELETE: $e');
      rethrow;
    }
  }
} 