import 'package:flutter/material.dart';

import '../model/budget_category.dart';

final List<BudgetCategory> budgetCategories = [
  BudgetCategory(id: 1, name: 'Beauty', icon: Icons.face, color: Colors.pink),
  BudgetCategory(
      id: 2, name: 'Food', icon: Icons.restaurant, color: Colors.green),
  BudgetCategory(
      id: 3, name: 'Beverage', icon: Icons.local_cafe, color: Colors.brown),
  BudgetCategory(
      id: 4, name: 'Bills', icon: Icons.receipt, color: Colors.blue),
  BudgetCategory(
      id: 5, name: 'Car', icon: Icons.directions_car, color: Colors.red),
  BudgetCategory(
      id: 6, name: 'Clothing', icon: Icons.checkroom, color: Colors.purple),
  BudgetCategory(
      id: 7, name: 'Education', icon: Icons.school, color: Colors.deepOrange),
  BudgetCategory(
      id: 8, name: 'Electronics', icon: Icons.devices, color: Colors.teal),
  BudgetCategory(
      id: 9,
      name: 'Entertainment',
      icon: Icons.videogame_asset,
      color: Colors.amber),
  BudgetCategory(
      id: 10,
      name: 'Health',
      icon: Icons.local_hospital,
      color: Colors.lightGreen),
  BudgetCategory(
      id: 11,
      name: 'Transport',
      icon: Icons.directions_bus,
      color: Colors.lightBlue),
  BudgetCategory(
      id: 12, name: 'Tax', icon: Icons.attach_money, color: Colors.yellow),
  BudgetCategory(
      id: 13, name: 'Insurance', icon: Icons.security, color: Colors.grey),
  BudgetCategory(
      id: 14,
      name: 'Shopping',
      icon: Icons.shopping_cart,
      color: Colors.orange),
  BudgetCategory(
      id: 15,
      name: 'Others',
      icon: Icons.more_vert,
      color: Colors.deepPurpleAccent),
];


IconData getCategoryIconByName(String categoryName) {
  final category = budgetCategories.firstWhere(
        (cat) => cat.name == categoryName,
    orElse: () => BudgetCategory(
      id: 0,
      name: 'Default',
      icon: Icons.error_outline,
      color: Colors.grey,
    ),
  );
  return category.icon;
}


Color getCategoryColor(String categoryName) {
  final category = budgetCategories.firstWhere(
        (cat) => cat.name == categoryName,
    orElse: () => BudgetCategory(
      id: 0,
      name: 'Default',
      icon: Icons.error_outline,
      color: Colors.grey,
    ),
  );
  return category.color;
}
