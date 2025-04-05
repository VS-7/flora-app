import '../../domain/interfaces/entity.dart';
import '../../domain/interfaces/repository.dart';
import 'sync_status_repository.dart';

/// Decorator para os repositórios que adiciona a capacidade de rastrear mudanças
/// para sincronização
class SyncAwareRepository<T extends Entity> implements Repository<T> {
  final Repository<T> _baseRepository;
  final SyncStatusRepository _syncStatusRepository;
  final String _entityType;

  SyncAwareRepository(
    this._baseRepository,
    this._syncStatusRepository,
    this._entityType,
  );

  // Expor o repositório base para acesso a métodos específicos
  Repository<T> get baseRepository => _baseRepository;

  @override
  Future<List<T>> getAll() {
    return _baseRepository.getAll();
  }

  @override
  Future<T?> getById(String id) {
    return _baseRepository.getById(id);
  }

  @override
  Future<void> insert(T entity) async {
    await _baseRepository.insert(entity);
    // Marcar como pendente de sincronização
    await _syncStatusRepository.markAsPending(entity.id, _entityType);
  }

  @override
  Future<void> update(T entity) async {
    await _baseRepository.update(entity);
    // Marcar como pendente de sincronização
    await _syncStatusRepository.markAsPending(entity.id, _entityType);
  }

  @override
  Future<void> delete(String id) async {
    await _baseRepository.delete(id);
    // Remover status de sincronização
    await _syncStatusRepository.delete(id, _entityType);
  }
}
