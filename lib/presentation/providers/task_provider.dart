import 'package:flutter/material.dart';
import '../../domain/models/task_model.dart';
import '../../domain/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;
  List<Task> _tasks = [];
  Task? _currentTask;
  bool _isLoading = false;
  String? _error;

  TaskProvider({required TaskService taskService}) : _taskService = taskService;

  List<Task> get tasks => _tasks;
  Task? get currentTask => _currentTask;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTasks => _tasks.isNotEmpty;

  // Initialize the provider by loading tasks for a specific farm
  Future<void> initialize(String farmId) async {
    await loadTasksByFarmId(farmId);
  }

  // Load tasks by farm ID
  Future<void> loadTasksByFarmId(String farmId) async {
    _setLoading(true);
    try {
      _tasks = await _taskService.getTasksByFarmId(farmId);

      // If there are tasks and no task is currently selected, select the first one
      if (_tasks.isNotEmpty && _currentTask == null) {
        _currentTask = _tasks.first;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tasks: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load tasks by date range
  Future<void> loadTasksByDateRange(
    DateTime startDate,
    DateTime endDate,
    String farmId,
  ) async {
    _setLoading(true);
    try {
      _tasks = await _taskService.getTasksByDateRange(
        startDate,
        endDate,
        farmId,
      );

      // Reset current task if the list changes
      if (_tasks.isNotEmpty) {
        if (_currentTask == null ||
            !_tasks.any((t) => t.id == _currentTask!.id)) {
          _currentTask = _tasks.first;
        }
      } else {
        _currentTask = null;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tasks by date range: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load tasks for a specific employee
  Future<void> loadTasksByEmployeeId(String employeeId) async {
    _setLoading(true);
    try {
      _tasks = await _taskService.getTasksByEmployeeId(employeeId);

      // Reset current task if the list changes
      if (_tasks.isNotEmpty) {
        if (_currentTask == null ||
            !_tasks.any((t) => t.id == _currentTask!.id)) {
          _currentTask = _tasks.first;
        }
      } else {
        _currentTask = null;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tasks for employee: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Select a task as current
  void selectTask(String taskId) {
    final selectedTask = _tasks.firstWhere(
      (task) => task.id == taskId,
      orElse: () => _currentTask!,
    );

    if (selectedTask.id != _currentTask?.id) {
      _currentTask = selectedTask;
      notifyListeners();
    }
  }

  // Create a new task
  Future<Task?> createTask({
    required String description,
    required DateTime date,
    required String type,
    required double dailyRate,
    required String farmId,
    List<String>? assignedEmployees,
  }) async {
    _setLoading(true);
    try {
      final task = await _taskService.createTask(
        description: description,
        date: date,
        type: type,
        dailyRate: dailyRate,
        farmId: farmId,
        assignedEmployees: assignedEmployees,
      );

      _tasks.add(task);

      // If this is the first task, set it as current
      if (_currentTask == null) {
        _currentTask = task;
      }

      _clearError();
      notifyListeners();
      return task;
    } catch (e) {
      _setError('Failed to create task: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing task
  Future<bool> updateTask({
    required String id,
    String? description,
    DateTime? date,
    String? type,
    double? dailyRate,
    List<String>? assignedEmployees,
  }) async {
    _setLoading(true);
    try {
      await _taskService.updateTask(
        id: id,
        description: description,
        date: date,
        type: type,
        dailyRate: dailyRate,
        assignedEmployees: assignedEmployees,
      );

      // Update the local list
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        final updatedTask = await _taskService.getById(id);
        if (updatedTask != null) {
          _tasks[index] = updatedTask;

          // If the updated task is the current one, update the reference
          if (_currentTask?.id == id) {
            _currentTask = updatedTask;
          }
        }
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update task: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a task
  Future<bool> deleteTask(String id) async {
    _setLoading(true);
    try {
      await _taskService.delete(id);

      // Remove from the local list
      _tasks.removeWhere((task) => task.id == id);

      // If the deleted task was the current one, select another if available
      if (_currentTask?.id == id) {
        _currentTask = _tasks.isNotEmpty ? _tasks.first : null;
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete task: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Assign an employee to a task
  Future<bool> assignEmployeeToTask(String taskId, String employeeId) async {
    _setLoading(true);
    try {
      await _taskService.assignEmployeeToTask(taskId, employeeId);

      // Update the task in the local list
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        final updatedTask = await _taskService.getById(taskId);
        if (updatedTask != null) {
          _tasks[index] = updatedTask;

          // If the updated task is the current one, update the reference
          if (_currentTask?.id == taskId) {
            _currentTask = updatedTask;
          }
        }
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to assign employee to task: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove an employee from a task
  Future<bool> removeEmployeeFromTask(String taskId, String employeeId) async {
    _setLoading(true);
    try {
      await _taskService.removeEmployeeFromTask(taskId, employeeId);

      // Update the task in the local list
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        final updatedTask = await _taskService.getById(taskId);
        if (updatedTask != null) {
          _tasks[index] = updatedTask;

          // If the updated task is the current one, update the reference
          if (_currentTask?.id == taskId) {
            _currentTask = updatedTask;
          }
        }
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove employee from task: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Utilities to manage state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
