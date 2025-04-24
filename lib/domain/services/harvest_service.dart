import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/harvest_model.dart';
import '../../data/repositories/harvest_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class HarvestService implements Service<Harvest> {
  final Repository<Harvest> _repository;
  final HarvestRepository _harvestRepository;
  final _uuid = const Uuid();

  HarvestService(Repository<Harvest> repository)
    : _repository = repository,
      _harvestRepository =
          repository is HarvestRepository
              ? repository
              : (repository is SyncAwareRepository<Harvest>)
              ? (repository.baseRepository as HarvestRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo HarvestRepository ou SyncAwareRepository<Harvest>',
              );

  @override
  Future<List<Harvest>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Harvest?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(Harvest entity) async {
    final existingHarvest = await _repository.getById(entity.id);
    if (existingHarvest == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<Harvest> createYearlyHarvest({
    required String name,
    required int year,
    required DateTime startDate,
    required String farmId,
  }) async {
    final harvest = Harvest(
      id: _uuid.v4(),
      name: name,
      year: year,
      startDate: startDate,
      farmId: farmId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.insert(harvest);
    return harvest;
  }

  Future<void> updateHarvest({
    required String id,
    String? name,
    int? year,
    DateTime? startDate,
  }) async {
    final harvest = await _repository.getById(id);
    if (harvest != null) {
      final updatedHarvest = harvest.copyWith(
        name: name,
        year: year,
        startDate: startDate,
      );
      await _repository.update(updatedHarvest);
    }
  }

  Future<List<Harvest>> getHarvestsByFarmId(String farmId) async {
    return await _harvestRepository.getHarvestsByFarmId(farmId);
  }

  Future<Harvest?> getCurrentYearHarvest(String farmId) async {
    final currentYear = DateTime.now().year;
    final harvests = await _harvestRepository.getHarvestsByFarmId(farmId);
    return harvests.where((h) => h.year == currentYear).firstOrNull;
  }

  Future<Harvest?> getHarvestByYear(String farmId, int year) async {
    final harvests = await _harvestRepository.getHarvestsByFarmId(farmId);
    return harvests.where((h) => h.year == year).firstOrNull;
  }

  Future<List<Harvest>> getHarvestsByDateRange(
    DateTime startDate,
    DateTime endDate,
    String farmId,
  ) async {
    return await _harvestRepository.getHarvestsByDateRange(
      startDate,
      endDate,
      farmId,
    );
  }
}
