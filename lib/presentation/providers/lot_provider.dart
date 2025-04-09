import 'package:flutter/material.dart';
import '../../domain/models/lot_model.dart';
import '../../domain/services/lot_service.dart';

class LotProvider extends ChangeNotifier {
  final LotService _lotService;
  List<Lot> _lots = [];
  Lot? _currentLot;
  bool _isLoading = false;
  String? _error;

  LotProvider({required LotService lotService}) : _lotService = lotService;

  List<Lot> get lots => _lots;
  Lot? get currentLot => _currentLot;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLots => _lots.isNotEmpty;

  // Initialize the provider by loading lots for a specific farm
  Future<void> initialize(String farmId) async {
    await loadLotsByFarmId(farmId);
  }

  // Load lots by farm ID
  Future<void> loadLotsByFarmId(String farmId) async {
    _setLoading(true);
    try {
      _lots = await _lotService.getLotsByFarmId(farmId);

      // If there are lots and no lot is currently selected, select the first one
      if (_lots.isNotEmpty && _currentLot == null) {
        _currentLot = _lots.first;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load lots: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Select a lot as current
  void selectLot(String lotId) {
    final selectedLot = _lots.firstWhere(
      (lot) => lot.id == lotId,
      orElse: () => _currentLot!,
    );

    if (selectedLot.id != _currentLot?.id) {
      _currentLot = selectedLot;
      notifyListeners();
    }
  }

  // Create a new lot
  Future<Lot?> createLot({
    required String name,
    required double area,
    required String currentHarvest,
    Map<String, double>? coordinates,
    required String farmId,
  }) async {
    _setLoading(true);
    try {
      final lot = await _lotService.createLot(
        name: name,
        area: area,
        currentHarvest: currentHarvest,
        coordinates: coordinates,
        farmId: farmId,
      );

      _lots.add(lot);

      // If this is the first lot, set it as current
      if (_currentLot == null) {
        _currentLot = lot;
      }

      _clearError();
      notifyListeners();
      return lot;
    } catch (e) {
      _setError('Failed to create lot: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing lot
  Future<bool> updateLot({
    required String id,
    String? name,
    double? area,
    String? currentHarvest,
    Map<String, double>? coordinates,
  }) async {
    _setLoading(true);
    try {
      await _lotService.updateLot(
        id: id,
        name: name,
        area: area,
        currentHarvest: currentHarvest,
        coordinates: coordinates,
      );

      // Update the local list
      final index = _lots.indexWhere((lot) => lot.id == id);
      if (index != -1) {
        final updatedLot = await _lotService.getById(id);
        if (updatedLot != null) {
          _lots[index] = updatedLot;

          // If the updated lot is the current one, update the reference
          if (_currentLot?.id == id) {
            _currentLot = updatedLot;
          }
        }
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update lot: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a lot
  Future<bool> deleteLot(String id) async {
    _setLoading(true);
    try {
      await _lotService.delete(id);

      // Remove from the local list
      _lots.removeWhere((lot) => lot.id == id);

      // If the deleted lot was the current one, select another if available
      if (_currentLot?.id == id) {
        _currentLot = _lots.isNotEmpty ? _lots.first : null;
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete lot: ${e.toString()}');
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
