import 'entity.dart';

abstract class SyncService<T extends Entity> {
  /// Sincroniza dados do dispositivo local para o Supabase (upload)
  Future<void> syncUp();

  /// Sincroniza dados do Supabase para o dispositivo local (download)
  Future<void> syncDown();

  /// Verifica se há sincronização pendente
  Future<bool> hasPendingSync();

  /// Retorna a última vez que a sincronização foi realizada
  Future<DateTime?> getLastSyncTime();

  /// Marca a entidade como sincronizada
  Future<void> markAsSynced(T entity);

  /// Sincroniza automaticamente quando há conexão de internet disponível
  Future<void> autoSync();
}
