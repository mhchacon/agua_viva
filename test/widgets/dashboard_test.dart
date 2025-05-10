import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:agua_viva/screens/dashboard_screen.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:agua_viva/services/auth_service.dart';
import 'package:agua_viva/models/assessment_model.dart';
import 'package:agua_viva/models/location.dart';

@GenerateMocks([AssessmentService, AuthService])
import 'dashboard_test.mocks.dart';

void main() {
  late MockAssessmentService mockAssessmentService;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAssessmentService = MockAssessmentService();
    mockAuthService = MockAuthService();
  });

  group('Dashboard Admin View', () {
    final testAssessments = [
      SpringAssessment(
        id: '123',
        springId: '123',
        evaluatorId: '123',
        status: 'approved',
        environmentalServices: ['Serviço 1'],
        ownerName: 'Proprietário 1',
        ownerCpf: '12345678900',
        hasCAR: true,
        location: Location(latitude: -22.123, longitude: -43.456),
        altitude: 800.0,
        municipality: 'Município 1',
        reference: 'Referência 1',
        hasAPP: true,
        appStatus: 'Bom',
        hasWaterFlow: true,
        hasWetlandVegetation: true,
        hasFavorableTopography: true,
        hasSoilSaturation: true,
        springType: 'Tipo 1',
        springCharacteristic: 'Característica 1',
        flowRegime: 'Regime 1',
        hydroEnvironmentalScores: {'critério1': 3},
        hydroEnvironmentalTotal: 25,
        surroundingConditions: {'condição1': 3},
        springConditions: {'condição1': 4},
        anthropicImpacts: {'impacto1': 2},
        generalState: 'Preservada',
        primaryUse: 'Consumo Humano',
        hasWaterAnalysis: false,
        hasFlowRate: false,
        photoReferences: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SpringAssessment(
        id: '456',
        springId: '456',
        evaluatorId: '456',
        status: 'pending',
        environmentalServices: ['Serviço 2'],
        ownerName: 'Proprietário 2',
        ownerCpf: '98765432100',
        hasCAR: true,
        location: Location(latitude: -22.456, longitude: -43.789),
        altitude: 900.0,
        municipality: 'Município 2',
        reference: 'Referência 2',
        hasAPP: true,
        appStatus: 'Regular',
        hasWaterFlow: true,
        hasWetlandVegetation: true,
        hasFavorableTopography: true,
        hasSoilSaturation: true,
        springType: 'Tipo 2',
        springCharacteristic: 'Característica 2',
        flowRegime: 'Regime 2',
        hydroEnvironmentalScores: {'critério1': 2},
        hydroEnvironmentalTotal: 18,
        surroundingConditions: {'condição1': 2},
        springConditions: {'condição1': 3},
        anthropicImpacts: {'impacto1': 3},
        generalState: 'Perturbada',
        primaryUse: 'Irrigação',
        hasWaterAnalysis: false,
        hasFlowRate: false,
        photoReferences: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    testWidgets('deve exibir componentes do painel do administrador quando há avaliações', (WidgetTester tester) async {
      // Configurar o mock
      when(mockAssessmentService.getAllAssessments()).thenAnswer((_) async => testAssessments);
      
      // Construir o widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AssessmentService>.value(value: mockAssessmentService),
            ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
          ],
          child: const MaterialApp(
            home: DashboardScreen(userRole: UserRole.admin),
          ),
        ),
      );
      
      // Aguardar a construção assíncrona
      await tester.pumpAndSettle();
      
      // Verificar componentes do painel
      expect(find.text('Painel de Controle'), findsOneWidget);
      expect(find.text('Resumo de Avaliações'), findsOneWidget);
      expect(find.text('Estado das Nascentes'), findsOneWidget);
      expect(find.text('Municípios mais Avaliados'), findsOneWidget);
      expect(find.text('Últimas Avaliações'), findsOneWidget);
      
      // Verificar dados estatísticos
      expect(find.text('2'), findsWidgets); // Total de avaliações
      expect(find.text('1'), findsWidgets); // Aprovadas
      expect(find.text('1'), findsWidgets); // Pendentes
      
      // Verificar botão de relatório
      expect(find.text('Gerar Relatório PDF'), findsOneWidget);
    });
    
    testWidgets('deve exibir mensagem quando não há avaliações', (WidgetTester tester) async {
      // Configurar o mock para retornar lista vazia
      when(mockAssessmentService.getAllAssessments()).thenAnswer((_) async => []);
      
      // Construir o widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AssessmentService>.value(value: mockAssessmentService),
            ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
          ],
          child: const MaterialApp(
            home: DashboardScreen(userRole: UserRole.admin),
          ),
        ),
      );
      
      // Aguardar a construção assíncrona
      await tester.pumpAndSettle();
      
      // Verificar mensagem de lista vazia
      expect(find.text('Nenhuma avaliação cadastrada'), findsOneWidget);
      expect(find.text('As avaliações serão exibidas aqui quando disponíveis'), findsOneWidget);
    });
    
    testWidgets('deve exibir indicador de carregamento enquanto busca dados', (WidgetTester tester) async {
      // Configurar o mock para não resolver imediatamente
      final completer = Completer<List<SpringAssessment>>();
      when(mockAssessmentService.getAllAssessments()).thenAnswer((_) => completer.future);
      
      // Construir o widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AssessmentService>.value(value: mockAssessmentService),
            ChangeNotifierProvider<AuthService>.value(value: mockAuthService),
          ],
          child: const MaterialApp(
            home: DashboardScreen(userRole: UserRole.admin),
          ),
        ),
      );
      
      // Verificar indicador de carregamento
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Completar o future
      completer.complete(testAssessments);
      await tester.pumpAndSettle();
      
      // Verificar que o conteúdo foi carregado
      expect(find.text('Painel de Controle'), findsOneWidget);
    });
  });
} 