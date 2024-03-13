import 'package:flutter/cupertino.dart';

class BudgetCategory {
  final int id;
  final String name;
  final IconData icon; // use icondata to represent an icon
  final Color color;
  double? amount;

  BudgetCategory({required this.id, required this.name , required this.icon , required this.color});


}
