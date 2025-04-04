import 'package:flutter/material.dart';
import '../../domain/models/user_model.dart';
import '../../domain/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;
  User? _currentUser;

  UserProvider({required UserService userService}) : _userService = userService;

  User? get currentUser => _currentUser;
  bool get isUserRegistered => _currentUser != null;

  // Inicializar o provedor carregando o usuário do banco de dados
  Future<void> initialize() async {
    await _loadUserFromStorage();
  }

  // Carregar usuário do banco de dados
  Future<void> _loadUserFromStorage() async {
    final users = await _userService.getAll();
    if (users.isNotEmpty) {
      _currentUser = users.first; // Assumindo que só temos um usuário
      notifyListeners();
    }
  }

  // Registrar um novo usuário
  Future<void> registerUser(
    String name,
    String farmName,
    String? location,
  ) async {
    await _userService.createUser(name, farmName, location);
    await _loadUserFromStorage();
  }

  // Atualizar dados do usuário
  Future<void> updateUser({
    String? name,
    String? farmName,
    String? location,
  }) async {
    if (_currentUser == null) return;

    await _userService.updateUser(
      id: _currentUser!.id,
      name: name,
      farmName: farmName,
      location: location,
    );
    await _loadUserFromStorage();
  }
}
