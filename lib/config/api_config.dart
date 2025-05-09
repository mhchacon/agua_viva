class ApiConfig {
  // URL base da API
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Timeout das requisições
  static const int timeout = 30; // segundos
  
  // Versão da API
  static const String apiVersion = 'v1';
  
  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String users = '/users';
  static const String springs = '/springs';
  static const String assessments = '/assessments';
} 