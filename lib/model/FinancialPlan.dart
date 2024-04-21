import 'package:flutter/material.dart';

class FinancialPlan {
  final int planId;
  final int userId;
  final String planCategory;
  final double planAmount;
  final DateTime planDate;

  FinancialPlan({
    required this.planId,
    required this.userId,
    required this.planCategory,
    required this.planAmount,
    required this.planDate,
  });

  factory FinancialPlan.fromJson(Map<String, dynamic> json) {
    return FinancialPlan(
      planId: json['plan_id'],
      userId: json['user_id'],
      planCategory: json['plan_category'],
      planAmount: json['plan_amount'].toDouble(),
      planDate: DateTime.parse(json['plan_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'user_id': userId,
      'plan_category': planCategory,
      'plan_amount': planAmount,
      'plan_date': planDate.toIso8601String(),
    };
  }
}
