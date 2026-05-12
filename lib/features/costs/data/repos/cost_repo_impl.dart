import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/cost_entry.dart';
import '../../domain/entities/house_cost.dart';

class CostRepoImpl {
  final _db = FirebaseFirestore.instance;

  Future<void> addCost({
    required String messId, required String month,
    required String paidBy, required String paidByName,
    required double amount, required String note,
    required bool isPaid, required CostType type,
  }) async {
    final id = const Uuid().v4();
    await _db.collection('messes').doc(messId)
      .collection('costs').doc(month)
      .collection('entries').doc(id).set({
        'paidBy': paidBy, 'paidByName': paidByName,
        'amount': amount, 'note': note, 'isPaid': isPaid,
        'type': type.name, 'date': Timestamp.now()});
  }

  Future<void> togglePaid(String messId, String month, String costId, bool isPaid) {
    return _db.collection('messes').doc(messId)
      .collection('costs').doc(month).collection('entries').doc(costId)
      .update({'isPaid': isPaid});
  }

  Stream<List<CostEntry>> getCostsStream(String messId, String month) {
    return _db.collection('messes').doc(messId)
      .collection('costs').doc(month).collection('entries')
      .orderBy('date').snapshots()
      .map((snap) => snap.docs.map((d) {
        final data = d.data();
        return CostEntry(
          id: d.id, messId: messId,
          paidBy: data['paidBy'], paidByName: data['paidByName'],
          amount: (data['amount'] as num).toDouble(),
          note: data['note'] ?? '', isPaid: data['isPaid'] ?? false,
          date: (data['date'] as Timestamp).toDate(),
          type: CostType.values.firstWhere(
            (t) => t.name == data['type'], orElse: () => CostType.other));
      }).toList());
  }

  double calcTotalCost(List<CostEntry> entries) =>
    entries.fold(0.0, (s, e) => s + e.amount);

  Future<void> saveHouseCost(HouseCost cost) async {
    await _db.collection('messes').doc(cost.messId)
      .collection('houseCosts').doc(cost.month).set({
        'rent': cost.rent, 'wifi': cost.wifi, 'dustBill': cost.dustBill,
        'wbEb': cost.wbEb, 'cookerBill': cost.cookerBill,
        'paidTo': cost.paidTo, 'memberStatus': cost.memberStatus});
  }

  Stream<HouseCost?> getHouseCostStream(String messId, String month) {
    return _db.collection('messes').doc(messId)
      .collection('houseCosts').doc(month).snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        final data = doc.data()!;
        return HouseCost(
          messId: messId, month: month,
          rent: (data['rent'] as num?)?.toDouble() ?? 0,
          wifi: (data['wifi'] as num?)?.toDouble() ?? 0,
          dustBill: (data['dustBill'] as num?)?.toDouble() ?? 0,
          wbEb: (data['wbEb'] as num?)?.toDouble() ?? 0,
          cookerBill: (data['cookerBill'] as num?)?.toDouble() ?? 0,
          paidTo: data['paidTo'] ?? '',
          memberStatus: Map<String, String>.from(data['memberStatus'] ?? {}));
      });
  }
}