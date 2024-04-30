class Income {
  final String incomeType;
  final double amount;

  Income({
    required this.incomeType,
    required this.amount,
    //test
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      incomeType: json['incomeType'] as String,
      amount: json['amount'] as double,
    );
  }
}
