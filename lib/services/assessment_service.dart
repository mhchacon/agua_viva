import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/spring_assessment_model.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:agua_viva/config/mongodb_config.dart';
import 'package:agua_viva/models/assessment_model.dart';

class AssessmentService {
  // Storage keys
  static const String _springsKey = 'springs_data';
  static const String _assessmentsKey = 'assessments_data';
  
  // Cache for in-memory data
  List<Spring> _springs = [];
  List<SpringAssessment> _assessments = [];
  
  // Stream controllers for real-time updates
  final _springsStreamController = StreamController<List<Spring>>.broadcast();
  final _assessmentsStreamController = StreamController<List<SpringAssessment>>.broadcast();
  
  // Constructor - load initial data
  AssessmentService() {
    _loadData();
  }
  
  // Getters for streams
  Stream<List<Spring>> get springsStream => _springsStreamController.stream;
  Stream<List<SpringAssessment>> get assessmentsStream => _assessmentsStreamController.stream;
  
  // Load data from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load springs
    final springsJson = prefs.getString(_springsKey);
    if (springsJson != null) {
      final List<dynamic> decodedSprings = jsonDecode(springsJson);
      _springs = decodedSprings
          .map((springJson) => Spring.fromJson(springJson))
          .toList();
      _springsStreamController.add(_springs);
    } else {
      // Initialize with sample data if empty
      await _initializeSampleData();
    }
    
