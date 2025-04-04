import 'entity.dart';

abstract class Service<T extends Entity> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T entity);
  Future<void> delete(String id);
}
