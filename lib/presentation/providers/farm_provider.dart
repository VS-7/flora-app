import 'package:flutter/material.dart';
import '../../domain/models/farm_model.dart';
import '../../domain/services/farm_service.dart';

class FarmProvider extends ChangeNotifier {
  final FarmService _farmService;
  List<Farm> _farms = [];
  Farm? _currentFarm;
  bool _isLoading = false;
  String? _error;

  FarmProvider({required FarmService farmService}) : _farmService = farmService;

  List<Farm> get farms => _farms;
  Farm? get currentFarm => _currentFarm;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasFarms => _farms.isNotEmpty;

  // Inicializar o provedor carregando as fazendas
  Future<void> initialize(String userId) async {
    await loadFarmsByUserId(userId);
  }

  // Carregar fazendas de um usuário
  Future<void> loadFarmsByUserId(String userId) async {
    _setLoading(true);
    try {
      _farms = await _farmService.getFarmsByUserId(userId);

      // Se houver fazendas, selecione a primeira como atual
      if (_farms.isNotEmpty && _currentFarm == null) {
        _currentFarm = _farms.first;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Falha ao carregar fazendas: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Selecionar uma fazenda como atual
  void selectFarm(String farmId) {
    final selectedFarm = _farms.firstWhere(
      (farm) => farm.id == farmId,
      orElse: () => _currentFarm!,
    );

    if (selectedFarm.id != _currentFarm?.id) {
      _currentFarm = selectedFarm;
      notifyListeners();
    }
  }

  // Criar uma nova fazenda
  Future<Farm?> createFarm({
    required String name,
    required String userId,
    String? location,
    String? description,
    double? totalArea,
    String? mainCrop,
  }) async {
    _setLoading(true);
    try {
      final farm = await _farmService.createFarm(
        name: name,
        userId: userId,
        location: location,
        description: description,
        totalArea: totalArea,
        mainCrop: mainCrop,
      );

      _farms.add(farm);

      // Se esta for a primeira fazenda, defina-a como atual
      if (_currentFarm == null) {
        _currentFarm = farm;
      }

      _clearError();
      notifyListeners();
      return farm;
    } catch (e) {
      _setError('Falha ao criar fazenda: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar uma fazenda existente
  Future<bool> updateFarm({
    required String id,
    String? name,
    String? location,
    String? description,
    double? totalArea,
    String? mainCrop,
  }) async {
    _setLoading(true);
    try {
      await _farmService.updateFarm(
        id: id,
        name: name,
        location: location,
        description: description,
        totalArea: totalArea,
        mainCrop: mainCrop,
      );

      // Atualizar a lista local
      final index = _farms.indexWhere((farm) => farm.id == id);
      if (index != -1) {
        final updatedFarm = await _farmService.getById(id);
        if (updatedFarm != null) {
          _farms[index] = updatedFarm;

          // Se a fazenda atualizada for a atual, atualize a referência
          if (_currentFarm?.id == id) {
            _currentFarm = updatedFarm;
          }
        }
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Falha ao atualizar fazenda: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Excluir uma fazenda
  Future<bool> deleteFarm(String id) async {
    _setLoading(true);
    try {
      await _farmService.delete(id);

      // Remover da lista local
      _farms.removeWhere((farm) => farm.id == id);

      // Se a fazenda excluída for a atual, selecione outra se disponível
      if (_currentFarm?.id == id) {
        _currentFarm = _farms.isNotEmpty ? _farms.first : null;
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Falha ao excluir fazenda: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Utilitários para gerenciar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
