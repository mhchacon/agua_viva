import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:agua_viva/services/api_service.dart';
import 'package:agua_viva/config/api_config.dart';

@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  late MockClient mockHttpClient;
  late ApiService apiService;

  setUp(() {
    mockHttpClient = MockClient();
    // Substituir o cliente HTTP no ApiService
    ApiConfig.httpClient = mockHttpClient;
    apiService = ApiService();
  });

  group('ApiService', () {
    test('checkServerConnection deve retornar true quando o servidor está online', () async {
      // Configurar o mock do cliente HTTP
      when(mockHttpClient.get(
        Uri.parse('${ApiConfig.getBaseUrl()}/health'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"status": "ok"}', 200));

      // Executar o método a ser testado
      final result = await apiService.checkServerConnection();

      // Verificar se o resultado está correto
      expect(result, true);
      expect(ApiConfig.offlineMode, false);
    });

    test('checkServerConnection deve retornar false e ativar modo offline quando o servidor está offline', () async {
      // Configurar o mock do cliente HTTP para simular erro de conexão
      when(mockHttpClient.get(
        Uri.parse('${ApiConfig.getBaseUrl()}/health'),
        headers: anyNamed('headers'),
      )).thenThrow(Exception('Erro de conexão'));

      // Executar o método a ser testado
      final result = await apiService.checkServerConnection();

      // Verificar se o resultado está correto
      expect(result, false);
      // Verificar se o modo offline foi ativado
      expect(ApiConfig.offlineMode, true);
    });

    test('GET deve retornar dados quando o servidor responde corretamente', () async {
      // Configurar o mock do cliente HTTP
      when(mockHttpClient.get(
        Uri.parse('${ApiConfig.getBaseUrl()}/test'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"data": "test"}', 200));

      // Executar o método a ser testado
      final result = await apiService.get('/test');

      // Verificar se o resultado está correto
      expect(result, isA<Map<String, dynamic>>());
      expect(result['data'], 'test');
    });

    test('POST deve enviar dados e retornar resposta quando o servidor responde corretamente', () async {
      // Configurar o mock do cliente HTTP
      when(mockHttpClient.post(
        Uri.parse('${ApiConfig.getBaseUrl()}/test'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('{"success": true}', 200));

      // Executar o método a ser testado
      final result = await apiService.post('/test', {'test': 'data'});

      // Verificar se o resultado está correto
      expect(result, isA<Map<String, dynamic>>());
      expect(result['success'], true);
    });

    test('switchToNextUrl deve alternar para a próxima URL quando a atual falha', () {
      // Salvar a URL atual
      final currentUrl = ApiConfig.currentUrl;
      
      // Executar o método a ser testado
      final newUrl = ApiConfig.switchToNextUrl();
      
      // Verificar se a URL foi alterada
      expect(newUrl, isNot(equals(currentUrl)));
      expect(ApiConfig.currentUrl, equals(newUrl));
    });
  });
} 