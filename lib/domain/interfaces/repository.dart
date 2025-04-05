import 'entity.dart';

abstract class Repository<T extends Entity> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> insert(T entity);
  Future<void> update(T entity);
  Future<void> delete(String id);
}
