class BudgetInfo {
  final double budgetLimit;
  final double budgetSpent;
  final String budgetCategory;

  BudgetInfo({
    required this.budgetLimit,
    required this.budgetSpent,
    required this.budgetCategory,
  });

  factory BudgetInfo.fromJson(Map<String, dynamic> json) {
    return BudgetInfo(
      budgetLimit: json['budgetLimit'].toDouble(),
      budgetSpent: json['budgetSpent'].toDouble(),
      budgetCategory: json['budgetCategory'],
    );
  }
}
