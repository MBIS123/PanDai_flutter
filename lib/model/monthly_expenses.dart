class Transaction {
  final String budgetCategory;
  final double transactionAmount;

  Transaction({required this.budgetCategory, required this.transactionAmount});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      budgetCategory: json['budgetCategory'],
      transactionAmount: json['transactionAmount'].toDouble(),
    );
  }
}