import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:agua_viva/utils/logger.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl => ApiConfig.getBaseUrl();
  final _logger = AppLogger();
  String? _authToken;

  // Headers padrão
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // Método para verificar a conectividade com o servidor
  Future<bool> checkServerConnection() async {
    _logger.info('Verificando conexão com o servidor: $baseUrl');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      ).timeout(Duration(seconds: ApiConfig.timeout));
      
      final isConnected = response.statusCode >= 200 && response.statusCode < 300;
      
      if (isConnected) {
        _logger.info('Conexão estabelecida com o servidor: $baseUrl');
        ApiConfig.offlineMode = false;
      } else {
        _logger.warning('Servidor retornou status ${response.statusCode}');
        ApiConfig.offlineMode = true;
      }
      
      return isConnected;
    } catch (e) {
      _logger.error('Erro ao verificar conexão com o servidor: $e');
      ApiConfig.switchToNextUrl();
      return false;
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Verifica a conexão primeiro
      await checkServerConnection();
      if (ApiConfig.offlineMode) {
        throw Exception('Sem conexão com o servidor. Tente novamente mais tarde.');
      }
      
      _logger.info('Tentando login em: $baseUrl/auth/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(seconds: ApiConfig.timeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        _logger.info('Login bem-sucedido');
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Falha no login');
      }
    } catch (e) {
      _logger.error('Erro na tentativa de login: $e');
      throw Exception('Falha ao conectar com o servidor: $e');
    }
  }

  // GET
  Future<dynamic> get(String endpoint) async {
    try {
      _logger.info('GET: $baseUrl$endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      ).timeout(Duration(seconds: ApiConfig.timeout));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erro na requisição GET');
      }
    } catch (e) {
      _logger.error('Erro na requisição GET: $e');
      throw Exception('Erro na requisição: $e');
    }
  }
  
  // POST
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      _logger.info('POST: $baseUrl$endpoint');
      _logger.info('Dados: ${data.keys}');
      
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(Duration(seconds: ApiConfig.timeout));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erro na requisição POST');
      }
    } catch (e) {
      _logger.error('Erro na requisição POST: $e');
      throw Exception('Erro na requisição: $e');
    }
  }

  // PUT
  Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      _logger.info('PUT: $baseUrl$endpoint');
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(Duration(seconds: ApiConfig.timeout));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erro na requisição PUT');
      }
    } catch (e) {
      _logger.error('Erro na requisição PUT: $e');
      throw Exception('Erro na requisição: $e');
    }
  }

  // DELETE
  Future<void> delete(String endpoint) async {
    try {
      _logger.info('DELETE: $baseUrl$endpoint');
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      ).timeout(Duration(seconds: ApiConfig.timeout));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erro na requisição DELETE');
      }
    } catch (e) {
      _logger.error('Erro na requisição DELETE: $e');
      throw Exception('Erro na requisição: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    _authToken = null;
    _logger.info('Usuário desconectado');
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
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erro na requisição');
    }
  }

  List<Map<String, dynamic>> _handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erro na requisição');
    }
  }
} 