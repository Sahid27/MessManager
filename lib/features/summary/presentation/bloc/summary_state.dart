import '../../domain/entities/member_balance.dart';

abstract class SummaryState {}
class SummaryInitial extends SummaryState {}
class SummaryLoading extends SummaryState {}
class SummaryError   extends SummaryState { final String msg; SummaryError(this.msg); }
class SummaryLoaded  extends SummaryState {
  final List<MemberBalance> balances;
  final double totalCost, mealRate;
  final int    totalMeals;
  final String month;
  SummaryLoaded({required this.balances, required this.totalCost,
    required this.mealRate, required this.totalMeals, required this.month});
}