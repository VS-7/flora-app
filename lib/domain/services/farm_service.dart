import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/farm_model.dart';
import '../../data/repositories/farm_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class FarmService implements Service<Farm> {
  final Repository<Farm> _repository;
  final FarmRepository _farmRepository;
  final _uuid = const Uuid();

  FarmService(Repository<Farm> repository)
    : _repository = repository,
      _farmRepository =
          repository is FarmRepository
              ? repository
              : (repository is SyncAwareRepository<Farm>)
              ? (repository.baseRepository as FarmRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo FarmRepository ou SyncAwareRepository<Farm>',
              );

  @override
  Future<List<Farm>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Farm?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(Farm entity) async {
    final existingFarm = await _repository.getById(entity.id);
    if (existingFarm == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<Farm> createFarm({
    required String name,
    required String userId,
    String? location,
    String? description,
    double? totalArea,
    String? mainCrop,
  }) async {
    final farm = Farm(
      id: _uuid.v4(),
      name: name,
      location: location,
      userId: userId,
      description: description,
      totalArea: totalArea,
      mainCrop: mainCrop,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.insert(farm);
    return farm;
  }

  Future<void> updateFarm({
    required String id,
    String? name,
    String? location,
    String? description,
    double? totalArea,
    String? mainCrop,
  }) async {
    final farm = await _repository.getById(id);
    if (farm != null) {
      final updatedFarm = farm.copyWith(
        name: name,
        location: location,
        description: description,
        totalArea: totalArea,
        mainCrop: mainCrop,
      );
      await _repository.update(updatedFarm);
    }
  }

  Future<List<Farm>> getFarmsByUserId(String userId) async {
    return await _farmRepository.getFarmsByUserId(userId);
  }
}
