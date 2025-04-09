import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/talhao_model.dart';
import '../../data/repositories/talhao_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class TalhaoService implements Service<Talhao> {
  final Repository<Talhao> _repository;
  final TalhaoRepository _talhaoRepository;
  final _uuid = const Uuid();

  TalhaoService(Repository<Talhao> repository)
    : _repository = repository,
      _talhaoRepository =
          repository is TalhaoRepository
              ? repository
              : (repository is SyncAwareRepository<Talhao>)
              ? (repository.baseRepository as TalhaoRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo TalhaoRepository ou SyncAwareRepository<Talhao>',
              );

  @override
  Future<List<Talhao>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Talhao?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(Talhao entity) async {
    final existingTalhao = await _repository.getById(entity.id);
    if (existingTalhao == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<Talhao> createTalhao({
    required String name,
    required double area,
    required String currentHarvest,
    Map<String, double>? coordinates,
    required String farmId,
  }) async {
    final talhao = Talhao(
      id: _uuid.v4(),
      name: name,
      area: area,
      currentHarvest: currentHarvest,
      coordinates: coordinates,
      farmId: farmId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.insert(talhao);
    return talhao;
  }

  Future<void> updateTalhao({
    required String id,
    String? name,
    double? area,
    String? currentHarvest,
    Map<String, double>? coordinates,
  }) async {
    final talhao = await _repository.getById(id);
    if (talhao != null) {
      final updatedTalhao = talhao.copyWith(
        name: name,
        area: area,
        currentHarvest: currentHarvest,
        coordinates: coordinates,
      );
      await _repository.update(updatedTalhao);
    }
  }

  Future<List<Talhao>> getTalhoesByFarmId(String farmId) async {
    return await _talhaoRepository.getTalhoesByFarmId(farmId);
  }
}
