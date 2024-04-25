import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pandai_planner_flutter/model/income_category.dart';

import 'model/income.dart';



class ManageIncome extends StatefulWidget {
  final String title;
  final int userId;

  ManageIncome({
    Key? key,
    required this.title,
    required this.userId,
  }) : super(key: key);

  @override
  _ManageIncomeState createState() => _ManageIncomeState();
}



class _ManageIncomeState extends State<ManageIncome> {
  List<Income> incomeList = [];


  @override
  void initState() {
    super.initState();
    _fetchIncomeData();
  }

  Future<void> _fetchIncomeData() async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/income/getAllIncome?userId=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          incomeList = data.map((item) => Income.fromJson(item)).toList();
        });
      } else {
        print('Failed to fetch income data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching income data: $error');
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.attach_money,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 8), // Add spacing between icon and title
            Text(
              widget.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),

      body: ListView.builder(
        itemCount: incomeCategories.length,
        itemBuilder: (context, index) {
          final category = incomeCategories[index];
          final income = incomeList.firstWhere((income) => income.incomeType == category.name, orElse: () => new Income( incomeType: "",amount: 0.00));
          final amountText = income != null ? 'RM${income.amount.toStringAsFixed(2)}' : '0.00';

          return ListTile(
            leading: Icon(
              category.icon,
              color: category.color,
            ),
            title: Text(category.name , style: TextStyle( fontWeight: FontWeight.bold ,
                fontSize: 16),),
            subtitle: Text('Amount: $amountText', style: TextStyle( fontWeight: FontWeight.bold ,
                fontSize: 16),),
            trailing: ElevatedButton(
              onPressed: () {
                _showAddIncomeDialog(context, category, widget.userId);
              },
              child: Text('Add Income'),
            ),
          );
        },
      ),


    );
  }

  Future<void> _createIncome(BuildContext context, int userId, String incomeType, double? incomeAmount) async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/income/createIncome';
    // Replace with your Spring Boot API endpoint URL
    print('Creating Income');
    final response = await http.post(
      Uri.parse('$apiUrl?userId=${userId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'incomeType': incomeType,
        'amount': incomeAmount,
      }),
    );

    if (response.statusCode == 200) {
      // Handle a successful response here
      print('create income successful');
      print('Response: ${response.body}');

      final snackBar = SnackBar(
        content: Text('Income recorded successfully!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Navigate to the home page after a short delay
      Future.delayed(Duration(seconds: 2), () {
        // Navigate to the home page or perform any other action here
      });
    } else {
      // Handle error or validation failures here
      print("The userid:" +userId.toString());
      print('Failed to create income. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }

  void _showAddIncomeDialog(BuildContext context, IncomeCategory category, int userId) {
    double? income = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Income for ${category.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Enter income amount',
                ),
                onChanged: (value) {
                  income = double.tryParse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (income != null) {
                  print("income:" + income.toString());
                  await _createIncome(context, userId, category.name, income);
                  _fetchIncomeData(); // Refresh income data after adding
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
