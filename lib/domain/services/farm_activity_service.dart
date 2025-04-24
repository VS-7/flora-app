import '../../domain/interfaces/service.dart';
import '../../domain/interfaces/repository.dart';
import '../../domain/models/farm_activity_model.dart';
import '../../data/repositories/farm_activity_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';
import 'package:uuid/uuid.dart';

class FarmActivityService implements Service<FarmActivity> {
  final Repository<FarmActivity> _repository;
  final FarmActivityRepository _farmActivityRepository;

  FarmActivityService(Repository<FarmActivity> repository)
    : _repository = repository,
      _farmActivityRepository =
          repository is FarmActivityRepository
              ? repository
              : (repository is SyncAwareRepository<FarmActivity>
                  ? repository.baseRepository as FarmActivityRepository
                  : throw ArgumentError(
                    'Repository deve ser do tipo FarmActivityRepository ou SyncAwareRepository<FarmActivity>',
                  ));

  @override
  Future<List<FarmActivity>> getAll() async {
    return _repository.getAll();
  }

  @override
  Future<FarmActivity?> getById(String id) async {
    return _repository.getById(id);
  }

  @override
  Future<String> add(FarmActivity entity) async {
    final id = entity.id.isEmpty ? const Uuid().v4() : entity.id;
    final now = DateTime.now();

    final activityToAdd = FarmActivity(
      id: id,
      title: entity.title,
      description: entity.description,
      date: entity.date,
      type: entity.type,
      farmId: entity.farmId,
      talhaoId: entity.talhaoId,
      harvestId: entity.harvestId,
      employeeId: entity.employeeId,
      productIds: entity.productIds,
      createdAt: now,
      updatedAt: now,
    );

    await _repository.insert(activityToAdd);
    return id;
  }

  @override
  Future<void> update(FarmActivity entity) async {
    final now = DateTime.now();
    final updatedActivity = FarmActivity(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      date: entity.date,
      type: entity.type,
      farmId: entity.farmId,
      talhaoId: entity.talhaoId,
      harvestId: entity.harvestId,
      employeeId: entity.employeeId,
      productIds: entity.productIds,
      createdAt: entity.createdAt,
      updatedAt: now,
    );

    await _repository.update(updatedActivity);
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  @override
  Future<String> save(FarmActivity entity) async {
    if (entity.id.isEmpty) {
      return add(entity);
    } else {
      await update(entity);
      return entity.id;
    }
  }

  Future<List<FarmActivity>> getByFarmId(String farmId) async {
    return _farmActivityRepository.getByFarmId(farmId);
  }

  Future<List<FarmActivity>> getByDate(DateTime date) async {
    return _farmActivityRepository.getByDate(date);
  }

  Future<List<FarmActivity>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _farmActivityRepository.getByDateRange(startDate, endDate);
  }

  Future<List<FarmActivity>> getByHarvestId(String harvestId) async {
    return _farmActivityRepository.getByHarvestId(harvestId);
  }

  Future<List<FarmActivity>> getByTalhaoId(String talhaoId) async {
    return _farmActivityRepository.getByTalhaoId(talhaoId);
  }
}
