import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class TaskService implements Service<Task> {
  final Repository<Task> _repository;
  final TaskRepository _taskRepository;
  final _uuid = const Uuid();

  TaskService(Repository<Task> repository)
    : _repository = repository,
      _taskRepository =
          repository is TaskRepository
              ? repository
              : (repository is SyncAwareRepository<Task>)
              ? (repository.baseRepository as TaskRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo TaskRepository ou SyncAwareRepository<Task>',
              );

  @override
  Future<List<Task>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Task?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(Task entity) async {
    final existingTask = await _repository.getById(entity.id);
    if (existingTask == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<Task> createTask({
    required String description,
    required DateTime date,
    required String type,
    required double dailyRate,
    required String farmId,
    List<String>? assignedEmployees,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      description: description,
      date: date,
      type: type,
      dailyRate: dailyRate,
      farmId: farmId,
      assignedEmployees: assignedEmployees,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.insert(task);
    return task;
  }

  Future<void> updateTask({
    required String id,
    String? description,
    DateTime? date,
    String? type,
    double? dailyRate,
    List<String>? assignedEmployees,
  }) async {
    final task = await _repository.getById(id);
    if (task != null) {
      final updatedTask = task.copyWith(
        description: description,
        date: date,
        type: type,
        dailyRate: dailyRate,
        assignedEmployees: assignedEmployees,
      );
      await _repository.update(updatedTask);
    }
  }

  Future<List<Task>> getTasksByFarmId(String farmId) async {
    return await _taskRepository.getTasksByFarmId(farmId);
  }

  Future<List<Task>> getTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
    String farmId,
  ) async {
    return await _taskRepository.getTasksByDateRange(
      startDate,
      endDate,
      farmId,
    );
  }

  Future<List<Task>> getTasksByEmployeeId(String employeeId) async {
    return await _taskRepository.getTasksByEmployeeId(employeeId);
  }

  Future<void> assignEmployeeToTask(String taskId, String employeeId) async {
    final task = await _repository.getById(taskId);
    if (task != null) {
      final assignedEmployees = List<String>.from(task.assignedEmployees ?? []);
      if (!assignedEmployees.contains(employeeId)) {
        assignedEmployees.add(employeeId);
        final updatedTask = task.copyWith(assignedEmployees: assignedEmployees);
        await _repository.update(updatedTask);
      }
    }
  }

  Future<void> removeEmployeeFromTask(String taskId, String employeeId) async {
    final task = await _repository.getById(taskId);
    if (task != null && task.assignedEmployees != null) {
      final assignedEmployees = List<String>.from(task.assignedEmployees!);
      if (assignedEmployees.contains(employeeId)) {
        assignedEmployees.remove(employeeId);
        final updatedTask = task.copyWith(assignedEmployees: assignedEmployees);
        await _repository.update(updatedTask);
      }
    }
  }
}
