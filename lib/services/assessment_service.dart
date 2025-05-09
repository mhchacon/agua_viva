import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:agua_viva/config/mongodb_config.dart';
import 'package:agua_viva/models/spring_model.dart';
import 'package:agua_viva/models/assessment_model.dart';
import 'package:agua_viva/models/location.dart';
import 'package:agua_viva/services/api_service.dart';
import 'package:agua_viva/utils/logger.dart';

class AssessmentService {
  final ApiService _apiService;
  final _logger = AppLogger();
  late Db _db;
  late DbCollection _assessmentsCollection;

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
  AssessmentService(this._apiService) {
    _initDb();
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
      Spring.fromStringIds(
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
      Spring.fromStringIds(
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
      Spring.fromStringIds(
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
      SpringAssessment.fromStringIds(
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
      SpringAssessment.fromStringIds(
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
      SpringAssessment.fromStringIds(
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

  void _initDb() async {
    try {
      _db = await Db.create(MongoDBConfig.connectionString);
      await _db.open();
      _assessmentsCollection = _db.collection('assessments');
      _logger.info('Conexão com MongoDB estabelecida com sucesso');
    } catch (e) {
      _logger.error('Erro ao conectar com MongoDB: $e');
      rethrow;
    }
  }

  Future<void> dispose() async {
    await _db.close();
    await _springsStreamController.close();
    await _assessmentsStreamController.close();
  }

  // Get single assessment by ID
  Future<SpringAssessment?> getAssessmentById(String id) async {
    try {
      final result = await _assessmentsCollection.findOne(where.id(ObjectId.parse(id)));
      if (result != null) {
        return SpringAssessment.fromMap(result);
      }
      return null;
    } catch (e) {
      _logger.error('Erro ao buscar avaliação: $e');
      rethrow;
    }
  }

  // Update assessment status
  Future<void> updateAssessmentStatus(String id, String status, String? justification) async {
    try {
      final update = {
        '\$set': {
          'status': status,
          'updatedAt': DateTime.now(),
          if (justification != null) 'justification': justification,
        }
      };

      await _assessmentsCollection.update(
        where.id(ObjectId.parse(id)),
        update,
      );
    } catch (e) {
      _logger.error('Erro ao atualizar status da avaliação: $e');
      rethrow;
    }
  }

  // Save assessment (create or update)
  Future<String> saveAssessment(SpringAssessment assessment) async {
    try {
      final response = await _apiService.post('/assessments', assessment.toJson());
      return response['id'] as String;
    } catch (e) {
      _logger.error('Erro ao salvar avaliação: $e');
      rethrow;
    }
  }

  // Get all assessments for an evaluator
  Stream<List<SpringAssessment>> getEvaluatorAssessments(String evaluatorId) async* {
    try {
      final cursor = _assessmentsCollection.find(
        where.eq('evaluatorId', ObjectId.parse(evaluatorId))
      );
      
      final assessments = await cursor.map((doc) => SpringAssessment.fromMap(doc)).toList();
      yield assessments;
    } catch (e) {
      _logger.error('Erro ao buscar avaliações do avaliador: $e');
      rethrow;
    }
  }

  // Get all assessments for a spring
  Stream<List<SpringAssessment>> getSpringAssessments(String springId) async* {
    try {
      final cursor = _assessmentsCollection.find(
        where.eq('springId', ObjectId.parse(springId))
      );
      
      final assessments = await cursor.map((doc) => SpringAssessment.fromMap(doc)).toList();
      yield assessments;
    } catch (e) {
      _logger.error('Erro ao buscar avaliações da nascente: $e');
      rethrow;
    }
  }

  // Get all assessments (for admin)
  Stream<List<SpringAssessment>> getAllAssessments() async* {
    try {
      final cursor = _assessmentsCollection.find();
      final assessments = await cursor.map((doc) => SpringAssessment.fromMap(doc)).toList();
      yield assessments;
    } catch (e) {
      _logger.error('Erro ao buscar todas avaliações: $e');
      rethrow;
    }
  }

  // Get assessments by status
  Stream<List<SpringAssessment>> getAssessmentsByStatus(String status) async* {
    try {
      final cursor = _assessmentsCollection.find(
        where.eq('status', status)
      );
      
      final assessments = await cursor.map((doc) => SpringAssessment.fromMap(doc)).toList();
      yield assessments;
    } catch (e) {
      _logger.error('Erro ao buscar avaliações por status: $e');
      rethrow;
    }
  }

  // Get springs by owner
  Stream<List<Spring>> getOwnerSprings(String ownerId) {
    final ownerObjectId = ObjectId.parse(ownerId);
    _springsStreamController.add(
      _springs.where((s) => s.ownerId == ownerObjectId).toList()
    );
    
    return _springsStreamController.stream.map((springs) {
      return springs.where((s) => s.ownerId == ownerObjectId).toList();
    });
  }

  // Get all springs (for admin)
  Stream<List<Spring>> getAllSprings() {
    _springsStreamController.add(_springs);
    return _springsStreamController.stream;
  }

  static const String collectionName = 'assessments';

  // Métodos para gerenciar avaliações
  Future<SpringAssessment> createAssessment(SpringAssessment assessment) async {
    try {
      final response = await _apiService.post('/assessments', assessment.toJson());
      return SpringAssessment.fromJson(response);
    } catch (e) {
      _logger.error('Erro ao criar avaliação: $e');
      rethrow;
    }
  }

  Future<SpringAssessment> updateAssessment(SpringAssessment assessment) async {
    try {
      final response = await _apiService.put('/assessments/${assessment.idString}', assessment.toJson());
      return SpringAssessment.fromJson(response);
    } catch (e) {
      _logger.error('Erro ao atualizar avaliação: $e');
      rethrow;
    }
  }

  Future<void> deleteAssessment(String id) async {
    try {
      await _apiService.delete('/assessments/$id');
    } catch (e) {
      _logger.error('Erro ao deletar avaliação: $e');
      rethrow;
    }
  }

  Future<List<SpringAssessment>> getAssessmentsByEvaluator(String evaluatorId) async {
    try {
      final response = await _apiService.get('/assessments/evaluator/$evaluatorId');
      return (response as List).map((json) => SpringAssessment.fromJson(json)).toList();
    } catch (e) {
      _logger.error('Erro ao buscar avaliações por avaliador: $e');
      rethrow;
    }
  }

  Future<List<SpringAssessment>> getAssessmentsBySpring(String springId) async {
    try {
      final response = await _apiService.get('/assessments/spring/$springId');
      return (response as List).map((json) => SpringAssessment.fromJson(json)).toList();
    } catch (e) {
      _logger.error('Erro ao buscar avaliações por nascente: $e');
      rethrow;
    }
  }

  // Métodos para gerenciar nascentes
  Future<Spring> createSpring(Spring spring) async {
    try {
      final response = await _apiService.createSpring(spring.toJson());
      return Spring.fromJson(response);
    } catch (e) {
      _logger.error('Erro ao criar nascente: $e');
      rethrow;
    }
  }

  Future<Spring> getSpringById(String id) async {
    try {
      final response = await _apiService.getSpring(id);
      return Spring.fromJson(response);
    } catch (e) {
      _logger.error('Erro ao buscar nascente por ID: $e');
      rethrow;
    }
  }

  Future<Spring> updateSpring(Spring spring) async {
    try {
      final response = await _apiService.updateSpring(spring.idString, spring.toJson());
      return Spring.fromJson(response);
    } catch (e) {
      _logger.error('Erro ao atualizar nascente: $e');
      rethrow;
    }
  }

  Future<void> deleteSpring(String id) async {
    try {
      await _apiService.deleteSpring(id);
    } catch (e) {
      _logger.error('Erro ao deletar nascente: $e');
      rethrow;
    }
  }

  Future<List<Spring>> getSpringsByOwner(String ownerId) async {
    try {
      final response = await _apiService.getSpringsByOwner(ownerId);
      return response.map((json) => Spring.fromJson(json)).toList();
    } catch (e) {
      _logger.error('Erro ao buscar nascentes por proprietário: $e');
      rethrow;
    }
  }

  Future<String> calculateClassification(Map<String, dynamic> environmentalRisk, Map<String, dynamic> hydroenvironmentalRisk) async {
    try {
      final response = await _apiService.post(
        '/assessments/calculate-classification',
        {
          'environmentalRisk': environmentalRisk,
          'hydroenvironmentalRisk': hydroenvironmentalRisk,
        },
      );
      return response['classification'] as String;
    } catch (e) {
      _logger.error('Erro ao calcular classificação: $e');
      rethrow;
    }
  }

  Future<void> uploadPhoto(String filePath, String photoPath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await _apiService.post(
        '/photos',
        {
          'path': photoPath,
          'data': base64Image,
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Erro ao fazer upload da foto: ${response.body}');
      }
    } catch (e, stackTrace) {
      _logger.error('Erro ao fazer upload da foto', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
