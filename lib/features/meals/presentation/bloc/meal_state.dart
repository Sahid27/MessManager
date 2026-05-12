import '../../domain/entities/meal_entry.dart';

abstract class MealState {}
class MealInitial extends MealState {}
class MealLoading extends MealState {}
class MealSaving  extends MealState {}
class MealSaved   extends MealState {}
class MealError   extends MealState { final String msg; MealError(this.msg); }
class MealLoaded  extends MealState {
  final String month;
  final List<MealEntry> entries;
  final int totalMeals;
  final double mealRate;
  MealLoaded({required this.month, required this.entries,
    required this.totalMeals, required this.mealRate});
}