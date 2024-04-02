import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'model/budget_category.dart';


class TransactionPage extends StatefulWidget {
  final String title;
  final int userId;


  const TransactionPage({Key? key, required this.title,required this.userId}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String _selectedCategory = 'Select category';
  String _note = '';
  DateTime _selectedDate = DateTime.now();

  final List<BudgetCategory> categories = [
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
  ];


  String getFormattedDate() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('MMMM, y');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('MYR'),
            trailing: Icon(Icons.keyboard_arrow_down),
            onTap: _showCalculatorDialog,
          ),
          ListTile(
            title: Text(_selectedCategory),
            trailing: Icon(Icons.keyboard_arrow_down),
            onTap: _showCategoryDialog,
          ),
          ListTile(
            title: Text('Write note'),
            trailing: Icon(Icons.edit),
            onTap: _showNoteDialog,
          ),
          ListTile(
            title: Text('Today'),
            subtitle: Text('${getFormattedDate()}'),
            trailing: Icon(Icons.calendar_today),
            onTap: _showDatePicker,
          ),
          // ... Additional UI elements ...
        ],
      ),
    );
  }

  void _showCalculatorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Create a TextEditingController to capture the input from the TextField
        TextEditingController _budgetController = TextEditingController();

        return AlertDialog(
          title: Text('Create Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[

              TextField(
                controller: _budgetController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              SizedBox(height: 20, width: 20),

              // Add any other input fields or widgets you need
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                print('Transaction set to: ${_budgetController.text}');
                double budgetLimit = double.tryParse(_budgetController.text) ??
                    0.0; // Fallback to 0.0 if parsing fails
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );


  }

  void _showCategoryDialog() {
    // TODO: Implement category selection dialog
  }

  void _showNoteDialog() {
    // Show dialog for text input
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Write note'),
          content: TextField(
            onChanged: (value) {

              if(mounted){
                setState(() {
                  _note = value;
                });
              }





              },
            decoration: InputDecoration(hintText: "Enter your note here"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDatePicker() {
    // Show date picker dialog
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((date) {
      if (date != null && date != _selectedDate) {
        setState(() {
          _selectedDate = date;
        });
      }
    });
  }
}
