import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/employee_production_model.dart';
import '../../data/repositories/employee_production_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class EmployeeProductionService implements Service<EmployeeProduction> {
  final Repository<EmployeeProduction> _repository;
  final EmployeeProductionRepository _employeeProductionRepository;
  final _uuid = const Uuid();

  EmployeeProductionService(Repository<EmployeeProduction> repository)
    : _repository = repository,
      _employeeProductionRepository =
          repository is EmployeeProductionRepository
              ? repository
              : (repository is SyncAwareRepository<EmployeeProduction>)
              ? (repository.baseRepository as EmployeeProductionRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo EmployeeProductionRepository ou SyncAwareRepository<EmployeeProduction>',
              );

  @override
  Future<List<EmployeeProduction>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<EmployeeProduction?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(EmployeeProduction entity) async {
    final existingProduction = await _repository.getById(entity.id);
    if (existingProduction == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<EmployeeProduction> createEmployeeProduction({
    required int measureQuantity,
    required double valuePerMeasure,
    required DateTime date,
    required double totalReceived,
    required String employeeId,
    required String harvestId,
    required String farmId,
  }) async {
    final production = EmployeeProduction(
      id: _uuid.v4(),
      measureQuantity: measureQuantity,
      valuePerMeasure: valuePerMeasure,
      date: date,
      totalReceived: totalReceived,
      employeeId: employeeId,
      harvestId: harvestId,
      farmId: farmId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.insert(production);
    return production;
  }

  Future<void> updateEmployeeProduction({
    required String id,
    int? measureQuantity,
    double? valuePerMeasure,
    DateTime? date,
    double? totalReceived,
  }) async {
    final production = await _repository.getById(id);
    if (production != null) {
      final updatedProduction = production.copyWith(
        measureQuantity: measureQuantity,
        valuePerMeasure: valuePerMeasure,
        date: date,
        totalReceived:
            totalReceived ??
            calculateTotal(
              measureQuantity ?? production.measureQuantity,
              valuePerMeasure ?? production.valuePerMeasure,
            ),
      );
      await _repository.update(updatedProduction);
    }
  }

  Future<List<EmployeeProduction>> getProductionsByEmployeeId(
    String employeeId,
  ) async {
    return await _employeeProductionRepository.getProductionsByEmployeeId(
      employeeId,
    );
  }

  Future<List<EmployeeProduction>> getProductionsByHarvestId(
    String harvestId,
  ) async {
    return await _employeeProductionRepository.getProductionsByHarvestId(
      harvestId,
    );
  }

  Future<List<EmployeeProduction>> getProductionsByFarmId(String farmId) async {
    return await _employeeProductionRepository.getProductionsByFarmId(farmId);
  }

  Future<List<EmployeeProduction>> getProductionsByDateRange(
    DateTime startDate,
    DateTime endDate,
    String farmId,
  ) async {
    return await _employeeProductionRepository.getProductionsByDateRange(
      startDate,
      endDate,
      farmId,
    );
  }

  double calculateTotal(int quantity, double valuePerMeasure) {
    return quantity * valuePerMeasure;
  }
}
