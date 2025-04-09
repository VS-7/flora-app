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

  Future<Harvest> createHarvest({
    required DateTime startDate,
    required String coffeeType,
    required int totalQuantity,
    required int quality,
    String? weather,
    required String lotId,
    required String farmId,
    List<String>? usedProducts,
  }) async {
    final harvest = Harvest(
      id: _uuid.v4(),
      startDate: startDate,
      coffeeType: coffeeType,
      totalQuantity: totalQuantity,
      quality: quality,
      weather: weather,
      lotId: lotId,
      farmId: farmId,
      usedProducts: usedProducts,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.insert(harvest);
    return harvest;
  }

  Future<void> updateHarvest({
    required String id,
    DateTime? startDate,
    String? coffeeType,
    int? totalQuantity,
    int? quality,
    String? weather,
    List<String>? usedProducts,
  }) async {
    final harvest = await _repository.getById(id);
    if (harvest != null) {
      final updatedHarvest = harvest.copyWith(
        startDate: startDate,
        coffeeType: coffeeType,
        totalQuantity: totalQuantity,
        quality: quality,
        weather: weather,
        usedProducts: usedProducts,
      );
      await _repository.update(updatedHarvest);
    }
  }

  Future<List<Harvest>> getHarvestsByFarmId(String farmId) async {
    return await _harvestRepository.getHarvestsByFarmId(farmId);
  }

  Future<List<Harvest>> getHarvestsByLotId(String lotId) async {
    return await _harvestRepository.getHarvestsByLotId(lotId);
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

  Future<void> addProductToHarvest(String harvestId, String productId) async {
    final harvest = await _repository.getById(harvestId);
    if (harvest != null) {
      final usedProducts = List<String>.from(harvest.usedProducts ?? []);
      if (!usedProducts.contains(productId)) {
        usedProducts.add(productId);
        final updatedHarvest = harvest.copyWith(usedProducts: usedProducts);
        await _repository.update(updatedHarvest);
      }
    }
  }

  Future<void> removeProductFromHarvest(
    String harvestId,
    String productId,
  ) async {
    final harvest = await _repository.getById(harvestId);
    if (harvest != null && harvest.usedProducts != null) {
      final usedProducts = List<String>.from(harvest.usedProducts!);
      if (usedProducts.contains(productId)) {
        usedProducts.remove(productId);
        final updatedHarvest = harvest.copyWith(usedProducts: usedProducts);
        await _repository.update(updatedHarvest);
      }
    }
  }
}
