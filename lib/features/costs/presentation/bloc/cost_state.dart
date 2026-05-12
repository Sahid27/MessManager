import '../../domain/entities/cost_entry.dart';

abstract class CostState {}
class CostInitial extends CostState {}
class CostLoading extends CostState {}
class CostError   extends CostState { final String msg; CostError(this.msg); }
class CostLoaded  extends CostState {
  final List<CostEntry> entries;
  final double totalCost;
  final double paidTotal;
  final double dueTotal;
  CostLoaded({required this.entries, required this.totalCost,
    required this.paidTotal, required this.dueTotal});
}