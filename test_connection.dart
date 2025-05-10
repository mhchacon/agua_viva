import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Lista de URLs para testar
final List<String> urlsToTest = [
  'http://localhost:3000/api/health',
  'http://127.0.0.1:3000/api/health',
  'http://10.0.2.2:3000/api/health',
  'http://192.168.1.52:3000/api/health', // IP real da máquina
];

Future<void> main() async {
  print('Testando conexão com o servidor...\n');
  
  for (final url in urlsToTest) {
    try {
      print('Testando $url');
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Conexão bem-sucedida! Status: ${response.statusCode}');
        print('   Resposta: $data\n');
      } else {
        print('❌ Falha! Status: ${response.statusCode}');
        print('   Resposta: ${response.body}\n');
      }
    } catch (e) {
      print('❌ Erro de conexão: $e\n');
    }
  }
  
  // Teste a rota de login como exemplo
  try {
    final loginUrl = 'http://192.168.1.52:3000/api/auth/login';
    print('Testando autenticação em $loginUrl');
    
    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'teste@example.com',
        'password': 'senha123',
      }),
    ).timeout(const Duration(seconds: 5));
    
    print('Status: ${response.statusCode}');
    print('Resposta: ${response.body}\n');
  } catch (e) {
    print('❌ Erro ao testar autenticação: $e\n');
  }
  
  print('Teste de conexão concluído.');
} 