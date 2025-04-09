import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/lot_model.dart';
import '../../data/repositories/lot_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class LotService implements Service<Lot> {
  final Repository<Lot> _repository;
  final LotRepository _lotRepository;
  final _uuid = const Uuid();

  LotService(Repository<Lot> repository)
    : _repository = repository,
      _lotRepository =
          repository is LotRepository
              ? repository
              : (repository is SyncAwareRepository<Lot>)
              ? (repository.baseRepository as LotRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo LotRepository ou SyncAwareRepository<Lot>',
              );

  @override
  Future<List<Lot>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Lot?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(Lot entity) async {
    final existingLot = await _repository.getById(entity.id);
    if (existingLot == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<Lot> createLot({
    required String name,
    required double area,
    required String currentHarvest,
    Map<String, double>? coordinates,
    required String farmId,
  }) async {
    final lot = Lot(
      id: _uuid.v4(),
      name: name,
      area: area,
      currentHarvest: currentHarvest,
      coordinates: coordinates,
      farmId: farmId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.insert(lot);
    return lot;
  }

  Future<void> updateLot({
    required String id,
    String? name,
    double? area,
    String? currentHarvest,
    Map<String, double>? coordinates,
  }) async {
    final lot = await _repository.getById(id);
    if (lot != null) {
      final updatedLot = lot.copyWith(
        name: name,
        area: area,
        currentHarvest: currentHarvest,
        coordinates: coordinates,
      );
      await _repository.update(updatedLot);
    }
  }

  Future<List<Lot>> getLotsByFarmId(String farmId) async {
    return await _lotRepository.getLotsByFarmId(farmId);
  }
}
