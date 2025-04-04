import 'package:flutter/material.dart';
import '../../domain/models/activity_model.dart';
import '../../domain/models/collaborator_model.dart';
import '../../domain/models/payment_model.dart';
import '../../domain/services/activity_service.dart';
import '../../domain/services/collaborator_service.dart';
import '../../domain/services/payment_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityService _activityService;
  final CollaboratorService _collaboratorService;
  final PaymentService _paymentService;

  List<Activity> _activities = [];
  List<Collaborator> _collaborators = [];
  List<Payment> _payments = [];

  ActivityProvider({
    required ActivityService activityService,
    required CollaboratorService collaboratorService,
    required PaymentService paymentService,
  }) : _activityService = activityService,
       _collaboratorService = collaboratorService,
       _paymentService = paymentService;

  // Getters
  List<Activity> get activities => [..._activities];
  List<Collaborator> get collaborators => [..._collaborators];
  List<Payment> get payments => [..._payments];

  // Inicializar o provedor carregando os dados do banco de dados
  Future<void> initialize() async {
    await _loadActivitiesFromStorage();
    await _loadCollaboratorsFromStorage();
    await _loadPaymentsFromStorage();
  }

  // Carregar atividades do banco de dados
  Future<void> _loadActivitiesFromStorage() async {
    _activities = await _activityService.getAll();
    notifyListeners();
  }

  // Carregar colaboradores do banco de dados
  Future<void> _loadCollaboratorsFromStorage() async {
    _collaborators = await _collaboratorService.getAll();
    notifyListeners();
  }

  // Carregar pagamentos do banco de dados
  Future<void> _loadPaymentsFromStorage() async {
    _payments = await _paymentService.getAll();
    notifyListeners();
  }

  // Adicionar uma nova atividade
  Future<void> addActivity({
    required DateTime date,
    required ActivityType type,
    required String description,
    double? cost,
    double? areaInHectares,
    int? quantityInBags,
    String? notes,
  }) async {
    await _activityService.createActivity(
      date: date,
      type: type,
      description: description,
      cost: cost,
      areaInHectares: areaInHectares,
      quantityInBags: quantityInBags,
      notes: notes,
    );
    await _loadActivitiesFromStorage();
  }

  // Adicionar um novo colaborador
  Future<void> addCollaborator(String name, double dailyRate) async {
    await _collaboratorService.createCollaborator(name, dailyRate);
    await _loadCollaboratorsFromStorage();
  }

  // Adicionar um novo pagamento
  Future<void> addPayment({
    required DateTime date,
    required double amount,
    required String collaboratorId,
    String? description,
  }) async {
    await _paymentService.createPayment(
      date: date,
      amount: amount,
      collaboratorId: collaboratorId,
      description: description,
    );
    await _loadPaymentsFromStorage();
  }

  // Obter atividades de um dia específico
  List<Activity> getActivitiesForDay(DateTime date) {
    return _activities
        .where(
          (activity) =>
              activity.date.year == date.year &&
              activity.date.month == date.month &&
              activity.date.day == date.day,
        )
        .toList();
  }

  // Obter colaborador por ID
  Collaborator? getCollaboratorById(String id) {
    try {
      return _collaborators.firstWhere((collab) => collab.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obter atividades por tipo
  List<Activity> getActivitiesByType(ActivityType type) {
    return _activities.where((activity) => activity.type == type).toList();
  }

  // Obter pagamentos por colaborador
  List<Payment> getPaymentsByCollaborator(String collaboratorId) {
    return _payments
        .where((payment) => payment.collaboratorId == collaboratorId)
        .toList();
  }

  // Obter total de pagamentos por colaborador
  double getTotalPaymentsByCollaborator(String collaboratorId) {
    return getPaymentsByCollaborator(
      collaboratorId,
    ).fold(0, (total, payment) => total + payment.amount);
  }

  // Verificar se precisa enviar alerta para atividade
  bool needsAlert(ActivityType type, int daysThreshold) {
    final activities = getActivitiesByType(type);
    if (activities.isEmpty) return false;

    // Ordenar por data, mais recente primeiro
    activities.sort((a, b) => b.date.compareTo(a.date));

    final mostRecentActivity = activities.first;
    final daysSinceLastActivity =
        DateTime.now().difference(mostRecentActivity.date).inDays;

    return daysSinceLastActivity >= daysThreshold;
  }
}
