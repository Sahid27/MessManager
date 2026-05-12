import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/meal_entry.dart';

class MealRepoImpl {
  final _db = FirebaseFirestore.instance;

  Future<void> saveMeals({
    required String messId,
    required String date,
    required Map<String, int> counts,
  }) async {
    final month = date.substring(0, 7);
    await _db.collection('messes').doc(messId)
      .collection('meals').doc(month)
      .collection('entries').doc(date)
      .set(counts.map((k, v) => MapEntry(k, v)));
  }

  Stream<List<MealEntry>> getMealsStream({required String messId, required String month}) {
    return _db.collection('messes').doc(messId)
      .collection('meals').doc(month).collection('entries')
      .orderBy(FieldPath.documentId).snapshots()
      .map((snap) => snap.docs.map((d) => MealEntry(
        date: d.id,
        counts: Map<String, int>.from(d.data().map(
          (k, v) => MapEntry(k, (v as num).toInt()))))).toList());
  }

  int calcTotal(List<MealEntry> entries) =>
    entries.fold(0, (s, e) => s + e.totalMeals);

  double calcRate(List<MealEntry> entries, double totalCost) {
    final total = calcTotal(entries);
    if (total == 0) return 0.0;
    return totalCost / total;
  }

  int memberTotal(List<MealEntry> entries, String uid) =>
    entries.fold(0, (s, e) => s + e.mealFor(uid));
}