import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class TransactionInfo {
  final int transactionId;
  final String budgetCategory;
  final String note;
  final DateTime transactionDate;
  final DateTime transactionTime;

  final double transactionAmount;

  TransactionInfo({
    required this.transactionId,
    required this.budgetCategory,
    required this.note,
    required this.transactionDate,
    required this.transactionTime,

    required this.transactionAmount,
  });

  factory TransactionInfo.fromJson(Map<String, dynamic> json) {
    final DateFormat timeFormat = DateFormat('HH:mm:ss');

    return TransactionInfo(
      transactionId: json['transactionId'],
      budgetCategory: json['budgetCategory'],
      note: json['note'],
      transactionDate: DateTime.parse(json['transactionDate']),
      transactionTime: timeFormat.parse(json['transactionTime']),
      transactionAmount: json['transactionAmount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'budgetCategory': budgetCategory,
      'note': note,
      'transactionDate': transactionDate.toIso8601String(),
      'transactionTime': transactionTime.toIso8601String(),

      'transactionAmount': transactionAmount,
    };
  }
}