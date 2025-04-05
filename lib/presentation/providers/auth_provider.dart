import 'package:flutter/material.dart';
import '../../domain/models/auth_model.dart';
import '../../domain/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  Auth? _currentAuth;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required AuthService authService}) : _authService = authService;

  Auth? get currentAuth => _currentAuth;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated =>
      _currentAuth != null && _currentAuth!.isTokenValid;

  // Inicializar o provedor carregando os dados de autenticação
  Future<void> initialize() async {
    await _loadAuthFromStorage();
  }

  // Carregar autenticação do banco de dados
  Future<void> _loadAuthFromStorage() async {
    _setLoading(true);
    try {
      _currentAuth = await _authService.getCurrentAuth();
      _clearError();
    } catch (e) {
      _setError('Falha ao carregar dados de autenticação');
    } finally {
      _setLoading(false);
    }
  }

  // Fazer login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      _currentAuth = await _authService.login(email, password);
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Falha ao fazer login: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Fazer logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentAuth = null;
      _clearError();
    } catch (e) {
      _setError('Falha ao fazer logout: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Verificar status de autenticação
  Future<bool> checkAuthStatus() async {
    return await _authService.isUserLoggedIn();
  }

  // Utilitários para gerenciar estado
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
