import 'package:flutter/foundation.dart';
import '../../domain/interfaces/service.dart';
import '../../domain/models/farm_activity_model.dart';
import 'package:uuid/uuid.dart';

class FarmActivityProvider with ChangeNotifier {
  final Service<FarmActivity> _service;

  FarmActivityProvider(this._service);

  List<FarmActivity> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<FarmActivity> get activities => List.unmodifiable(_activities);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActivities() async {
    try {
      _setLoading(true);
      _activities = await _service.getAll();
      _setError(null);
    } catch (e) {
      _setError('Erro ao carregar atividades: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadActivitiesByFarmId(String farmId) async {
    try {
      _setLoading(true);
      _activities = await (_service as dynamic).getByFarmId(farmId);
      _setError(null);
    } catch (e) {
      _setError('Erro ao carregar atividades da fazenda: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadActivitiesByDate(DateTime date) async {
    try {
      _setLoading(true);
      _activities = await (_service as dynamic).getByDate(date);
      _setError(null);
    } catch (e) {
      _setError('Erro ao carregar atividades da data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadActivitiesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _setLoading(true);
      _activities = await (_service as dynamic).getByDateRange(
        startDate,
        endDate,
      );
      _setError(null);
    } catch (e) {
      _setError('Erro ao carregar atividades no período: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<FarmActivity?> getActivityById(String id) async {
    try {
      return await _service.getById(id);
    } catch (e) {
      _setError('Erro ao obter atividade: $e');
      return null;
    }
  }

  Future<void> addActivity(FarmActivity activity) async {
    try {
      _setLoading(true);
      final now = DateTime.now();
      final newActivity = FarmActivity(
        id: activity.id.isEmpty ? const Uuid().v4() : activity.id,
        title: activity.title,
        description: activity.description,
        date: activity.date,
        type: activity.type,
        farmId: activity.farmId,
        talhaoId: activity.talhaoId,
        harvestId: activity.harvestId,
        employeeId: activity.employeeId,
        productIds: activity.productIds,
        createdAt: now,
        updatedAt: now,
      );

      await _service.save(newActivity);
      await loadActivities();
      _setError(null);
    } catch (e) {
      _setError('Erro ao adicionar atividade: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateActivity(FarmActivity activity) async {
    try {
      _setLoading(true);
      await _service.save(activity);
      await loadActivities();
      _setError(null);
      return true;
    } catch (e) {
      _setError('Erro ao atualizar atividade: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteActivity(String id) async {
    try {
      _setLoading(true);
      await _service.delete(id);
      _activities.removeWhere((activity) => activity.id == id);
      notifyListeners();
      _setError(null);
      return true;
    } catch (e) {
      _setError('Erro ao excluir atividade: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<FarmActivity> getActivitiesByHarvestId(String harvestId) {
    return _activities
        .where((activity) => activity.harvestId == harvestId)
        .toList();
  }

  List<FarmActivity> getActivitiesByTalhaoId(String talhaoId) {
    return _activities
        .where((activity) => activity.talhaoId == talhaoId)
        .toList();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    if (message != null) {
      notifyListeners();
    }
  }
}
