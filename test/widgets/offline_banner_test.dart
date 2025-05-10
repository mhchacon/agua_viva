import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agua_viva/widgets/offline_banner.dart';
import 'package:agua_viva/config/api_config.dart';

void main() {
  group('OfflineBanner Widget', () {
    testWidgets('não exibe o banner quando está online', (WidgetTester tester) async {
      // Configurar o modo online
      ApiConfig.offlineMode = false;
      
      // Construir o widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetryConnectionCallback(
              onRetry: () async => true,
              child: const OfflineBanner(),
            ),
          ),
        ),
      );
      
      // Banner não deve ser visível
      expect(find.text('Você está offline'), findsNothing);
    });
    
    testWidgets('exibe o banner quando está offline', (WidgetTester tester) async {
      // Configurar o modo offline
      ApiConfig.offlineMode = true;
      
      // Construir o widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetryConnectionCallback(
              onRetry: () async => true,
              child: const OfflineBanner(),
            ),
          ),
        ),
      );
      
      // Banner deve ser visível
      expect(find.text('Você está offline'), findsOneWidget);
      expect(find.text('Os dados serão sincronizados quando a conexão for restaurada'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
    
    testWidgets('botão de atualização chama o callback quando pressionado', (WidgetTester tester) async {
      // Configurar o modo offline
      ApiConfig.offlineMode = true;
      
      // Flag para verificar se o callback foi chamado
      bool callbackCalled = false;
      
      // Função de callback
      Future<bool> onRetry() async {
        callbackCalled = true;
        return true;
      }
      
      // Construir o widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetryConnectionCallback(
              onRetry: onRetry,
              child: const OfflineBanner(),
            ),
          ),
        ),
      );
      
      // Tap no botão de atualização
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      
      // Verificar se o callback foi chamado
      expect(callbackCalled, isTrue);
    });
  });
} 