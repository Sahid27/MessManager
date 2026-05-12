class CostEntry {
  final String   id;
  final String   messId;
  final String   paidBy;   // uid
  final String   paidByName;
  final double   amount;
  final String   note;
  final DateTime date;
  final bool     isPaid;
  final CostType type;

  const CostEntry({
    required this.id, required this.messId,
    required this.paidBy, required this.paidByName,
    required this.amount, required this.note,
    required this.date, required this.isPaid,
    required this.type,
  });
}

enum CostType { market, gas, utility, other }