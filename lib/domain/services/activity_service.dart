import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/activity_model.dart';
import '../../data/repositories/activity_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class ActivityService implements Service<Activity> {
  final Repository<Activity> _repository;
  final ActivityRepository _activityRepository;
  final _uuid = const Uuid();

  ActivityService(Repository<Activity> repository)
    : _repository = repository,
      _activityRepository =
          repository is ActivityRepository
              ? repository
              : (repository is SyncAwareRepository<Activity>)
              ? (repository.baseRepository as ActivityRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo ActivityRepository ou SyncAwareRepository<Activity>',
              );

  @override
  Future<List<Activity>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Activity?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(Activity entity) async {
    final existingActivity = await _repository.getById(entity.id);
    if (existingActivity == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<void> createActivity({
    required DateTime date,
    required ActivityType type,
    required String description,
    double? cost,
    double? areaInHectares,
    int? quantityInBags,
    String? notes,
  }) async {
    final activity = Activity(
      id: _uuid.v4(),
      date: date,
      type: type,
      description: description,
      cost: cost,
      areaInHectares: areaInHectares,
      quantityInBags: quantityInBags,
      notes: notes,
    );
    await _repository.insert(activity);
  }

  Future<void> updateActivity({
    required String id,
    DateTime? date,
    ActivityType? type,
    String? description,
    double? cost,
    double? areaInHectares,
    int? quantityInBags,
    String? notes,
  }) async {
    final activity = await _repository.getById(id);
    if (activity != null) {
      final updatedActivity = activity.copyWith(
        date: date,
        type: type,
        description: description,
        cost: cost,
        areaInHectares: areaInHectares,
        quantityInBags: quantityInBags,
        notes: notes,
      );
      await _repository.update(updatedActivity);
    }
  }

  Future<List<Activity>> getActivitiesByType(ActivityType type) async {
    return await _activityRepository.getActivitiesByType(type);
  }

  Future<List<Activity>> getActivitiesByDate(DateTime date) async {
    return await _activityRepository.getActivitiesByDate(date);
  }

  Future<List<Activity>> getActivitiesInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _activityRepository.getActivitiesInDateRange(
      startDate,
      endDate,
    );
  }

  bool needsAlert(ActivityType type, int daysThreshold) {
    // Implementar a lógica para verificar se precisa enviar alerta
    // para uma atividade com base no tipo e no tempo desde a última realização
    return false; // Temporário
  }
}
