import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:agua_viva/services/api_service.dart';
import 'package:agua_viva/services/assessment_service.dart';
import 'package:agua_viva/models/assessment_model.dart';
import 'package:agua_viva/models/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([ApiService])
import 'assessment_service_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late AssessmentService assessmentService;

  setUp(() {
    mockApiService = MockApiService();
    SharedPreferences.setMockInitialValues({});
    assessmentService = AssessmentService(mockApiService);
  });

  group('AssessmentService', () {
    test('getAllAssessments deve retornar lista de avaliações do servidor quando online', () async {
      // Configurar o mock do ApiService
      when(mockApiService.get('/assessments')).thenAnswer((_) async => [
        {
          'id': '123456789012345678901234',
          'springId': '123456789012345678901234',
          'evaluatorId': '123456789012345678901234',
          'status': 'pending',
          'environmentalServices': ['Serviço 1', 'Serviço 2'],
          'ownerName': 'Proprietário Teste',
          'ownerCpf': '12345678900',
          'hasCAR': true,
          'carNumber': '12345',
          'location': {
            'latitude': -22.123,
            'longitude': -43.456,
          },
          'altitude': 800.0,
          'municipality': 'Município Teste',
          'reference': 'Referência de Teste',
          'hasAPP': true,
          'appStatus': 'Bom',
          'hasWaterFlow': true,
          'hasWetlandVegetation': true,
          'hasFavorableTopography': true,
          'hasSoilSaturation': true,
          'springType': 'Tipo Teste',
          'springCharacteristic': 'Característica Teste',
          'flowRegime': 'Regime Teste',
          'hydroEnvironmentalScores': {'critério1': 3, 'critério2': 5},
          'hydroEnvironmentalTotal': 25,
          'surroundingConditions': {'condição1': 3},
          'springConditions': {'condição1': 4},
          'anthropicImpacts': {'impacto1': 2},
          'generalState': 'Preservada',
          'primaryUse': 'Consumo Humano',
          'hasWaterAnalysis': false,
          'hasFlowRate': false,
          'photoReferences': [],
          'createdAt': '2023-01-01T00:00:00.000Z',
          'updatedAt': '2023-01-01T00:00:00.000Z',
        }
      ]);

      // Executar o método a ser testado
      final result = await assessmentService.getAllAssessments();

      // Verificar se o resultado está correto
      expect(result, isA<List<SpringAssessment>>());
      expect(result.length, 1);
      expect(result[0].ownerName, 'Proprietário Teste');
      expect(result[0].municipality, 'Município Teste');
      expect(result[0].status, 'pending');
    });

    test('saveAssessment deve salvar localmente quando offline', () async {
      // Configurar o mock do ApiService para simular modo offline
      when(mockApiService.post('/assessments', any)).thenThrow(Exception('Sem conexão'));

      // Criar uma avaliação para o teste
      final assessment = SpringAssessment(
        id: 'temp_id',
        springId: 'spring_id',
        evaluatorId: 'evaluator_id',
        status: 'pending',
        environmentalServices: ['Serviço 1'],
        ownerName: 'Proprietário Offline',
        ownerCpf: '12345678900',
        hasCAR: true,
        location: Location(latitude: -22.123, longitude: -43.456),
        altitude: 800.0,
        municipality: 'Município Offline',
        reference: 'Referência Offline',
        hasAPP: true,
        appStatus: 'Bom',
        hasWaterFlow: true,
        hasWetlandVegetation: true,
        hasFavorableTopography: true,
        hasSoilSaturation: true,
        springType: 'Tipo Teste',
        springCharacteristic: 'Característica Teste',
        flowRegime: 'Regime Teste',
        hydroEnvironmentalScores: {'critério1': 3},
        hydroEnvironmentalTotal: 20,
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
      );

      // Executar o método a ser testado
      final result = await assessmentService.saveAssessment(assessment);

      // Verificar se o resultado contém um ID offline
      expect(result, isA<String>());
      expect(result.startsWith('offline_'), true);
    });

    test('getAssessmentsByOwnerCpf deve retornar avaliações pelo CPF', () async {
      // Configurar o mock do ApiService
      when(mockApiService.get('/assessments/owner/12345678900')).thenAnswer((_) async => [
        {
          'id': '123456789012345678901234',
          'springId': '123456789012345678901234',
          'evaluatorId': '123456789012345678901234',
          'status': 'pending',
          'environmentalServices': ['Serviço 1'],
          'ownerName': 'Proprietário Teste',
          'ownerCpf': '12345678900',
          'hasCAR': true,
          'carNumber': '12345',
          'location': {
            'latitude': -22.123,
            'longitude': -43.456,
          },
          'altitude': 800.0,
          'municipality': 'Município Teste',
          'reference': 'Referência de Teste',
          'hasAPP': true,
          'appStatus': 'Bom',
          'hasWaterFlow': true,
          'hasWetlandVegetation': true,
          'hasFavorableTopography': true,
          'hasSoilSaturation': true,
          'springType': 'Tipo Teste',
          'springCharacteristic': 'Característica Teste',
          'flowRegime': 'Regime Teste',
          'hydroEnvironmentalScores': {'critério1': 3},
          'hydroEnvironmentalTotal': 20,
          'surroundingConditions': {'condição1': 3},
          'springConditions': {'condição1': 4},
          'anthropicImpacts': {'impacto1': 2},
          'generalState': 'Preservada',
          'primaryUse': 'Consumo Humano',
          'hasWaterAnalysis': false,
          'hasFlowRate': false,
          'photoReferences': [],
          'createdAt': '2023-01-01T00:00:00.000Z',
          'updatedAt': '2023-01-01T00:00:00.000Z',
        }
      ]);

      // Executar o método a ser testado
      final result = await assessmentService.getAssessmentsByOwnerCpf('12345678900');

      // Verificar se o resultado está correto
      expect(result, isA<List<SpringAssessment>>());
      expect(result.length, 1);
      expect(result[0].ownerCpf, '12345678900');
    });
  });
} 