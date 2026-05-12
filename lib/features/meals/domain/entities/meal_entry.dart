class MealEntry {
  final String              date;
  final Map<String, int> counts;

  const MealEntry({required this.date, required this.counts});

  int get totalMeals => counts.values.fold(0, (s, v) => s + v);
  int mealFor(String uid) => counts[uid] ?? 0;
}