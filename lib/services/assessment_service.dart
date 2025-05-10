import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agua_viva/models/spring_model.dart';
import 'package:agua_viva/models/assessment_model.dart';
import 'package:agua_viva/services/api_service.dart';
import 'package:agua_viva/utils/logger.dart';
import 'package:agua_viva/config/api_config.dart';
import 'package:agua_viva/utils/image_compression.dart';

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
    // Verificar conectividade e tentar sincronizar periodicamente
    Future.delayed(const Duration(seconds: 5), _checkAndSyncData);
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

  // Verificar conectividade e sincronizar dados se possível
  Future<void> _checkAndSyncData() async {
    try {
      final isConnected = await _apiService.checkServerConnection();
      if (isConnected) {
        _logger.info('Conectado ao servidor. Sincronizando dados...');
        await _loadData();
      } else {
        _logger.warning('Sem conexão com o servidor. Usando dados em cache.');
      }
    } catch (e) {
      _logger.error('Erro ao verificar conectividade: $e');
    }
    
    // Agendar próxima verificação
    Future.delayed(const Duration(minutes: 2), _checkAndSyncData);
  }

  // Sincronizar dados offline com o servidor quando a conexão for restaurada
  Future<void> syncOfflineData() async {
    _logger.info('Tentando sincronizar dados offline com o servidor...');
    
    try {
      // Verificar se há conexão com o servidor
      final isConnected = await _apiService.checkServerConnection();
      if (!isConnected) {
        _logger.warning('Sem conexão, não é possível sincronizar dados offline.');
        return;
      }

      // Carregar dados do cache
      await _loadFromCache();
      
      // Verificar se há avaliações para sincronizar
      final offlineAssessments = _assessments.where((a) => a.id.startsWith('offline_')).toList();
      
      if (offlineAssessments.isEmpty) {
        _logger.info('Não há avaliações offline para sincronizar.');
        return;
      }
      
      _logger.info('Encontradas ${offlineAssessments.length} avaliações offline para sincronizar.');
      
      int successCount = 0;
      
      // Sincronizar cada avaliação
      for (var assessment in offlineAssessments) {
        try {
          // Preparar dados para enviar ao servidor
          final assessmentData = assessment.toJson();
          // Remover ID offline
          assessmentData.remove('id');
          
          // Tentar enviar ao servidor
          final response = await _apiService.post('/assessments', assessmentData);
          
          if (response is Map<String, dynamic> && (response.containsKey('id') || response.containsKey('_id'))) {
            // Obter ID do servidor
            final serverId = response.containsKey('id') ? response['id'] as String : response['_id'] as String;
            
            // Remover avaliação offline
            _assessments.removeWhere((a) => a.id == assessment.id);
            
            // Adicionar avaliação sincronizada
            final serverAssessment = SpringAssessment.fromJson(response);
            _assessments.add(serverAssessment);
            
            successCount++;
            _logger.info('Avaliação sincronizada com sucesso: ${assessment.id} -> $serverId');
          }
        } catch (e) {
          _logger.error('Erro ao sincronizar avaliação ${assessment.id}: $e');
        }
      }
      
      if (successCount > 0) {
        // Atualizar o cache
        _assessmentsStreamController.add(_assessments);
        await _saveToCache();
        
        _logger.info('Sincronização concluída: $successCount/${offlineAssessments.length} avaliações sincronizadas com sucesso.');
      }
    } catch (e) {
      _logger.error('Erro durante a sincronização dos dados offline: $e');
    }
  }

  // Create new assessment
  Future<SpringAssessment> createAssessment(Map<String, dynamic> assessmentData) async {
    try {
      _logger.info('Iniciando criação de avaliação: ${assessmentData.keys}');
      // Verificar conexão com o servidor
      _logger.info('URL da API: ${_apiService.baseUrl}');
      
      final response = await _apiService.post('/assessments', assessmentData);
      _logger.info('Resposta recebida do servidor: $response');
      
      final assessment = SpringAssessment.fromJson(response);
      
      _assessments.add(assessment);
      _assessmentsStreamController.add(_assessments);
      await _saveToCache();
      
      return assessment;
    } catch (e) {
      _logger.error('Erro ao criar avaliação: $e');
      // Tentar salvar localmente mesmo com erro
      try {
        _logger.info('Tentando salvar avaliação no cache local após erro no servidor');
        final localAssessment = SpringAssessment.fromJson(assessmentData);
        _assessments.add(localAssessment);
        _assessmentsStreamController.add(_assessments);
        await _saveToCache();
        return localAssessment;
      } catch (cacheError) {
        _logger.error('Erro ao salvar no cache: $cacheError');
        throw Exception('Não foi possível criar a avaliação: $e');
      }
    }
  }

  // Save assessment com suporte offline
  Future<String> saveAssessment(SpringAssessment assessment) async {
    try {
      final assessmentData = assessment.toJson();
      
      // Remove IDs que não são ObjectIds válidos (24 caracteres)
      if (assessment.id.length != 24) {
        assessmentData.remove('id');
        _logger.info('ID removido por não ser um ObjectId válido: ${assessment.id}');
      }
      if (assessment.springId.length != 24) {
        assessmentData.remove('springId');
        _logger.info('SpringID removido por não ser um ObjectId válido: ${assessment.springId}');
      }
      if (assessment.evaluatorId.length != 24) {
        assessmentData.remove('evaluatorId');
        _logger.info('EvaluatorID removido por não ser um ObjectId válido: ${assessment.evaluatorId}');
      }

      _logger.info('Tentando salvar avaliação no servidor...');
      _logger.info('Modo offline: ${ApiConfig.offlineMode}');
      
      try {
        final response = await _apiService.post('/assessments', assessmentData);
        _logger.info('Resposta recebida: $response');
        
        String id;
        if (response is Map<String, dynamic>) {
          // Verificar se é um ID offline
          if (response.containsKey('_offlineId')) {
            _logger.info('Salvando em modo offline com ID: ${response['_offlineId']}');
            id = response['_offlineId'];
            
            // Marcando para sincronização futura
            assessmentData['_needsSync'] = true;
            
            // Salvar em cache com ID offline
            final offlineAssessment = assessment.copyWith(id: id);
            _assessments.add(offlineAssessment);
            _assessmentsStreamController.add(_assessments);
            await _saveToCache();
            
            return id;
          } 
          // Verificar IDs normais
          else if (response.containsKey('id')) {
            id = response['id'] as String;
          } else if (response.containsKey('_id')) {
            id = response['_id'] as String;
          } else {
            _logger.error('Resposta não contém ID: $response');
            throw Exception('Resposta inválida do servidor');
          }
          
          // Salvou com sucesso no servidor
          final serverAssessment = SpringAssessment.fromJson(response);
          
          // Atualizar na lista local
          final index = _assessments.indexWhere((a) => a.id == assessment.id);
          if (index >= 0) {
            _assessments[index] = serverAssessment;
          } else {
            _assessments.add(serverAssessment);
          }
          
          _assessmentsStreamController.add(_assessments);
          await _saveToCache();
          
          return id;
        } else {
          throw Exception('Resposta inválida do servidor');
        }
      } catch (e) {
        // Em caso de erro na conexão, salva localmente
        _logger.warning('Erro ao salvar no servidor. Salvando localmente: $e');
        
        // Gerar ID offline se necessário
        final offlineId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
        final offlineAssessment = assessment.copyWith(
          id: offlineId,
          status: 'pending',
          updatedAt: DateTime.now(),
        );
        
        // Armazenar localmente
        _assessments.add(offlineAssessment);
        _assessmentsStreamController.add(_assessments);
        await _saveToCache();
        
        return offlineId;
      }
    } catch (e) {
      _logger.error('Erro ao salvar avaliação: $e');
      throw Exception('Não foi possível salvar a avaliação: $e');
    }
  }

  // Upload photo
  Future<void> uploadPhoto(String filePath, String photoPath) async {
    try {
      // Comprimir a imagem antes do upload
      final compressedFilePath = await ImageCompression.compressImage(filePath);
      
      // Se a compressão falhar, usa a imagem original
      final fileToUpload = compressedFilePath ?? filePath;
      
      final file = File(fileToUpload);
      if (!await file.exists()) {
        throw Exception('Arquivo não encontrado: $fileToUpload');
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
      
      // Apagar o arquivo temporário comprimido se ele existir
      if (compressedFilePath != null) {
        try {
          final compressedFile = File(compressedFilePath);
          if (await compressedFile.exists()) {
            await compressedFile.delete();
          }
        } catch (e) {
          _logger.warning('Erro ao apagar arquivo temporário comprimido: $e');
        }
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

  // Get all assessments
  Future<List<SpringAssessment>> getAllAssessments() async {
    try {
      final response = await _apiService.get('/assessments');
      if (response is List) {
        final assessments = response
            .map((assessment) => SpringAssessment.fromJson(assessment))
            .toList();
        
        // Atualizar a lista em cache com os dados mais recentes
        _assessments = assessments;
        _assessmentsStreamController.add(_assessments);
        await _saveToCache();
        
        return assessments;
      }
      return [];
    } catch (e) {
      _logger.error('Erro ao buscar todas as avaliações: $e');
      // Retornar a lista em cache se houver erro na comunicação
      return _assessments;
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
