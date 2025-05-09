import 'dart:async';
import 'package:agua_viva/models/spring_model.dart';
import 'package:agua_viva/services/api_service.dart';
import 'package:agua_viva/utils/logger.dart';

class SpringService {
  final ApiService _apiService;
  final _logger = AppLogger();

  SpringService(this._apiService);

  // Criar uma nova nascente
  Future<Spring> createSpring(Spring spring) async {
    try {
      final response = await _apiService.createSpring(spring.toJson());
      return Spring.fromJson(response);
    } catch (e, stackTrace) {
      _logger.error('Erro ao criar nascente', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Buscar todas as nascentes
  Future<List<Spring>> getAllSprings() async {
    try {
      final response = await _apiService.getSprings();
      return response.map((json) => Spring.fromJson(json)).toList();
    } catch (e, stackTrace) {
      _logger.error('Erro ao buscar nascentes', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Buscar nascente por ID
  Future<Spring> getSpringById(String id) async {
    try {
      final response = await _apiService.get('/springs/$id');
      return Spring.fromJson(response);
    } catch (e, stackTrace) {
      _logger.error('Erro ao buscar nascente por ID', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Atualizar nascente
  Future<Spring> updateSpring(Spring spring) async {
    try {
      final response = await _apiService.put('/springs/${spring.idString}', spring.toJson());
      return Spring.fromJson(response);
    } catch (e, stackTrace) {
      _logger.error('Erro ao atualizar nascente', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Deletar nascente
  Future<void> deleteSpring(String id) async {
    try {
      await _apiService.delete('/springs/$id');
    } catch (e, stackTrace) {
      _logger.error('Erro ao deletar nascente', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Buscar nascentes por proprietário
  Future<List<Spring>> getSpringsByOwner(String ownerId) async {
    try {
      final response = await _apiService.get('/springs/owner/$ownerId');
      return (response as List).map((json) => Spring.fromJson(json)).toList();
    } catch (e, stackTrace) {
      _logger.error('Erro ao buscar nascentes por proprietário', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
} 