    // Load assessments
    final assessmentsJson = prefs.getString(_assessmentsKey);
    if (assessmentsJson != null) {
      final List<dynamic> decodedAssessments = jsonDecode(assessmentsJson);
      _assessments = decodedAssessments
          .map((assessmentJson) => SpringAssessment.fromJson(assessmentJson))
          .toList();
      _assessmentsStreamController.add(_assessments);
    }
  }
  
  // Save springs to SharedPreferences
  Future<void> _saveSprings() async {
    final prefs = await SharedPreferences.getInstance();
    final springsJson = jsonEncode(_springs.map((spring) => spring.toJson()).toList());
    await prefs.setString(_springsKey, springsJson);
    _springsStreamController.add(_springs);
  }
  
  // Save assessments to SharedPreferences
  Future<void> _saveAssessments() async {
    final prefs = await SharedPreferences.getInstance();
    final assessmentsJson = jsonEncode(_assessments.map((assessment) => assessment.toJson()).toList());
    await prefs.setString(_assessmentsKey, assessmentsJson);
    _assessmentsStreamController.add(_assessments);
  }
  
  // Initialize with sample data for demonstration
  Future<void> _initializeSampleData() async {
    // Sample springs
    _springs = [
      Spring(
        id: 'spring1',
        ownerId: 'user123',
        ownerName: 'José da Silva',
        location: Location(latitude: -23.5505, longitude: -46.6333),
        altitude: 760.5,
        municipality: 'São Paulo',
        reference: 'Sítio Água Cristalina',
        hasCAR: true,
        hasAPP: true,
        appStatus: 'Bom',
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Spring(
        id: 'spring2',
        ownerId: 'user123',
        ownerName: 'José da Silva',
        location: Location(latitude: -23.5605, longitude: -46.6433),
        altitude: 765.2,
        municipality: 'São Paulo',
        reference: 'Nascente do Córrego',
        hasCAR: true,
        hasAPP: true,
        appStatus: 'Ruim',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Spring(
        id: 'spring3',
        ownerId: 'user456',
        ownerName: 'Ana Oliveira',
        location: Location(latitude: -22.9068, longitude: -43.1729),
        altitude: 520.3,
        municipality: 'Rio de Janeiro',
        reference: 'Fazenda Primavera',
        hasCAR: false,
        hasAPP: false,
        appStatus: 'Não tem',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
    
    // Sample assessments
    _assessments = [
      SpringAssessment(
        id: 'assessment1',
        springId: 'spring1',
        evaluatorId: 'evaluator1',
        status: 'approved',
        environmentalServices: ['Proteção de nascentes', 'Manutenção de cobertura vegetal'],
        ownerName: 'José da Silva',
        hasCAR: true,
        location: Location(latitude: -23.5505, longitude: -46.6333),
        altitude: 760.5,
        municipality: 'São Paulo',
        reference: 'Sítio Água Cristalina',
        hasAPP: true,
        appStatus: 'Bom',
        hasWaterFlow: true,
        hasWetlandVegetation: true,
        hasFavorableTopography: true,
        hasSoilSaturation: true,
        springType: 'Encosta / Eluvial',
        springCharacteristic: 'Pontual',
        flowRegime: 'Perene',
        hydroEnvironmentalScores: {
          'waterColor': 3,
          'waterOdor': 3,
          'solidWaste': 3,
          'floatingMaterials': 3,
          'foam': 3,
          'oils': 3,
          'sewage': 3,
          'vegetation': 3,
          'uses': 3,
          'access': 3,
          'urbanEquipment': 3
        },
        hydroEnvironmentalTotal: 33,
        surroundingConditions: {
          'landUse': 1,
          'groundCover': 1,
          'riparianVegetation': 1
        },
        springConditions: {
          'physicalState': 1,
          'flowProduced': 1,
          'humanIntervention': 1,
          'emergence': 1
        },
        anthropicImpacts: {
          'infrastructure': 1,
          'erosion': 1,
          'silting': 1,
          'animalPresence': 1,
          'animalOrigin': 1,
          'soilCompaction': 1,
          'pollutionSources': 1
        },
        generalState: 'Preservada',
        primaryUse: 'Abastecimento humano',
        hasWaterAnalysis: true,
        analysisDate: DateTime.now().subtract(const Duration(days: 45)),
        analysisParameters: 'pH, turbidez, coliformes',
        hasFlowRate: true,
        flowRateValue: 2.5,
        flowRateDate: DateTime.now().subtract(const Duration(days: 45)),
        photoReferences: ['photo_12345.jpg', 'photo_67890.jpg'],
        recommendations: 'Manter área cercada e proteger a vegetação do entorno.',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 45)),
        submittedAt: DateTime.now().subtract(const Duration(days: 50)),
      ),
      SpringAssessment(
        id: 'assessment2',
        springId: 'spring2',
        evaluatorId: 'evaluator1',
        status: 'pending',
        environmentalServices: ['Proteção de nascentes'],
        ownerName: 'José da Silva',
        hasCAR: true,
        location: Location(latitude: -23.5605, longitude: -46.6433),
        altitude: 765.2,
        municipality: 'São Paulo',
        reference: 'Nascente do Córrego',
        hasAPP: true,
        appStatus: 'Ruim',
        hasWaterFlow: true,
        hasWetlandVegetation: true,
        hasFavorableTopography: true,
        hasSoilSaturation: false,
        springType: 'Depressão',
        springCharacteristic: 'Difusa',
        diffusePoints: 3,
        flowRegime: 'Intermitente',
        hydroEnvironmentalScores: {
          'waterColor': 2,
          'waterOdor': 2,
          'solidWaste': 2,
          'floatingMaterials': 2,
          'foam': 2,
          'oils': 3,
          'sewage': 2,
          'vegetation': 2,
          'uses': 2,
          'access': 1,
          'urbanEquipment': 2
        },
        hydroEnvironmentalTotal: 22,
        surroundingConditions: {
          'landUse': 2,
          'groundCover': 2,
          'riparianVegetation': 2
        },
        springConditions: {
          'physicalState': 2,
          'flowProduced': 2,
          'humanIntervention': 2,
          'emergence': 2
        },
        anthropicImpacts: {
          'infrastructure': 2,
          'erosion': 2,
          'silting': 2,
          'animalPresence': 2,
          'animalOrigin': 2,
          'soilCompaction': 2,
          'pollutionSources': 2
        },
        generalState: 'Perturbada',
        primaryUse: 'Agricultura',
        hasWaterAnalysis: false,
        hasFlowRate: false,
        photoReferences: ['photo_13579.jpg'],
        recommendations: 'Recomenda-se o cercamento da área, plantio de espécies nativas e controle de acesso do gado.',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        submittedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      SpringAssessment(
        id: 'assessment3',
        springId: 'spring3',
        evaluatorId: 'evaluator2',
        status: 'rejected',
        environmentalServices: ['Proteção de nascentes'],
        ownerName: 'Ana Oliveira',
        hasCAR: false,
        location: Location(latitude: -22.9068, longitude: -43.1729),
        altitude: 520.3,
        municipality: 'Rio de Janeiro',
        reference: 'Fazenda Primavera',
        hasAPP: false,
        appStatus: 'Não tem',
        hasWaterFlow: false,
        hasWetlandVegetation: false,
        hasFavorableTopography: true,
        hasSoilSaturation: false,
        springType: 'Encosta / Eluvial',
        springCharacteristic: 'Pontual',
        flowRegime: 'Efêmera',
        hydroEnvironmentalScores: {
          'waterColor': 1,
          'waterOdor': 1,
          'solidWaste': 1,
          'floatingMaterials': 1,
          'foam': 1,
          'oils': 1,
          'sewage': 1,
          'vegetation': 1,
          'uses': 1,
          'access': 1,
          'urbanEquipment': 1
        },
        hydroEnvironmentalTotal: 11,
        surroundingConditions: {
          'landUse': 3,
          'groundCover': 3,
          'riparianVegetation': 3
        },
        springConditions: {
          'physicalState': 3,
          'flowProduced': 3,
          'humanIntervention': 3,
          'emergence': 3
        },
        anthropicImpacts: {
          'infrastructure': 3,
          'erosion': 3,
          'silting': 3,
          'animalPresence': 3,
          'animalOrigin': 3,
          'soilCompaction': 3,
          'pollutionSources': 3
        },
        generalState: 'Degradada',
        primaryUse: 'Criação de animais',
        hasWaterAnalysis: false,
        hasFlowRate: false,
        photoReferences: ['photo_24680.jpg'],
        recommendations: 'Recuperação completa da área, replantio de mata nativa e isolamento da área por ao menos 5 anos.',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        submittedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
    
    // Save to SharedPreferences
    await _saveSprings();
    await _saveAssessments();
  }

  // Create or update a spring
  Future<String> saveSpring(Spring spring) async {
    try {
      String springId = spring.id;
      final now = DateTime.now();
      
      if (springId.isEmpty) {
        // Create new spring with UUID
        springId = const Uuid().v4();
        final newSpring = Spring(
          id: springId,
          ownerId: spring.ownerId,
          ownerName: spring.ownerName,
          location: spring.location,
          altitude: spring.altitude,
          municipality: spring.municipality,
          reference: spring.reference,
          hasCAR: spring.hasCAR,
          carNumber: spring.carNumber,
          hasAPP: spring.hasAPP,
          appStatus: spring.appStatus,
          createdAt: now,
          updatedAt: now,
        );
        
        _springs.add(newSpring);
      } else {
        // Update existing spring
        final index = _springs.indexWhere((s) => s.id == springId);
        if (index >= 0) {
          _springs[index] = Spring(
            id: springId,
            ownerId: spring.ownerId,
            ownerName: spring.ownerName,
            location: spring.location,
            altitude: spring.altitude,
            municipality: spring.municipality,
            reference: spring.reference,
            hasCAR: spring.hasCAR,
            carNumber: spring.carNumber,
            hasAPP: spring.hasAPP,
            appStatus: spring.appStatus,
            createdAt: _springs[index].createdAt,
            updatedAt: now,
          );
        }
      }
      
      await _saveSprings();
      return springId;
    } catch (e) {
      print('Error saving spring: $e');
      rethrow;
    }
  }

  // Save assessment (create or update)
  Future<String> saveAssessment(SpringAssessment assessment) async {
    try {
      String assessmentId = assessment.id;
      final now = DateTime.now();
      
      if (assessmentId.isEmpty) {
        // Create new assessment with UUID
        assessmentId = const Uuid().v4();
        final newAssessment = SpringAssessment(
          id: assessmentId,
          springId: assessment.springId,
          evaluatorId: assessment.evaluatorId,
          status: assessment.status,
          environmentalServices: assessment.environmentalServices,
          ownerName: assessment.ownerName,
          hasCAR: assessment.hasCAR,
          carNumber: assessment.carNumber,
          location: assessment.location,
          altitude: assessment.altitude,
          municipality: assessment.municipality,
          reference: assessment.reference,
          hasAPP: assessment.hasAPP,
          appStatus: assessment.appStatus,
          hasWaterFlow: assessment.hasWaterFlow,
          hasWetlandVegetation: assessment.hasWetlandVegetation,
          hasFavorableTopography: assessment.hasFavorableTopography,
          hasSoilSaturation: assessment.hasSoilSaturation,
          springType: assessment.springType,
          springCharacteristic: assessment.springCharacteristic,
          diffusePoints: assessment.diffusePoints,
          flowRegime: assessment.flowRegime,
          ownerResponse: assessment.ownerResponse,
          informationSource: assessment.informationSource,
          hydroEnvironmentalScores: assessment.hydroEnvironmentalScores,
          hydroEnvironmentalTotal: assessment.hydroEnvironmentalTotal,
          surroundingConditions: assessment.surroundingConditions,
          springConditions: assessment.springConditions,
          anthropicImpacts: assessment.anthropicImpacts,
          generalState: assessment.generalState,
          primaryUse: assessment.primaryUse,
          hasWaterAnalysis: assessment.hasWaterAnalysis,
          analysisDate: assessment.analysisDate,
          analysisParameters: assessment.analysisParameters,
          hasFlowRate: assessment.hasFlowRate,
          flowRateValue: assessment.flowRateValue,
          flowRateDate: assessment.flowRateDate,
          photoReferences: assessment.photoReferences,
          recommendations: assessment.recommendations,
          createdAt: now,
          updatedAt: now,
          submittedAt: assessment.submittedAt,
        );
        
        _assessments.add(newAssessment);
      } else {
        // Update existing assessment
        final index = _assessments.indexWhere((a) => a.id == assessmentId);
        if (index >= 0) {
          _assessments[index] = SpringAssessment(
            id: assessmentId,
            springId: assessment.springId,
            evaluatorId: assessment.evaluatorId,
            status: assessment.status,
            environmentalServices: assessment.environmentalServices,
            ownerName: assessment.ownerName,
            hasCAR: assessment.hasCAR,
            carNumber: assessment.carNumber,
            location: assessment.location,
            altitude: assessment.altitude,
            municipality: assessment.municipality,
            reference: assessment.reference,
            hasAPP: assessment.hasAPP,
            appStatus: assessment.appStatus,
            hasWaterFlow: assessment.hasWaterFlow,
            hasWetlandVegetation: assessment.hasWetlandVegetation,
            hasFavorableTopography: assessment.hasFavorableTopography,
            hasSoilSaturation: assessment.hasSoilSaturation,
            springType: assessment.springType,
            springCharacteristic: assessment.springCharacteristic,
            diffusePoints: assessment.diffusePoints,
            flowRegime: assessment.flowRegime,
            ownerResponse: assessment.ownerResponse,
            informationSource: assessment.informationSource,
            hydroEnvironmentalScores: assessment.hydroEnvironmentalScores,
            hydroEnvironmentalTotal: assessment.hydroEnvironmentalTotal,
            surroundingConditions: assessment.surroundingConditions,
            springConditions: assessment.springConditions,
            anthropicImpacts: assessment.anthropicImpacts,
            generalState: assessment.generalState,
            primaryUse: assessment.primaryUse,
            hasWaterAnalysis: assessment.hasWaterAnalysis,
            analysisDate: assessment.analysisDate,
            analysisParameters: assessment.analysisParameters,
            hasFlowRate: assessment.hasFlowRate,
            flowRateValue: assessment.flowRateValue,
            flowRateDate: assessment.flowRateDate,
            photoReferences: assessment.photoReferences,
            recommendations: assessment.recommendations,
            createdAt: _assessments[index].createdAt,
            updatedAt: now,
            submittedAt: assessment.submittedAt ?? (assessment.status != 'draft' ? now : null),
          );
        }
      }
      
      await _saveAssessments();
      return assessmentId;
    } catch (e) {
      print('Error saving assessment: $e');
      rethrow;
    }
  }

  // Submit assessment for review (changes status to pending)
  Future<void> submitAssessment(String assessmentId) async {
    try {
      final index = _assessments.indexWhere((a) => a.id == assessmentId);
      if (index >= 0) {
        final assessment = _assessments[index];
        final now = DateTime.now();
        
        _assessments[index] = SpringAssessment(
          id: assessment.id,
          springId: assessment.springId,
          evaluatorId: assessment.evaluatorId,
          status: 'pending',
          environmentalServices: assessment.environmentalServices,
          ownerName: assessment.ownerName,
          hasCAR: assessment.hasCAR,
          carNumber: assessment.carNumber,
          location: assessment.location,
          altitude: assessment.altitude,
          municipality: assessment.municipality,
          reference: assessment.reference,
          hasAPP: assessment.hasAPP,
          appStatus: assessment.appStatus,
          hasWaterFlow: assessment.hasWaterFlow,
          hasWetlandVegetation: assessment.hasWetlandVegetation,
          hasFavorableTopography: assessment.hasFavorableTopography,
          hasSoilSaturation: assessment.hasSoilSaturation,
          springType: assessment.springType,
          springCharacteristic: assessment.springCharacteristic,
          diffusePoints: assessment.diffusePoints,
          flowRegime: assessment.flowRegime,
          ownerResponse: assessment.ownerResponse,
          informationSource: assessment.informationSource,
          hydroEnvironmentalScores: assessment.hydroEnvironmentalScores,
          hydroEnvironmentalTotal: assessment.hydroEnvironmentalTotal,
          surroundingConditions: assessment.surroundingConditions,
          springConditions: assessment.springConditions,
          anthropicImpacts: assessment.anthropicImpacts,
          generalState: assessment.generalState,
          primaryUse: assessment.primaryUse,
          hasWaterAnalysis: assessment.hasWaterAnalysis,
          analysisDate: assessment.analysisDate,
          analysisParameters: assessment.analysisParameters,
          hasFlowRate: assessment.hasFlowRate,
          flowRateValue: assessment.flowRateValue,
          flowRateDate: assessment.flowRateDate,
          photoReferences: assessment.photoReferences,
          recommendations: assessment.recommendations,
          createdAt: assessment.createdAt,
          updatedAt: now,
          submittedAt: now,
        );
        
        await _saveAssessments();
      }
    } catch (e) {
      print('Error submitting assessment: $e');
      rethrow;
    }
  }

  // Get all assessments for an evaluator
  Stream<List<SpringAssessment>> getEvaluatorAssessments(String evaluatorId) {
    _assessmentsStreamController.add(
      _assessments.where((a) => a.evaluatorId == evaluatorId).toList()
    );
    
    return _assessmentsStreamController.stream.map((assessments) {
      return assessments.where((a) => a.evaluatorId == evaluatorId).toList();
    });
  }

  // Get all assessments for a spring
  Stream<List<SpringAssessment>> getSpringAssessments(String springId) {
    _assessmentsStreamController.add(
      _assessments.where((a) => a.springId == springId).toList()
    );
    
    return _assessmentsStreamController.stream.map((assessments) {
      return assessments.where((a) => a.springId == springId).toList();
    });
  }

  // Get all assessments (for admin)
  Stream<List<SpringAssessment>> getAllAssessments() {
    _assessmentsStreamController.add(_assessments);
    return _assessmentsStreamController.stream;
  }

  // Get assessments by status
  Stream<List<SpringAssessment>> getAssessmentsByStatus(String status) {
    _assessmentsStreamController.add(
      _assessments.where((a) => a.status == status).toList()
    );
    
    return _assessmentsStreamController.stream.map((assessments) {
      return assessments.where((a) => a.status == status).toList();
    });
  }

  // Get springs by owner
  Stream<List<Spring>> getOwnerSprings(String ownerId) {
    _springsStreamController.add(
      _springs.where((s) => s.ownerId == ownerId).toList()
    );
    
    return _springsStreamController.stream.map((springs) {
      return springs.where((s) => s.ownerId == ownerId).toList();
    });
  }

  // Get all springs (for admin)
  Stream<List<Spring>> getAllSprings() {
    _springsStreamController.add(_springs);
    return _springsStreamController.stream;
  }

  // Get single assessment by ID
  Future<SpringAssessment?> getAssessmentById(String id) async {
    try {
      return _assessments.firstWhere((a) => a.id == id);
    } catch (e) {
      print('Error getting assessment: $e');
      return null;
    }
  }

  // Update assessment status (for admin)
  Future<void> updateAssessmentStatus(String id, String status, String? justification) async {
    try {
      final index = _assessments.indexWhere((a) => a.id == id);
      if (index >= 0) {
        final assessment = _assessments[index];
        
        _assessments[index] = SpringAssessment(
          id: assessment.id,
          springId: assessment.springId,
          evaluatorId: assessment.evaluatorId,
          status: status,
          environmentalServices: assessment.environmentalServices,
          ownerName: assessment.ownerName,
          hasCAR: assessment.hasCAR,
          carNumber: assessment.carNumber,
          location: assessment.location,
          altitude: assessment.altitude,
          municipality: assessment.municipality,
          reference: assessment.reference,
          hasAPP: assessment.hasAPP,
          appStatus: assessment.appStatus,
          hasWaterFlow: assessment.hasWaterFlow,
          hasWetlandVegetation: assessment.hasWetlandVegetation,
          hasFavorableTopography: assessment.hasFavorableTopography,
          hasSoilSaturation: assessment.hasSoilSaturation,
          springType: assessment.springType,
          springCharacteristic: assessment.springCharacteristic,
          diffusePoints: assessment.diffusePoints,
          flowRegime: assessment.flowRegime,
          ownerResponse: assessment.ownerResponse,
          informationSource: assessment.informationSource,
          hydroEnvironmentalScores: assessment.hydroEnvironmentalScores,
          hydroEnvironmentalTotal: assessment.hydroEnvironmentalTotal,
          surroundingConditions: assessment.surroundingConditions,
          springConditions: assessment.springConditions,
          anthropicImpacts: assessment.anthropicImpacts,
          generalState: assessment.generalState,
          primaryUse: assessment.primaryUse,
          hasWaterAnalysis: assessment.hasWaterAnalysis,
          analysisDate: assessment.analysisDate,
          analysisParameters: assessment.analysisParameters,
          hasFlowRate: assessment.hasFlowRate,
          flowRateValue: assessment.flowRateValue,
          flowRateDate: assessment.flowRateDate,
          photoReferences: assessment.photoReferences,
          recommendations: justification ?? assessment.recommendations,
          createdAt: assessment.createdAt,
          updatedAt: DateTime.now(),
          submittedAt: assessment.submittedAt,
        );
        
        await _saveAssessments();
      }
    } catch (e) {
      print('Error updating assessment status: $e');
      rethrow;
    }
  }
  
  // Clean up resources
  void dispose() {
    _springsStreamController.close();
    _assessmentsStreamController.close();
  }

  static const String collectionName = 'assessments';

  // Criar nova avaliação
  static Future<SpringAssessment> createAssessment(SpringAssessment assessment) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    await collection.insert(assessment.toMap());
    return assessment;
  }

  // Buscar avaliação por ID
  static Future<SpringAssessment?> getAssessmentById(ObjectId id) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    final assessmentMap = await collection.findOne(where.id(id));
    if (assessmentMap == null) return null;
    return SpringAssessment.fromMap(assessmentMap);
  }

  // Buscar avaliações por avaliador
  static Future<List<SpringAssessment>> getAssessmentsByEvaluator(ObjectId evaluatorId) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    final assessments = await collection.find(where.eq('evaluatorId', evaluatorId)).toList();
    return assessments.map((assessmentMap) => SpringAssessment.fromMap(assessmentMap)).toList();
  }

  // Buscar avaliações por nascente
  static Future<List<SpringAssessment>> getAssessmentsBySpring(ObjectId springId) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    final assessments = await collection.find(where.eq('springId', springId)).toList();
    return assessments.map((assessmentMap) => SpringAssessment.fromMap(assessmentMap)).toList();
  }

  // Atualizar avaliação
  static Future<void> updateAssessment(SpringAssessment assessment) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    await collection.update(
      where.id(assessment.id),
      assessment.toMap(),
    );
  }

  // Deletar avaliação
  static Future<void> deleteAssessment(ObjectId id) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    await collection.remove(where.id(id));
  }

  // Listar todas as avaliações
  static Future<List<SpringAssessment>> getAllAssessments() async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    final assessments = await collection.find().toList();
    return assessments.map((assessmentMap) => SpringAssessment.fromMap(assessmentMap)).toList();
  }

  // Buscar avaliações por status
  static Future<List<SpringAssessment>> getAssessmentsByStatus(String status) async {
    final db = await MongoDBConfig.getDatabase();
    final collection = db.collection(collectionName);

    final assessments = await collection.find(where.eq('status', status)).toList();
    return assessments.map((assessmentMap) => SpringAssessment.fromMap(assessmentMap)).toList();
  }

  // Buscar avaliações pendentes
  static Future<List<SpringAssessment>> getPendingAssessments() async {
    return getAssessmentsByStatus('pending');
  }

  // Buscar avaliações em rascunho
  static Future<List<SpringAssessment>> getDraftAssessments() async {
    return getAssessmentsByStatus('draft');
  }

  // Buscar avaliações aprovadas
  static Future<List<SpringAssessment>> getApprovedAssessments() async {
    return getAssessmentsByStatus('approved');
  }

  // Buscar avaliações rejeitadas
  static Future<List<SpringAssessment>> getRejectedAssessments() async {
    return getAssessmentsByStatus('rejected');
  }
}
