import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../interfaces/repository.dart';
import '../interfaces/service.dart';
import '../models/auth_model.dart';
import '../../data/database/supabase_config.dart';

class AuthService implements Service<Auth> {
  final Repository<Auth> _repository;
  final _uuid = const Uuid();

  AuthService(this._repository);

  @override
  Future<List<Auth>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Auth?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(Auth entity) async {
    final existingAuth = await _repository.getById(entity.id);
    if (existingAuth == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  // Verifica se há um usuário autenticado
  Future<bool> isUserLoggedIn() async {
    final session = SupabaseConfig.client.auth.currentSession;
    if (session != null && !session.isExpired) {
      return true;
    }

    // Verifica se temos uma autenticação armazenada localmente
    final auths = await getAll();
    if (auths.isNotEmpty) {
      final auth = auths.first;
      return auth.isTokenValid;
    }

    return false;
  }

  // Obtém o usuário atualmente autenticado
  Future<Auth?> getCurrentAuth() async {
    final auths = await getAll();
    if (auths.isNotEmpty) {
      return auths.first;
    }
    return null;
  }

  // Faz login com email e senha
  Future<Auth> login(String email, String password) async {
    try {
      // Fazer login usando o Supabase
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Criar um objeto Auth com os dados retornados
      final auth = Auth(
        id: _uuid.v4(),
        email: email,
        token: response.session?.accessToken,
        expiresAt:
            response.session?.expiresAt != null
                ? DateTime.fromMillisecondsSinceEpoch(
                  response.session!.expiresAt! * 1000,
                )
                : null,
      );

      // Limpar auths antigos
      final existingAuths = await getAll();
      for (var oldAuth in existingAuths) {
        await delete(oldAuth.id);
      }

      // Salvar a nova auth
      await _repository.insert(auth);
      return auth;
    } catch (e) {
      throw Exception('Falha ao fazer login: ${e.toString()}');
    }
  }

  // Deslogar
  Future<void> logout() async {
    try {
      // Logout no Supabase
      await SupabaseConfig.client.auth.signOut();

      // Remover autenticação local
      final auths = await getAll();
      for (var auth in auths) {
        await delete(auth.id);
      }
    } catch (e) {
      throw Exception('Falha ao fazer logout: ${e.toString()}');
    }
  }
}
