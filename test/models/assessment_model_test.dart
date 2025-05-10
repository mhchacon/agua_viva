import 'package:flutter_test/flutter_test.dart';
import 'package:agua_viva/models/assessment_model.dart';
import 'package:agua_viva/models/location.dart';

void main() {
  group('SpringAssessment', () {
    late SpringAssessment assessment;
    final testId = '507f1f77bcf86cd799439011';
    final testSpringId = '507f1f77bcf86cd799439012';
    final testEvaluatorId = '507f1f77bcf86cd799439013';

    setUp(() {
      assessment = SpringAssessment(
        id: testId,
        springId: testSpringId,
        evaluatorId: testEvaluatorId,
        status: 'pending',
        environmentalServices: ['Água potável', 'Irrigação'],
        ownerName: 'João Silva',
        hasCAR: true,
        carNumber: '123456',
        location: Location(latitude: -23.5505, longitude: -46.6333),
        altitude: 800.0,
        municipality: 'São Paulo',
        reference: 'Próximo ao rio',
        hasAPP: true,
        appStatus: 'Bom',
        hasWaterFlow: true,
        hasWetlandVegetation: true,
        hasFavorableTopography: true,
        hasSoilSaturation: true,
        springType: 'Perene',
        springCharacteristic: 'Ponto único',
        flowRegime: 'Contínuo',
        hydroEnvironmentalScores: {'Qualidade': 5, 'Quantidade': 4},
        hydroEnvironmentalTotal: 9,
        surroundingConditions: {'Vegetação': 3},
        springConditions: {'Proteção': 4},
        anthropicImpacts: {'Poluição': 2},
        generalState: 'Preservada',
        primaryUse: 'Consumo humano',
        hasWaterAnalysis: true,
        hasFlowRate: true,
        photoReferences: ['foto1.jpg', 'foto2.jpg'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('deve converter corretamente para JSON', () {
      final json = assessment.toJson();
      
      expect(json['id'], equals(testId));
      expect(json['springId'], equals(testSpringId));
      expect(json['evaluatorId'], equals(testEvaluatorId));
      expect(json['status'], equals('pending'));
      expect(json['ownerName'], equals('João Silva'));
    });

    test('deve criar a partir de JSON', () {
      final json = assessment.toJson();
      final newAssessment = SpringAssessment.fromJson(json);
      
      expect(newAssessment.id, equals(testId));
      expect(newAssessment.springId, equals(testSpringId));
      expect(newAssessment.evaluatorId, equals(testEvaluatorId));
      expect(newAssessment.status, equals('pending'));
      expect(newAssessment.ownerName, equals('João Silva'));
    });

    test('deve criar cópia com alterações usando copyWith', () {
      final newStatus = 'approved';
      final newOwnerName = 'Maria Santos';
      
      final updatedAssessment = assessment.copyWith(
        status: newStatus,
        ownerName: newOwnerName,
      );
      
      expect(updatedAssessment.id, equals(testId));
      expect(updatedAssessment.status, equals(newStatus));
      expect(updatedAssessment.ownerName, equals(newOwnerName));
      expect(updatedAssessment.springId, equals(testSpringId));
    });

    test('deve manter valores originais em campos não alterados', () {
      final updatedAssessment = assessment.copyWith(
        status: 'approved',
      );
      
      expect(updatedAssessment.ownerName, equals(assessment.ownerName));
      expect(updatedAssessment.hasCAR, equals(assessment.hasCAR));
      expect(updatedAssessment.location.latitude, equals(assessment.location.latitude));
    });

    test('deve converter corretamente para Map', () {
      final map = assessment.toMap();
      
      expect(map['_id'], equals(testId));
      expect(map['springId'], equals(testSpringId));
      expect(map['evaluatorId'], equals(testEvaluatorId));
      expect(map['status'], equals('pending'));
      expect(map['ownerName'], equals('João Silva'));
    });

    test('deve criar a partir de Map', () {
      final map = assessment.toMap();
      final newAssessment = SpringAssessment.fromMap(map);
      
      expect(newAssessment.id, equals(testId));
      expect(newAssessment.springId, equals(testSpringId));
      expect(newAssessment.evaluatorId, equals(testEvaluatorId));
      expect(newAssessment.status, equals('pending'));
      expect(newAssessment.ownerName, equals('João Silva'));
    });
  });
} 