import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/employee_model.dart';
import '../../data/repositories/employee_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class EmployeeService implements Service<Employee> {
  final Repository<Employee> _repository;
  final EmployeeRepository _employeeRepository;
  final _uuid = const Uuid();

  EmployeeService(Repository<Employee> repository)
    : _repository = repository,
      _employeeRepository =
          repository is EmployeeRepository
              ? repository
              : (repository is SyncAwareRepository<Employee>)
              ? (repository.baseRepository as EmployeeRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo EmployeeRepository ou SyncAwareRepository<Employee>',
              );

  @override
  Future<List<Employee>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Employee?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(Employee entity) async {
    final existingEmployee = await _repository.getById(entity.id);
    if (existingEmployee == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<Employee> createEmployee({
    required String name,
    required String role,
    required double cost,
    String? photoUrl,
    required String farmId,
  }) async {
    final employee = Employee(
      id: _uuid.v4(),
      name: name,
      role: role,
      cost: cost,
      photoUrl: photoUrl,
      farmId: farmId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.insert(employee);
    return employee;
  }

  Future<void> updateEmployee({
    required String id,
    String? name,
    String? role,
    double? cost,
    String? photoUrl,
  }) async {
    final employee = await _repository.getById(id);
    if (employee != null) {
      final updatedEmployee = employee.copyWith(
        name: name,
        role: role,
        cost: cost,
        photoUrl: photoUrl,
      );
      await _repository.update(updatedEmployee);
    }
  }

  Future<List<Employee>> getEmployeesByFarmId(String farmId) async {
    return await _employeeRepository.getEmployeesByFarmId(farmId);
  }

  Future<List<Employee>> getEmployeesByRole(String role, String farmId) async {
    return await _employeeRepository.getEmployeesByRole(role, farmId);
  }
}
