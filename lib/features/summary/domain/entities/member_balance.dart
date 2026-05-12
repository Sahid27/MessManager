class MemberBalance {
  final String uid, name;
  final int    totalMeals;
  final double mealOwe;      // meals * rate
  final double marketPaid;   // what they paid for market
  final double houseOwe;     // house cost per member
  final double balance;      // marketPaid - mealOwe - houseOwe

  const MemberBalance({
    required this.uid, required this.name,
    required this.totalMeals, required this.mealOwe,
    required this.marketPaid, required this.houseOwe,
    required this.balance,
  });

  bool get isPositive => balance >= 0;
}