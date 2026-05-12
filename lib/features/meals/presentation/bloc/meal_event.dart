abstract class MealEvent {}

class LoadMealsRequested extends MealEvent {
  final String messId, month;
  LoadMealsRequested({required this.messId, required this.month});
}

class SaveMealsRequested extends MealEvent {
  final String messId, date;
  final Map<String, int> counts;
  SaveMealsRequested({required this.messId, required this.date, required this.counts});
}