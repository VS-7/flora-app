import 'package:flutter/material.dart';
import '../../domain/models/harvest_model.dart';
import '../../domain/services/harvest_service.dart';

class HarvestProvider extends ChangeNotifier {
  final HarvestService _harvestService;
  List<Harvest> _harvests = [];
  Harvest? _currentHarvest;
  bool _isLoading = false;
  String? _error;

  HarvestProvider({required HarvestService harvestService})
    : _harvestService = harvestService;

  List<Harvest> get harvests => _harvests;
  Harvest? get currentHarvest => _currentHarvest;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasHarvests => _harvests.isNotEmpty;

  // Initialize the provider by loading harvests for a specific farm
  Future<void> initialize(String farmId) async {
    await loadHarvestsByFarmId(farmId);
  }

  // Load harvests by farm ID
  Future<void> loadHarvestsByFarmId(String farmId) async {
    _setLoading(true);
    try {
      _harvests = await _harvestService.getHarvestsByFarmId(farmId);

      // If there are harvests and no harvest is currently selected, select the first one
      if (_harvests.isNotEmpty && _currentHarvest == null) {
        _currentHarvest = _harvests.first;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load harvests: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load harvests by lot ID
  Future<void> loadHarvestsByTalhaoId(String talhaoId) async {
    _setLoading(true);
    try {
      _harvests = await _harvestService.getHarvestsByTalhaoId(talhaoId);

      // Reset current harvest if the list changes
      if (_harvests.isNotEmpty) {
        if (_currentHarvest == null ||
            !_harvests.any((h) => h.id == _currentHarvest!.id)) {
          _currentHarvest = _harvests.first;
        }
      } else {
        _currentHarvest = null;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load harvests for lot: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load harvests by date range
  Future<void> loadHarvestsByDateRange(
    DateTime startDate,
    DateTime endDate,
    String farmId,
  ) async {
    _setLoading(true);
    try {
      _harvests = await _harvestService.getHarvestsByDateRange(
        startDate,
        endDate,
        farmId,
      );

      // Reset current harvest if the list changes
      if (_harvests.isNotEmpty) {
        if (_currentHarvest == null ||
            !_harvests.any((h) => h.id == _currentHarvest!.id)) {
          _currentHarvest = _harvests.first;
        }
      } else {
        _currentHarvest = null;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load harvests by date range: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Select a harvest as current
  void selectHarvest(String harvestId) {
    final selectedHarvest = _harvests.firstWhere(
      (harvest) => harvest.id == harvestId,
      orElse: () => _currentHarvest!,
    );

    if (selectedHarvest.id != _currentHarvest?.id) {
      _currentHarvest = selectedHarvest;
      notifyListeners();
    }
  }

  // Create a new harvest
  Future<Harvest?> createHarvest({
    required DateTime startDate,
    required String coffeeType,
    required int totalQuantity,
    required int quality,
    String? weather,
    required String talhaoId,
    required String farmId,
    List<String>? usedProducts,
  }) async {
    _setLoading(true);
    try {
      final harvest = await _harvestService.createHarvest(
        startDate: startDate,
        coffeeType: coffeeType,
        totalQuantity: totalQuantity,
        quality: quality,
        weather: weather,
        talhaoId: talhaoId,
        farmId: farmId,
        usedProducts: usedProducts,
      );

      _harvests.add(harvest);

      // If this is the first harvest, set it as current
      if (_currentHarvest == null) {
        _currentHarvest = harvest;
      }

      _clearError();
      notifyListeners();
      return harvest;
    } catch (e) {
      _setError('Failed to create harvest: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing harvest
  Future<bool> updateHarvest({
    required String id,
    DateTime? startDate,
    String? coffeeType,
    int? totalQuantity,
    int? quality,
    String? weather,
    String? talhaoId,
    List<String>? usedProducts,
  }) async {
    _setLoading(true);
    try {
      await _harvestService.updateHarvest(
        id: id,
        startDate: startDate,
        coffeeType: coffeeType,
        totalQuantity: totalQuantity,
        quality: quality,
        weather: weather,
        talhaoId: talhaoId,
        usedProducts: usedProducts,
      );

      // Update the local list
      final index = _harvests.indexWhere((harvest) => harvest.id == id);
      if (index != -1) {
        final updatedHarvest = await _harvestService.getById(id);
        if (updatedHarvest != null) {
          _harvests[index] = updatedHarvest;

          // If the updated harvest is the current one, update the reference
          if (_currentHarvest?.id == id) {
            _currentHarvest = updatedHarvest;
          }
        }
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update harvest: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a harvest
  Future<bool> deleteHarvest(String id) async {
    _setLoading(true);
    try {
      await _harvestService.delete(id);

      // Remove from the local list
      _harvests.removeWhere((harvest) => harvest.id == id);

      // If the deleted harvest was the current one, select another if available
      if (_currentHarvest?.id == id) {
        _currentHarvest = _harvests.isNotEmpty ? _harvests.first : null;
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete harvest: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add a product to a harvest
  Future<bool> addProductToHarvest(String harvestId, String productId) async {
    _setLoading(true);
    try {
      await _harvestService.addProductToHarvest(harvestId, productId);

      // Update the harvest in the local list
      final index = _harvests.indexWhere((harvest) => harvest.id == harvestId);
      if (index != -1) {
        final updatedHarvest = await _harvestService.getById(harvestId);
        if (updatedHarvest != null) {
          _harvests[index] = updatedHarvest;

          // If the updated harvest is the current one, update the reference
          if (_currentHarvest?.id == harvestId) {
            _currentHarvest = updatedHarvest;
          }
        }
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add product to harvest: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove a product from a harvest
  Future<bool> removeProductFromHarvest(
    String harvestId,
    String productId,
  ) async {
    _setLoading(true);
    try {
      await _harvestService.removeProductFromHarvest(harvestId, productId);

      // Update the harvest in the local list
      final index = _harvests.indexWhere((harvest) => harvest.id == harvestId);
      if (index != -1) {
        final updatedHarvest = await _harvestService.getById(harvestId);
        if (updatedHarvest != null) {
          _harvests[index] = updatedHarvest;

          // If the updated harvest is the current one, update the reference
          if (_currentHarvest?.id == harvestId) {
            _currentHarvest = updatedHarvest;
          }
        }
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove product from harvest: ${e.toString()}');
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
