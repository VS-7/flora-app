import 'dart:async';
import '../../utils/connectivity_helper.dart';
import '../interfaces/sync_service.dart';
import '../models/farm_model.dart';
import '../models/employee_model.dart';
import '../models/product_model.dart';
import '../models/talhao_model.dart';
import '../models/harvest_model.dart';

class SyncManager {
  final ConnectivityHelper _connectivityHelper;
  final SyncService<Farm> farmSyncService;
  final SyncService<Employee> employeeSyncService;
  final SyncService<Product> productSyncService;
  final SyncService<Talhao> talhaoSyncService;
  final SyncService<Harvest> harvestSyncService;
  Timer? _syncTimer;

  SyncManager({
    required this.farmSyncService,
    required this.employeeSyncService,
    required this.productSyncService,
    required this.talhaoSyncService,
    required this.harvestSyncService,
    required ConnectivityHelper connectivityHelper,
  }) : _connectivityHelper = connectivityHelper;

  List<SyncService> get _syncServices => [
    farmSyncService,
    employeeSyncService,
    productSyncService,
    talhaoSyncService,
    harvestSyncService,
  ];

  Future<void> syncAll() async {
    if (!_connectivityHelper.isConnected) {
      return;
    }

    for (final service in _syncServices) {
      // Primeiro envia os dados locais para o servidor
      await service.syncUp();
      // Depois baixa as atualizações do servidor
      await service.syncDown();
    }
  }

  Future<void> syncUp() async {
    if (!_connectivityHelper.isConnected) {
      return;
    }

    for (final service in _syncServices) {
      await service.syncUp();
    }
  }

  Future<void> syncDown() async {
    if (!_connectivityHelper.isConnected) {
      return;
    }

    for (final service in _syncServices) {
      await service.syncDown();
    }
  }

  Future<bool> hasPendingSync() async {
    for (final service in _syncServices) {
      if (await service.hasPendingSync()) {
        return true;
      }
    }
    return false;
  }

  void startPeriodicSync({Duration period = const Duration(minutes: 15)}) {
    stopPeriodicSync();
    _syncTimer = Timer.periodic(period, (_) {
      syncAll();
    });
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // Iniciar sincronização quando a conectividade for restaurada
  void setupConnectivitySync() {
    // Aqui idealmente usaríamos o stream de conectividade para reagir a mudanças
    // Mas para simplificar, podemos fazer verificações periódicas de conectividade
    Timer.periodic(const Duration(minutes: 1), (_) async {
      await _connectivityHelper.checkConnectivity();
      if (_connectivityHelper.isConnected) {
        await syncAll();
      }
    });
  }
}
