import 'package:flutter/material.dart';
import '../../domain/models/employee_model.dart';
import '../../domain/services/employee_service.dart';

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _employeeService;
  List<Employee> _employees = [];
  Employee? _currentEmployee;
  bool _isLoading = false;
  String? _error;

  EmployeeProvider({required EmployeeService employeeService})
    : _employeeService = employeeService;

  List<Employee> get employees => _employees;
  Employee? get currentEmployee => _currentEmployee;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasEmployees => _employees.isNotEmpty;

  // Initialize the provider by loading employees for a specific farm
  Future<void> initialize(String farmId) async {
    await loadEmployeesByFarmId(farmId);
  }

  // Load employees by farm ID
  Future<void> loadEmployeesByFarmId(String farmId) async {
    _setLoading(true);
    try {
      _employees = await _employeeService.getEmployeesByFarmId(farmId);

      // If there are employees and no employee is currently selected, select the first one
      if (_employees.isNotEmpty && _currentEmployee == null) {
        _currentEmployee = _employees.first;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load employees: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load employees by role
  Future<void> loadEmployeesByRole(String role, String farmId) async {
    _setLoading(true);
    try {
      _employees = await _employeeService.getEmployeesByRole(role, farmId);

      // Reset current employee if the list changes
      if (_employees.isNotEmpty) {
        if (_currentEmployee == null ||
            !_employees.any((e) => e.id == _currentEmployee!.id)) {
          _currentEmployee = _employees.first;
        }
      } else {
        _currentEmployee = null;
      }

      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load employees by role: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Select an employee as current
  void selectEmployee(String employeeId) {
    final selectedEmployee = _employees.firstWhere(
      (employee) => employee.id == employeeId,
      orElse: () => _currentEmployee!,
    );

    if (selectedEmployee.id != _currentEmployee?.id) {
      _currentEmployee = selectedEmployee;
      notifyListeners();
    }
  }

  // Create a new employee
  Future<Employee?> createEmployee({
    required String name,
    required String role,
    required double cost,
    String? photoUrl,
    required String farmId,
  }) async {
    _setLoading(true);
    try {
      final employee = await _employeeService.createEmployee(
        name: name,
        role: role,
        cost: cost,
        photoUrl: photoUrl,
        farmId: farmId,
      );

      _employees.add(employee);

      // If this is the first employee, set it as current
      if (_currentEmployee == null) {
        _currentEmployee = employee;
      }

      _clearError();
      notifyListeners();
      return employee;
    } catch (e) {
      _setError('Failed to create employee: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing employee
  Future<bool> updateEmployee({
    required String id,
    String? name,
    String? role,
    double? cost,
    String? photoUrl,
  }) async {
    _setLoading(true);
    try {
      await _employeeService.updateEmployee(
        id: id,
        name: name,
        role: role,
        cost: cost,
        photoUrl: photoUrl,
      );

      // Update the local list
      final index = _employees.indexWhere((employee) => employee.id == id);
      if (index != -1) {
        final updatedEmployee = await _employeeService.getById(id);
        if (updatedEmployee != null) {
          _employees[index] = updatedEmployee;

          // If the updated employee is the current one, update the reference
          if (_currentEmployee?.id == id) {
            _currentEmployee = updatedEmployee;
          }
        }
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update employee: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete an employee
  Future<bool> deleteEmployee(String id) async {
    _setLoading(true);
    try {
      await _employeeService.delete(id);

      // Remove from the local list
      _employees.removeWhere((employee) => employee.id == id);

      // If the deleted employee was the current one, select another if available
      if (_currentEmployee?.id == id) {
        _currentEmployee = _employees.isNotEmpty ? _employees.first : null;
      }

      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete employee: ${e.toString()}');
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
