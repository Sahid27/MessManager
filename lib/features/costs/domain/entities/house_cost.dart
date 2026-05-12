class HouseCost {
  final String messId;
  final String month;
  final double rent, wifi, dustBill, wbEb, cookerBill;
  final String paidTo;
  final Map<String, String> memberStatus; // uid -> 'paid'|'due'|'partial'

  const HouseCost({
    required this.messId, required this.month,
    required this.rent, required this.wifi,
    required this.dustBill, required this.wbEb,
    required this.cookerBill, required this.paidTo,
    required this.memberStatus,
  });

  double get totalPerMember => rent + wifi + dustBill + wbEb + cookerBill;
}