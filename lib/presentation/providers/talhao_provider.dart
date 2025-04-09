import 'package:flutter/material.dart';
import '../../domain/models/talhao_model.dart';
import '../../domain/services/talhao_service.dart';

class TalhaoProvider extends ChangeNotifier {
  final TalhaoService _talhaoService;
  List<Talhao> _talhoes = [];
  Talhao? _currentTalhao;
  bool _isLoading = false;
  String? _error;

  TalhaoProvider({required TalhaoService talhaoService})
    : _talhaoService = talhaoService;

  List<Talhao> get talhoes => _talhoes;
  Talhao? get currentTalhao => _currentTalhao;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTalhoes => _talhoes.isNotEmpty;

  // Initialize the provider by loading talhoes for a specific farm
  Future<void> initialize(String farmId) async {
    await loadTalhoesByFarmId(farmId);
  }

  // Load talhoes by farm ID
  Future<void> loadTalhoesByFarmId(String farmId) async {
    _setLoading(true);
    try {
      _talhoes = await _talhaoService.getTalhoesByFarmId(farmId);

      // If there are talhoes and no talhao is currently selected, select the first one
      if (_talhoes.isNotEmpty && _currentTalhao == null) {
        _currentTalhao = _talhoes.first;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load talhoes: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Select a talhao as current
  void selectTalhao(String talhaoId) {
    final selectedTalhao = _talhoes.firstWhere(
      (talhao) => talhao.id == talhaoId,
      orElse: () => _currentTalhao!,
    );

    if (selectedTalhao.id != _currentTalhao?.id) {
      _currentTalhao = selectedTalhao;
      notifyListeners();
    }
  }

  // Create a new talhao
  Future<Talhao?> createTalhao({
    required String name,
    required double area,
    required String currentHarvest,
    Map<String, double>? coordinates,
    required String farmId,
  }) async {
    _setLoading(true);
    try {
      final talhao = await _talhaoService.createTalhao(
        name: name,
        area: area,
        currentHarvest: currentHarvest,
        coordinates: coordinates,
        farmId: farmId,
      );

      _talhoes.add(talhao);

      // If this is the first talhao, set it as current
      if (_currentTalhao == null) {
        _currentTalhao = talhao;
      }

      _clearError();
      notifyListeners();
      return talhao;
    } catch (e) {
      _setError('Failed to create talhao: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing talhao
  Future<bool> updateTalhao({
    required String id,
    String? name,
    double? area,
    String? currentHarvest,
    Map<String, double>? coordinates,
  }) async {
    _setLoading(true);
    try {
      await _talhaoService.updateTalhao(
        id: id,
        name: name,
        area: area,
        currentHarvest: currentHarvest,
        coordinates: coordinates,
      );

      // Update the local list
      final index = _talhoes.indexWhere((talhao) => talhao.id == id);
      if (index != -1) {
        final updatedTalhao = await _talhaoService.getById(id);
        if (updatedTalhao != null) {
          _talhoes[index] = updatedTalhao;

          // If the updated talhao is the current one, update the reference
          if (_currentTalhao?.id == id) {
            _currentTalhao = updatedTalhao;
          }
        }
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update talhao: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a talhao
  Future<bool> deleteTalhao(String id) async {
    _setLoading(true);
    try {
      await _talhaoService.delete(id);

      // Remove from the local list
      _talhoes.removeWhere((talhao) => talhao.id == id);

      // If the deleted talhao was the current one, select another if available
      if (_currentTalhao?.id == id) {
        _currentTalhao = _talhoes.isNotEmpty ? _talhoes.first : null;
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete talhao: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Utilities to manage state
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
