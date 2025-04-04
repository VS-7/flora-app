import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class UserService implements Service<User> {
  final UserRepository _repository;
  final _uuid = const Uuid();

  UserService(this._repository);

  @override
  Future<List<User>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<User?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(User entity) async {
    final existingUser = await _repository.getById(entity.id);
    if (existingUser == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<void> createUser(
    String name,
    String farmName,
    String? location,
  ) async {
    final user = User(
      id: _uuid.v4(),
      name: name,
      farmName: farmName,
      location: location,
    );
    await _repository.insert(user);
  }

  Future<void> updateUser({
    required String id,
    String? name,
    String? farmName,
    String? location,
  }) async {
    final user = await _repository.getById(id);
    if (user != null) {
      final updatedUser = user.copyWith(
        name: name,
        farmName: farmName,
        location: location,
      );
      await _repository.update(updatedUser);
    }
  }
}
