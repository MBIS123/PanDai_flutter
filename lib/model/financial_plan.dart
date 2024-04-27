import 'package:flutter/material.dart';

class FinancialPlan {
  final int financialPlanId; // Updated property name to match entity class
  final String planName;
  final double targetAmount;
  final DateTime createPlanDate;
  final String successScore;
  final String assessment;
  final String financialAdvice;
  final String financialAdjustment;

  FinancialPlan({
    required this.financialPlanId, // Updated property name to match entity class
    required this.planName,
    required this.targetAmount,
    required this.createPlanDate,
    required this.successScore,
    required this.assessment,
    required this.financialAdvice,
    required this.financialAdjustment,
  });

  factory FinancialPlan.fromJson(Map<String, dynamic> json) {
    return FinancialPlan(
      financialPlanId: json['financialPlanId'] ?? 0,
      planName: json['planName'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0.0).toDouble(),
      createPlanDate: DateTime.parse(json['createPlanDate'] ?? ''),
      successScore: json['successScore'] ?? '',
      assessment: json['assessment'] ?? '',
      financialAdvice: json['financialAdvice'] ?? '',
      financialAdjustment: json['financialAdjustment'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'financialPlanId': financialPlanId, // Updated property name to match entity class
      'planName': planName,
      'targetAmount': targetAmount,
      'createPlanDate': createPlanDate.toIso8601String(),
      'successScore': successScore,
      'assessment': assessment,
      'financialAdvice': financialAdvice,
      'financialAdjustment': financialAdjustment,
    };
  }
}
