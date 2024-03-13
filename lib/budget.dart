import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'model/budget_category.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _formKey = GlobalKey<FormState>();

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

  void showSetBudgetDialog(BuildContext context, BudgetCategory category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Create a TextEditingController to capture the input from the TextField
        TextEditingController _budgetController = TextEditingController();
        String formattedDate = getFormattedDate(); // Call the method here

        return AlertDialog(
          title: Text('Create Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8),
                constraints: BoxConstraints(
                  minWidth: 250, // Minimum width of the box
                  minHeight: 50, // Minimum height of the box
                ),
                // Add some padding inside the box
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    // Choose the color for your box
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: Colors.grey) // Define the border color and width
                    ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  // Use min to avoid extra space
                  children: [
                    Icon(category.icon),
                    // Your face icon
                    SizedBox(width: 50),
                    // Space between the icon and text
                    Text('${category.name}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),

              TextField(
                controller: _budgetController,
                decoration: InputDecoration(
                  labelText: 'Limit',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 20, width: 20),
              Text(formattedDate)
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
              child: Text('SET'),
              onPressed: () {
                // TODO: Handle the budget setting logic
                print('Budget set to: ${_budgetController.text}');
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendUserData(
      String email, String password, String firstName, String lastName) async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/users/register';
    // Replace with your Spring Boot API endpoint URL
    print('Creating Budget');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,

      }),
    );

    if (response.statusCode == 201) {
      // Handle a successful response here
      print('register successful');
      print('Response: ${response.body}');
      Navigator.pushReplacementNamed(context, '/homePage');

      final snackBar = SnackBar(
        content: Text('Registration successful!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Navigate to the home page after a short delay
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/homePage');
      });
    } else {
      // Handle error or validation failures here
      print('Failed to register in. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }

  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('MMMM, y');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        var category = categories[index];
        return ListTile(
          leading: Icon(
            category.icon,
            color: category.color,
          ),
          title: Text(
            category.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          trailing: ElevatedButton(
            onPressed: () => showSetBudgetDialog(context, category),
            child: Text('Set Budget'),
          ),
        );
      },
    );
  }
}
