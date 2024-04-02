import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'model/budget_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'model/budget_info.dart'; // Import services for TextInputFormatter

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key, required this.title, required this.userId})
      : super(key: key);
  final String title;
  final int userId;

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _formKey = GlobalKey<FormState>();
  late final int actualUserId = widget.userId;
  List<BudgetInfo> budgetInfoList = []; // Initialize as an empty list
  late BudgetInfo? budgetInfo;

  @override
  void initState() {
    super.initState();
    _fetchBudgetData();
  }

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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
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
                print('Budget set to: ${_budgetController.text}');
                double budgetLimit = double.tryParse(_budgetController.text) ??
                    0.0; // Fallback to 0.0 if parsing fails

                DateTime budgetDate = DateTime.now();

                String budgetCategory = category.name;
                print('UserID:' + widget.userId.toString());
                _createBudget(
                    widget.userId, budgetLimit, budgetCategory, budgetDate);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createBudget(int userId, double budgetLimit,
      String budgetCategory, DateTime budgetDate) async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/budget/createBudget';
    // Replace with your Spring Boot API endpoint URL
    print('Creating Budget');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'budgetLimit': budgetLimit,
        'budgetCategory': budgetCategory,
        'budgetDate': budgetDate.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      // Handle a successful response here
      print('create budget successful');
      print('Response: ${response.body}');
      Navigator.pushReplacementNamed(context, '/BudgetPage');

      final snackBar = SnackBar(
        content: Text('Created budget successful!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Navigate to the home page after a short delay
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/homePage');
      });
    } else {
      // Handle error or validation failures here
      print('Failed to create budget. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }

  String getFormattedDate() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('MMMM, y');
    return formatter.format(now);
  }

  // Future<void> _fetchBudgetData() async {
  //   DateTime budgetDate = DateTime.now();
  //
  //   final String apiUrl =
  //       'http://10.0.2.2:8080/api/v1/budget/budgetCurrentMonth'; // Adjust with your actual API URL
  //   final response = await http.get(
  //     Uri.parse('$apiUrl?userId=${widget.userId}'),
  //     // Example category
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //   );
  //
  //   if (response.statusCode == 200 || response.statusCode == 201 ) {
  //     print('response reeceived successfyully');
  //     setState(() {
  //       budgetInfo = BudgetInfo.fromJson(jsonDecode(response.body));
  //     });
  //   } else {
  //     print('Failed to load budgetjhkjkh. Status code: ${response.statusCode} Status message: ${response.body}');
  //   }
  // }
  Future<void> _fetchBudgetData() async {
    final String apiUrl =
        'http://10.0.2.2:8080/api/v1/budget/budgetCurrentMonth';
    final response = await http.get(
      Uri.parse('$apiUrl?userId=${widget.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      List<BudgetInfo> budgetList = jsonResponse
          .map((budgetJson) => BudgetInfo.fromJson(budgetJson))
          .toList();
      setState(() {
        budgetInfoList = budgetList;
      });
    } else {
      print('Failed to load budget. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (budgetInfoList == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Handle action (e.g., navigate to a new budget entry page)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      'Budget Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Replace with actual budget data
                    Text(
//                      'Total Budget: \$${budgetInfo?.budgetLimit ?? 'N/A'}',
                      'Total Budget: \$ 500',

                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    Text(
//                      'Total Budget: \$${budgetInfo?.budgetLimit ?? 'N/A'}',
                      'Total Budget: \$ 500',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    LinearProgressIndicator(
                      value: ( 0) /
                          ( 1),
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Expanded(
          //   child: ListView.builder(
          //     itemCount: categories.length,
          //     itemBuilder: (context, index) {
          //       var category = categories[index];
          //       return Card(
          //         margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          //         child: Column(
          //           children: [
          //             ListTile(
          //               leading: CircleAvatar(
          //                 backgroundColor: category.color,
          //                 child: Icon(
          //                   category.icon,
          //                   color: Colors.white,
          //                 ),
          //               ),
          //               title: Text(
          //                 category.name,
          //                 style: TextStyle(fontWeight: FontWeight.bold),
          //               ),
          //               subtitle: Text('Spent this month: \$200'),
          //               // Replace with actual data
          //               trailing: ElevatedButton(
          //                 onPressed: () =>
          //                     showSetBudgetDialog(context, category),
          //                 child: Text('Set Budget'),
          //               ),
          //             ),
          //             Padding(
          //               padding: EdgeInsets.symmetric(horizontal: 16.0),
          //               child: LinearProgressIndicator(
          //                 value: 1 / 500,
          //                 // This is an example, replace with actual data
          //                 backgroundColor: Colors.grey[300],
          //                 color: Colors.blue,
          //               ),
          //             ),
          //             SizedBox(height: 8),
          //             // For some spacing after the progress bar
          //           ],
          //         ),
          //       );
          //     },
          //   ),
          // ), // original one

          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var category = categories[index];

                BudgetInfo defaultBudgetInfo = BudgetInfo(
                  budgetLimit: 0, // Default value for budget limit
                  budgetSpent: 0, // Default value for budget spent
                  budgetCategory: category.name, // Use the category name from the current iteration
                );

                BudgetInfo matchingBudget = budgetInfoList.firstWhere(
                      (budgetInfo) => budgetInfo.budgetCategory == category.name,
                  orElse: () => defaultBudgetInfo, // Return the default object if no match is found
                );




                // Define budget text based on whether a matching budget was found
                String budgetText = matchingBudget != null
                    ? 'Limit: \$${matchingBudget.budgetLimit.toStringAsFixed(2)} Spent: \$${matchingBudget.budgetSpent.toStringAsFixed(2)}'
                    : 'No budget set';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: category.color,
                          child: Icon(
                            category.icon,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(budgetText), // Use the budgetText here
                        trailing: ElevatedButton(
                          onPressed: () => showSetBudgetDialog(context, category),
                          child: Text('Set Budget'),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: LinearProgressIndicator(
                          value: matchingBudget.budgetLimit > 0
                              ? matchingBudget.budgetSpent / matchingBudget.budgetLimit
                              : 0, // Fallback to 0 if the budgetLimit is 0 to avoid division by zero
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                        ),

                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ),


          // Expanded(
          //   child: ListView.builder(
          //     itemCount: budgetInfoList.length, // Use the length of budgetInfoList
          //     itemBuilder: (context, index) {
          //       var budgetInfo = budgetInfoList[index]; // Get current BudgetInfo
          //       return Card(
          //         margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          //         child: Column(
          //           children: [
          //             ListTile(
          //               leading: CircleAvatar(
          //                 backgroundColor: Colors.grey, // Consider dynamic color or icons based on category
          //                 child: Text("\$"), // Placeholder icon, consider changing based on category
          //               ),
          //               title: Text(
          //                 budgetInfo.budgetCategory, // Display the budget category
          //                 style: TextStyle(fontWeight: FontWeight.bold),
          //               ),
          //               subtitle: Text('Limit: \$${budgetInfo.budgetLimit.toStringAsFixed(2)}'), // Display the budget limit
          //               trailing: Text(
          //                 'Spent: \$${budgetInfo.budgetSpent.toStringAsFixed(2)}', // Display the budget spent
          //               ),
          //             ),
          //             Padding(
          //               padding: EdgeInsets.symmetric(horizontal: 16.0),
          //               child: LinearProgressIndicator(
          //                 value: budgetInfo.budgetSpent / budgetInfo.budgetLimit, // Calculate progress
          //                 backgroundColor: Colors.grey[300],
          //                 color: Colors.blue, // Consider changing color based on progress
          //               ),
          //             ),
          //             SizedBox(height: 8),
          //           ],
          //         ),
          //       );
          //     },
          //   ),
          // ),


        ],
      ),
    );
  }
}
