import 'dart:convert';
import 'package:pandai_planner_flutter/utilities/bottomNavigationWidget.dart';

import 'user_Data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'model/budget_category.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pandai_planner_flutter/budget.dart';
import 'package:pandai_planner_flutter/home_page.dart';
import 'package:pandai_planner_flutter/register.dart';
import 'package:pandai_planner_flutter/transaction_page.dart';
import '../ai_planner.dart';
import '../profile_page.dart';

class TransactionPage extends StatefulWidget {
  final String title;
  final int userId;
  const TransactionPage({Key? key, required this.title, required this.userId})
      : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}




class _TransactionPageState extends State<TransactionPage> {

  String _selectedCategory = 'Select category';
  String _noteHeader='Write note';
  late DateTime _selectedDate;
  double _transactionAmount = 0.00;
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
        color: Colors.orange ),
  ];



  String getFormattedDate() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('MMMM, y');
    return formatter.format(now);
  }

  Color getCategoryColor(String categoryName) {
    final category = categories.firstWhere(
          (cat) => cat.name == categoryName,
      orElse: () => BudgetCategory(id: 0, name: 'Default', icon: Icons.error_outline, color: Colors.grey),
    );
    return category.color;
  }

  IconData getCategoryIconByName(String categoryName) {
    final category = categories.firstWhere(
          (cat) => cat.name == categoryName,
      orElse: () => BudgetCategory(id: 0, name: 'Default', icon: Icons.error_outline, color: Colors.grey),
    );
    return category.icon;
  }


  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      bottomNavigationBar: __BottomNavigationBar(userId: widget.userId),

      body: Column(
        children: <Widget>[
          ListTile(
            title: Text(_transactionAmount != null ? 'RM ${_transactionAmount.toStringAsFixed(2)}' : 'RM'),
            trailing: Icon(Icons.keyboard_arrow_down),
            onTap: _showCalculatorDialog,
          ),
          ListTile(
            title: Text(_selectedCategory),
            trailing: Icon(Icons.keyboard_arrow_down),
            onTap: _showCategoryDialog,
            leading: CircleAvatar(
              backgroundColor: getCategoryColor(_selectedCategory), // Get the color from the selected category
              child: Icon(getCategoryIconByName(_selectedCategory), color: Colors.white), // Get the icon from the selected category
            ),
          ),

          ListTile(
            title: Text(_noteHeader),
            trailing: Icon(Icons.edit),
            onTap: _showNoteDialog,
          ),
          ListTile(
            title: Text('Transaction date'),
            subtitle: Text('${DateFormat('MMMM dd, y').format(_selectedDate)}'),
            trailing: Icon(Icons.calendar_today),
            onTap: _showDatePicker,
          ),
          Container(
            alignment: Alignment.bottomCenter, // Aligns the button at the bottom center
            padding: EdgeInsets.all(16), // Optional padding for spacing
            child: ElevatedButton(
              onPressed: () async{
                try {
                  print("the transcation amount is:" + _transactionAmount.toString());
                  _createTransaction(
                      widget.userId, _transactionAmount, _selectedCategory,
                      _noteHeader.toString(), _selectedDate);
                  recordBudgetSpent(  widget.userId,  _selectedCategory,_selectedDate , _transactionAmount);
                }
                catch(error){
                }
              },
              child: Text('Save'),
            ),
          )
        ],
      ),
    );
  }


  Future<void> _createTransaction(
      int userId,
      double transactionAmount,
      String budgetCategory,
      String note,
      DateTime transactionDate
      ) async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/transaction/createTransaction'; // Replace with your actual endpoint URL
    print('Creating Transaction');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'transactionAmount': transactionAmount,
        'budgetCategory': budgetCategory,
        'note': note,
        'transactionDate': transactionDate.toIso8601String(), // Ensure backend accepts ISO 8601 string format
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle a successful response here
      print('Transaction created successfully');
      print('Response: ${response.body}');
      int userId = UserData().userId;
      final snackBar = SnackBar(
        content: Text('Transaction Recorded!'),
        duration: Duration(seconds: 2),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Navigate to the home page after a short delay
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          print("reloaded");
          _transactionAmount = 0.0; // Reset transaction amount
          _selectedCategory = 'Select category'; // Reset selected category
          _noteHeader = 'Write note'; // Reset note header
          _selectedDate = DateTime.now(); // Reset selected date
        });

      });
      setState(() {
      });
    } else {
      // Handle error or validation failures here
      print('Failed to create transaction. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }

  Future<void> recordBudgetSpent(
      int userId,
      String budgetCategory,
      DateTime budgetDate,
      double budgetSpent
      ) async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/budget/recordBudgetSpent'; // Update with your actual endpoint URL
    print('Recording Budget Spent');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'budgetCategory': budgetCategory,
        'budgetDate': budgetDate.toIso8601String(), // Format date to ISO 8601 string
        'budgetSpent': budgetSpent,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Budget spent recorded successfully');
      print('Response: ${response.body}');

    } else {
      print('Failed to record budget spent. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }


  void _showCalculatorDialog() {
    TextEditingController _transactionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Create a TextEditingController to capture the input from the TextField
        return AlertDialog(
          title: Text('Create Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _transactionController,
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
              child: Text('Confirm'),
              onPressed: () {
                print('Transaction set to: ${_transactionController.text}');
            // Fallback to 0.0 if parsing fails

                setState(() {
                  _transactionAmount = double.tryParse(_transactionController.text) ??
                      0.0; // Fallback to 0.0 if parsing fails
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Category'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var category = categories[index];
                return ListTile(
                  title: Text(category.name),
                  leading: CircleAvatar(
                    backgroundColor: category.color,
                    child: Icon(
                      category.icon,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category.name;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showNoteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Write note'),
          content: TextField(
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  _noteHeader = value;
                });
              }
            },
            decoration: InputDecoration(hintText: "Enter your note here"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDatePicker(){
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((date) {
      if (date != null && date != _selectedDate) {
        setState(() {
          _selectedDate = date;
        } );
      }
    });
  }




}



class __BottomNavigationBar extends StatefulWidget {
  final int userId;

  const __BottomNavigationBar({Key? key, required this.userId}) : super(key: key);

  @override
  State<__BottomNavigationBar> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<__BottomNavigationBar> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Index 0: Home'),
    Text('Index 1: Budget'),
    Text('Index 2: Transaction'),
    Text('Index 3: Smart Plan'),
    Text('Index 4: Account'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(

      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.wallet_giftcard),
          label: 'Budget',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Transaction',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance),
          label: 'Smart Plan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts),
          label: 'Account',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }




}
