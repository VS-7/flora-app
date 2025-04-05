import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/collaborator_model.dart';
import '../../data/repositories/collaborator_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class CollaboratorService implements Service<Collaborator> {
  final Repository<Collaborator> _repository;
  final CollaboratorRepository _collaboratorRepository;
  final _uuid = const Uuid();

  CollaboratorService(Repository<Collaborator> repository)
    : _repository = repository,
      _collaboratorRepository =
          repository is CollaboratorRepository
              ? repository
              : (repository is SyncAwareRepository<Collaborator>)
              ? (repository.baseRepository as CollaboratorRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo CollaboratorRepository ou SyncAwareRepository<Collaborator>',
              );

  @override
  Future<List<Collaborator>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Collaborator?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(Collaborator entity) async {
    final existingCollaborator = await _repository.getById(entity.id);
    if (existingCollaborator == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<void> createCollaborator(String name, double dailyRate) async {
    final collaborator = Collaborator(
      id: _uuid.v4(),
      name: name,
      dailyRate: dailyRate,
    );
    await _repository.insert(collaborator);
  }

  Future<void> updateCollaborator({
    required String id,
    String? name,
    double? dailyRate,
  }) async {
    final collaborator = await _repository.getById(id);
    if (collaborator != null) {
      final updatedCollaborator = collaborator.copyWith(
        name: name,
        dailyRate: dailyRate,
      );
      await _repository.update(updatedCollaborator);
    }
  }
}
