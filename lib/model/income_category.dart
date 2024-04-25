import 'package:flutter/material.dart';

class IncomeCategory {
  final int id;
  final String name;
  final IconData icon;
  final Color color;


  IncomeCategory({required this.id, required this.name, required this.icon, required this.color});
}

final List<IncomeCategory> incomeCategories = [
  IncomeCategory(id: 1, name: 'Awards', icon: Icons.emoji_events, color: Colors.blueAccent),
  IncomeCategory(id: 2, name: 'Coupons', icon: Icons.card_giftcard, color: Colors.greenAccent),
  IncomeCategory(id: 3, name: 'Grants', icon: Icons.school, color: Colors.redAccent),
  IncomeCategory(id: 4, name: 'Lottery', icon: Icons.casino, color: Colors.deepOrange),
  IncomeCategory(id: 5, name: 'Refunds', icon: Icons.monetization_on, color: Colors.amber),
  IncomeCategory(id: 6, name: 'Rental', icon: Icons.house, color: Colors.purpleAccent),
  IncomeCategory(id: 7, name: 'Salary', icon: Icons.attach_money, color: Colors.green),
  IncomeCategory(id: 8, name: 'Sale', icon: Icons.point_of_sale, color: Colors.brown),
];



IconData getIncomeCategoryIconByName(String categoryName) {
  final category = incomeCategories.firstWhere(
        (cat) => cat.name == categoryName,
    orElse: () => IncomeCategory(
      id: 0,
      name: 'Default',
      icon: Icons.error_outline,
      color: Colors.grey,
    ),
  );
  return category.icon;
}


Color getIncomeCategoryColor(String categoryName) {
  final category = incomeCategories.firstWhere(
        (cat) => cat.name == categoryName,
    orElse: () => IncomeCategory(
      id: 0,
      name: 'Default',
      icon: Icons.error_outline,
      color: Colors.grey,
    ),
  );
  return category.color;
}

