import 'package:uuid/uuid.dart';
import '../interfaces/service.dart';
import '../interfaces/repository.dart';
import '../models/payment_model.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/sync_aware_repository.dart';

class PaymentService implements Service<Payment> {
  final Repository<Payment> _repository;
  final PaymentRepository _paymentRepository;
  final _uuid = const Uuid();

  PaymentService(Repository<Payment> repository)
    : _repository = repository,
      _paymentRepository =
          repository is PaymentRepository
              ? repository
              : (repository is SyncAwareRepository<Payment>)
              ? (repository.baseRepository as PaymentRepository)
              : throw ArgumentError(
                'Repository deve ser do tipo PaymentRepository ou SyncAwareRepository<Payment>',
              );

  @override
  Future<List<Payment>> getAll() async {
    return await _repository.getAll();
  }

  @override
  Future<Payment?> getById(String id) async {
    return await _repository.getById(id);
  }

  @override
  Future<void> save(Payment entity) async {
    final existingPayment = await _repository.getById(entity.id);
    if (existingPayment == null) {
      await _repository.insert(entity);
    } else {
      await _repository.update(entity);
    }
  }

  @override
  Future<void> delete(String id) async {
    await _repository.delete(id);
  }

  Future<void> createPayment({
    required DateTime date,
    required double amount,
    required String collaboratorId,
    String? description,
  }) async {
    final payment = Payment(
      id: _uuid.v4(),
      date: date,
      amount: amount,
      collaboratorId: collaboratorId,
      description: description,
    );
    await _repository.insert(payment);
  }

  Future<void> updatePayment({
    required String id,
    DateTime? date,
    double? amount,
    String? collaboratorId,
    String? description,
  }) async {
    final payment = await _repository.getById(id);
    if (payment != null) {
      final updatedPayment = payment.copyWith(
        date: date,
        amount: amount,
        collaboratorId: collaboratorId,
        description: description,
      );
      await _repository.update(updatedPayment);
    }
  }

  Future<List<Payment>> getPaymentsByCollaborator(String collaboratorId) async {
    return await _paymentRepository.getPaymentsByCollaborator(collaboratorId);
  }

  Future<double> getTotalPaymentsByCollaborator(String collaboratorId) async {
    return await _paymentRepository.getTotalPaymentsByCollaborator(
      collaboratorId,
    );
  }

  Future<List<Payment>> getPaymentsInDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _paymentRepository.getPaymentsInDateRange(startDate, endDate);
  }
}
