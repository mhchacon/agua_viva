class ApiConfig {
  // Flag para modo offline (quando o servidor não está disponível)
  static bool offlineMode = false;
  
  // URLs disponíveis
  static const String baseUrl = 'http://localhost:3000/api';
  static const String mobileBaseUrl = 'http://10.0.2.2:3000/api';  // Para emulador Android
  
  // Substitua pelos IPs corretos da sua rede
  // Use ipconfig (Windows) ou ifconfig (Linux/Mac) para descobrir seu IP
  static final List<String> networkIPs = [
    'http://127.0.0.1:3000/api',
    'http://10.0.2.2:3000/api',      // Emulador Android -> localhost
    'http://192.168.1.52:3000/api',  // IP real da máquina local
    'http://172.20.10.1:3000/api'    // Exemplo para ponto de acesso móvel
  ];
  
  // Lista de URLs para tentar, em ordem de preferência
  static final List<String> _urlsToTry = [
    'http://192.168.1.52:3000/api',  // IP real da máquina - tenta primeiro
    'http://10.0.2.2:3000/api',      // Para emulador Android
    'http://127.0.0.1:3000/api',
    'http://localhost:3000/api',
  ];
  
  // URL atual sendo usada
  static String _currentUrl = 'http://192.168.1.52:3000/api';
  
  // Getter para a URL atual
  static String get currentUrl => _currentUrl;
  
  // Método para obter a URL apropriada com base no ambiente
  static String getBaseUrl() {
    if (offlineMode) {
      return ''; // URL vazia no modo offline
    }
    return _currentUrl;
  }
  
  // Método para alternar para a próxima URL se a atual falhar
  static String switchToNextUrl() {
    final currentIndex = _urlsToTry.indexOf(_currentUrl);
    if (currentIndex < _urlsToTry.length - 1) {
      _currentUrl = _urlsToTry[currentIndex + 1];
    } else {
      // Se já tentou todas as URLs, entra em modo offline
      offlineMode = true;
      _currentUrl = '';
    }
    return _currentUrl;
  }
  
  // Método para definir uma URL específica
  static void setUrl(String url) {
    _currentUrl = url;
    offlineMode = false;
  }
  
  // Timeout das requisições
  static const int timeout = 10; // segundos (reduzido para falhar mais rápido)
  
  // Versão da API
  static const String apiVersion = 'v1';
  
  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String users = '/users';
  static const String springs = '/springs';
  static const String assessments = '/assessments';
  
  // Adiciona uma rota de heartbeat/health para verificação
  static const String health = '/health';
} 