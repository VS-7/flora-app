import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/daily_receipt_model.dart';
import '../../data/repositories/daily_receipt_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class DailyReceiptService implements Service<DailyReceipt> {
  final Repository<DailyReceipt> _repository;
  final DailyReceiptRepository _dailyReceiptRepository;
  final _uuid = const Uuid();

  DailyReceiptService(Repository<DailyReceipt> repository)
    : _repository = repository,
      _dailyReceiptRepository =
          repository is DailyReceiptRepository
              ? repository
              : (repository is SyncAwareRepository<DailyReceipt>)
              ? (repository.baseRepository as DailyReceiptRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo DailyReceiptRepository ou SyncAwareRepository<DailyReceipt>',
              );

  @override
  Future<List<DailyReceipt>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<DailyReceipt?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(DailyReceipt entity) async {
    final existingReceipt = await _repository.getById(entity.id);
    if (existingReceipt == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<DailyReceipt> createDailyReceipt({
    required DateTime date,
    required String type,
    required String description,
    required double amountPaid,
    int? measure,
    required String printStatus,
    required String employeeId,
    String? harvestId,
    String? taskId,
    required String farmId,
  }) async {
    final receipt = DailyReceipt(
      id: _uuid.v4(),
      date: date,
      type: type,
      description: description,
      amountPaid: amountPaid,
      measure: measure,
      printStatus: printStatus,
      employeeId: employeeId,
      harvestId: harvestId,
      taskId: taskId,
      farmId: farmId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _repository.insert(receipt);
    return receipt;
  }

  Future<void> updateDailyReceipt({
    required String id,
    DateTime? date,
    String? type,
    String? description,
    double? amountPaid,
    int? measure,
    String? printStatus,
  }) async {
    final receipt = await _repository.getById(id);
    if (receipt != null) {
      final updatedReceipt = receipt.copyWith(
        date: date,
        type: type,
        description: description,
        amountPaid: amountPaid,
        measure: measure,
        printStatus: printStatus,
      );
      await _repository.update(updatedReceipt);
    }
  }

  Future<List<DailyReceipt>> getReceiptsByEmployeeId(String employeeId) async {
    return await _dailyReceiptRepository.getReceiptsByEmployeeId(employeeId);
  }

  Future<List<DailyReceipt>> getReceiptsByHarvestId(String harvestId) async {
    return await _dailyReceiptRepository.getReceiptsByHarvestId(harvestId);
  }

  Future<List<DailyReceipt>> getReceiptsByTaskId(String taskId) async {
    return await _dailyReceiptRepository.getReceiptsByTaskId(taskId);
  }

  Future<List<DailyReceipt>> getReceiptsByFarmId(String farmId) async {
    return await _dailyReceiptRepository.getReceiptsByFarmId(farmId);
  }

  Future<List<DailyReceipt>> getReceiptsByPrintStatus(
    String printStatus,
    String farmId,
  ) async {
    return await _dailyReceiptRepository.getReceiptsByPrintStatus(
      printStatus,
      farmId,
    );
  }

  Future<void> updatePrintStatus(String receiptId, String printStatus) async {
    final receipt = await _repository.getById(receiptId);
    if (receipt != null) {
      final updatedReceipt = receipt.copyWith(printStatus: printStatus);
      await _repository.update(updatedReceipt);
    }
  }
}
