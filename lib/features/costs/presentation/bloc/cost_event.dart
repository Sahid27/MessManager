import '../../domain/entities/cost_entry.dart';

abstract class CostEvent {}

class LoadCostsRequested extends CostEvent {
  final String messId, month;
  LoadCostsRequested({required this.messId, required this.month});
}

class AddCostRequested extends CostEvent {
  final String messId, month, paidBy, paidByName, note;
  final double amount;
  final bool isPaid;
  final CostType type;
  AddCostRequested({required this.messId, required this.month,
    required this.paidBy, required this.paidByName, required this.amount,
    required this.note, required this.isPaid, required this.type});
}

class TogglePaidRequested extends CostEvent {
  final String messId, month, costId;
  final bool isPaid;
  TogglePaidRequested({required this.messId, required this.month,
    required this.costId, required this.isPaid});
}