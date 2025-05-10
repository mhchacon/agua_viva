import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agua_viva/models/spring_model.dart';
import 'package:agua_viva/models/assessment_model.dart';
import 'package:agua_viva/services/api_service.dart';
import 'package:agua_viva/utils/logger.dart';

class AssessmentService {
  final ApiService _apiService;
  final _logger = AppLogger();
  
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
    _loadData();
  }
  
  // Getters for streams
  Stream<List<Spring>> get springsStream => _springsStreamController.stream;
  Stream<List<SpringAssessment>> get assessmentsStream => _assessmentsStreamController.stream;
  
  // Load data from SharedPreferences
  Future<void> _loadData() async {
    try {
      // Carregar avaliações do servidor
      final assessmentsResponse = await _apiService.get('/assessments');
      if (assessmentsResponse is List) {
        _assessments = assessmentsResponse
            .map((assessment) {
              if (assessment is Map<String, dynamic>) {
                return SpringAssessment.fromJson(assessment);
              }
              throw Exception('Formato de avaliação inválido');
            })
            .toList();
        _assessmentsStreamController.add(_assessments);
      } else {
        throw Exception('Formato de resposta inválido para avaliações');
      }
      
      // Carregar nascentes do servidor
      final springsResponse = await _apiService.get('/springs');
      if (springsResponse is List) {
        _springs = springsResponse
            .map((spring) {
              if (spring is Map<String, dynamic>) {
                return Spring.fromJson(spring);
              }
              throw Exception('Formato de nascente inválido');
            })
            .toList();
        _springsStreamController.add(_springs);
      } else {
        throw Exception('Formato de resposta inválido para nascentes');
      }
    } catch (e) {
      _logger.error('Erro ao carregar dados: $e');
      // Carregar dados do cache local se falhar
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load springs from cache
    final springsJson = prefs.getString(_springsKey);
    if (springsJson != null) {
      final List<dynamic> decodedSprings = jsonDecode(springsJson);
      _springs = decodedSprings
          .map((springJson) => Spring.fromJson(springJson))
          .toList();
      _springsStreamController.add(_springs);
    }
    
    // Load assessments from cache
    final assessmentsJson = prefs.getString(_assessmentsKey);
    if (assessmentsJson != null) {
      final List<dynamic> decodedAssessments = jsonDecode(assessmentsJson);
      _assessments = decodedAssessments
          .map((assessmentJson) => SpringAssessment.fromJson(assessmentJson))
          .toList();
      _assessmentsStreamController.add(_assessments);
    }
  }
  
  // Save data to cache
  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    
    final springsJson = jsonEncode(_springs.map((spring) => spring.toJson()).toList());
    await prefs.setString(_springsKey, springsJson);
    
    final assessmentsJson = jsonEncode(_assessments.map((assessment) => assessment.toJson()).toList());
    await prefs.setString(_assessmentsKey, assessmentsJson);
  }

  // Create new assessment
  Future<SpringAssessment> createAssessment(Map<String, dynamic> assessmentData) async {
    try {
      final response = await _apiService.post('/assessments', assessmentData);
      final assessment = SpringAssessment.fromJson(response);
      
      _assessments.add(assessment);
      _assessmentsStreamController.add(_assessments);
      await _saveToCache();
      
      return assessment;
    } catch (e) {
      _logger.error('Erro ao criar avaliação: $e');
      throw Exception('Não foi possível criar a avaliação: $e');
    }
  }

  // Save assessment (create or update)
  Future<String> saveAssessment(SpringAssessment assessment) async {
    try {
      final assessmentData = assessment.toJson();
      
      // Remove IDs que não são ObjectIds válidos (24 caracteres)
      if (assessment.id.length != 24) {
        assessmentData.remove('id');
      }
      if (assessment.springId.length != 24) {
        assessmentData.remove('springId');
      }
      if (assessment.evaluatorId.length != 24) {
        assessmentData.remove('evaluatorId');
      }

      final response = await _apiService.post('/assessments', assessmentData);
      if (response is Map<String, dynamic> && response.containsKey('id')) {
        return response['id'] as String;
      } else {
        throw Exception('Resposta inválida do servidor');
      }
    } catch (e) {
      _logger.error('Erro ao salvar avaliação: $e');
      throw Exception('Não foi possível salvar a avaliação: $e');
    }
  }

  // Upload photo
  Future<void> uploadPhoto(String filePath, String photoPath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Arquivo não encontrado: $filePath');
      }
      
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await _apiService.post(
        '/photos',
        {
          'path': photoPath,
          'data': base64Image,
        },
      );
      
      if (response is! Map<String, dynamic>) {
        throw Exception('Resposta inválida do servidor');
      }
    } catch (e) {
      _logger.error('Erro ao fazer upload da foto: $e');
      throw Exception('Não foi possível fazer upload da foto: $e');
    }
  }

  // Get assessment by ID
  Future<SpringAssessment?> getAssessmentById(String id) async {
    try {
      final response = await _apiService.get('/assessments/$id');
      return SpringAssessment.fromJson(response);
    } catch (e) {
      _logger.error('Erro ao buscar avaliação: $e');
      // Try to find in cache
      return _assessments.firstWhere((a) => a.id.toString() == id);
    }
  }

  // Get assessments by owner CPF
  Future<List<SpringAssessment>> getAssessmentsByOwnerCpf(String cpf) async {
    try {
      final response = await _apiService.get('/assessments/owner/$cpf');
      if (response is List) {
        return response
            .map((assessment) => SpringAssessment.fromJson(assessment))
            .toList();
      }
      return [];
    } catch (e) {
      _logger.error('Erro ao buscar avaliações do proprietário: $e');
      // Try to find in cache
      return _assessments.where((a) => a.ownerCpf == cpf).toList();
    }
  }

  // Update assessment
  Future<SpringAssessment> updateAssessment(String id, Map<String, dynamic> assessmentData) async {
    try {
      final response = await _apiService.put('/assessments/$id', assessmentData);
      final updatedAssessment = SpringAssessment.fromJson(response);
      
      final index = _assessments.indexWhere((a) => a.id.toString() == id);
      if (index != -1) {
        _assessments[index] = updatedAssessment;
        _assessmentsStreamController.add(_assessments);
        await _saveToCache();
      }
      
      return updatedAssessment;
    } catch (e) {
      _logger.error('Erro ao atualizar avaliação: $e');
      throw Exception('Não foi possível atualizar a avaliação: $e');
    }
  }

  // Delete assessment
  Future<void> deleteAssessment(String id) async {
    try {
      await _apiService.delete('/assessments/$id');
      
      _assessments.removeWhere((a) => a.id.toString() == id);
      _assessmentsStreamController.add(_assessments);
      await _saveToCache();
    } catch (e) {
      _logger.error('Erro ao deletar avaliação: $e');
      throw Exception('Não foi possível deletar a avaliação: $e');
    }
  }

  // Update assessment status
  Future<void> updateAssessmentStatus(String id, String status) async {
    try {
      await _apiService.put('/assessments/$id/status', {'status': status});
      
      final index = _assessments.indexWhere((a) => a.id.toString() == id);
      if (index != -1) {
        _assessments[index] = _assessments[index].copyWith(status: status);
        _assessmentsStreamController.add(_assessments);
        await _saveToCache();
      }
    } catch (e) {
      _logger.error('Erro ao atualizar status da avaliação: $e');
      throw Exception('Não foi possível atualizar o status da avaliação: $e');
    }
  }

  // Dispose of stream controllers
  void dispose() {
    _springsStreamController.close();
    _assessmentsStreamController.close();
  }
}
