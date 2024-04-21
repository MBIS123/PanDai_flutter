import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'model/budget_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'model/budget_info.dart'; // Import services for TextInputFormatter
import 'package:flutter/material.dart';
class MonthSwitcher extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onMonthChanged;

  const MonthSwitcher({
    Key? key,
    required this.initialDate,
    required this.onMonthChanged,
  }) : super(key: key);

  @override
  _MonthSwitcherState createState() => _MonthSwitcherState();
}

class _MonthSwitcherState extends State<MonthSwitcher> {
  late DateTime currentDate;

  @override
  void initState() {
    super.initState();
    currentDate = widget.initialDate;
  }

  void _nextMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
      widget.onMonthChanged(currentDate);
    });
  }

  void _previousMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month - 1, 1);
      widget.onMonthChanged(currentDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _previousMonth,
        ),
        Text(
          DateFormat('MMMM yyyy').format(currentDate),
          style: Theme.of(context).textTheme.headline6,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: _nextMonth,
        ),
      ],
    );
  }
}






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
  String _searchQuery = '';
  TextEditingController _monthController = TextEditingController();
  late double totalBudgetSpent = 0.00;
  late double totalBudgetLimit =0.00;
  DateTime selectedMonth = DateTime.now();



  @override
  void initState() {
    super.initState();
    _fetchBudgetData(selectedMonth);

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
    BudgetCategory(
        id: 15,
        name: 'Others',
        icon: Icons.more_vert,
        color: Colors.deepPurpleAccent),
  ];

  List<BudgetCategory> getFilteredBudgetInfo() {
    var filtered = categories
        .where((budgetCat) => budgetCat.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    List<BudgetCategory> filled = [];
    List<BudgetCategory> unfilled = [];

    for (var category in filtered) {
      var hasBudget = budgetInfoList.any((info) =>
      info.budgetCategory == category.name && info.budgetLimit > 0);
      if (hasBudget) {
        filled.add(category);
      } else {
        unfilled.add(category);
      }
    }

    return filled + unfilled; // Concatenate filled first, then unfilled
  }

  void showSetBudgetDialog(BuildContext context, BudgetCategory category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              onPressed: () async {
                try {
                  print('Budget set to: ${_budgetController.text}');
                  double budgetLimit = double.tryParse(_budgetController.text) ?? 0.0; // Fallback to 0.0 if parsing fails
                  print('Budget set to:' + budgetLimit.toString());

                  DateTime budgetDate = DateTime.now();
                  String budgetCategory = category.name;
                  print('UserID: ' + widget.userId.toString());

                  // Attempt to create the budget and refresh data
                  await _createBudget(widget.userId, budgetLimit, budgetCategory, budgetDate);
                  await _fetchBudgetData(selectedMonth);

                  // Use setState to trigger the UI update
                  setState(() {
                    print("doing refreshing");
                  });
                } catch (error) {
                  // Handle any errors here
                  print('An error occurred: $error');
                } finally {
                  // This block will execute no matter what and ensure the dialog is closed
                  Navigator.of(context).pop(); // Close the dialog
                }
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

      final snackBar = SnackBar(
        content: Text('Updated budget successfully!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Navigate to the home page after a short delay
      Future.delayed(Duration(seconds: 2), () {
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

  Future<void> _fetchBudgetData(DateTime month) async {
    final String apiUrl =
        'http://10.0.2.2:8080/api/v1/budget/budgetCurrentMonth';

    // Extract year and month from the DateTime object
    int year = month.year;
    int monthNumber = month.month;

    final response = await http.get(
      Uri.parse('$apiUrl?userId=${widget.userId}&year=$year&month=$monthNumber'),
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
        totalBudgetLimit = budgetList.fold(0.0, (sum, item) => sum + item.budgetLimit);
        totalBudgetSpent = budgetList.fold(0.0, (sum, item) => sum + item.budgetSpent);
      });
    } else {
      print('Failed to load budget. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }






  @override
  Widget build(BuildContext context) {
    List<BudgetCategory> filteredBudgetInfo = getFilteredBudgetInfo();
    bool foundUnfilled = false;

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
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          MonthSwitcher(
            initialDate: selectedMonth,
            onMonthChanged: (DateTime newMonth) {
              setState(() {
                selectedMonth = newMonth;
              });
              _fetchBudgetData(selectedMonth);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Reduced vertical padding
            child: TextField(
              decoration: InputDecoration(
                isDense: true, // Added to reduce the height
                contentPadding: EdgeInsets.fromLTRB(12, 10, 12, 10), // Adjusted padding, less than the defaults
                labelText: 'Search Budget Category',
                hintText: 'Enter budget name',
                prefixIcon: Icon(Icons.search, size: 20), // You can also reduce the icon size if needed
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),


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
                      'Total Budget: RM${totalBudgetLimit}',

                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    Text(
//                      'Total Budget: \$${budgetInfo?.budgetLimit ?? 'N/A'}',
                      'Total Budget Spend: RM${totalBudgetSpent}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    LinearProgressIndicator(
                      value: (0) / (1),
                      backgroundColor: Colors.grey[300],
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ),


          Expanded(
            child: ListView.builder(
              itemCount: filteredBudgetInfo.length,
              itemBuilder: (context, index) {
                var category = filteredBudgetInfo[index];
                BudgetInfo defaultBudgetInfo = BudgetInfo(
                  budgetLimit: 0,  // Default value for budget limit
                  budgetSpent: 0,  // Default value for budget spent
                  budgetCategory: category.name,
                );

                BudgetInfo matchingBudget = budgetInfoList.firstWhere(
                      (info) => info.budgetCategory == category.name,
                  orElse: () => defaultBudgetInfo,
                );

                bool isFilled = matchingBudget.budgetLimit > 0;
                if (!isFilled && !foundUnfilled) {
                  foundUnfilled = true; // We've now found the first unfilled item
                  return Column(
                    children: [
                      SizedBox(height: 20),
                      Divider(height: 40, thickness: 2, color: Colors.grey),

                      Text('Unassigned Budget Categories', style: TextStyle(color: Colors.purple, fontSize: 16)),
                      SizedBox(height: 20),
                      budgetCategoryItem(matchingBudget, category),
                    ],
                  );
                }
                return budgetCategoryItem(matchingBudget, category);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget budgetCategoryItem(BudgetInfo matchingBudget, BudgetCategory category) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: category.color,
              child: Icon(category.icon, color: Colors.white),
            ),
            title: Text(category.name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: matchingBudget.budgetLimit > 0 ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 14.0, color: Colors.white),
                    children: [
                      TextSpan(text: 'Limit: \$${matchingBudget.budgetLimit.toStringAsFixed(2)}\n'),
                      TextSpan(text: 'Spent: \$${matchingBudget.budgetSpent.toStringAsFixed(2)}', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                if (matchingBudget.budgetSpent > matchingBudget.budgetLimit)
                  Text('Overspent', style: TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ) : Text('No budget set'),
            trailing: ElevatedButton(
              onPressed: () => showSetBudgetDialog(context, category),
              child: Text('Set Budget'),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: LinearProgressIndicator(
              value: matchingBudget.budgetLimit > 0 ? matchingBudget.budgetSpent / matchingBudget.budgetLimit : 0,
              backgroundColor: Colors.grey[300],
              color: matchingBudget.budgetSpent > matchingBudget.budgetLimit ? Colors.red : Colors.blue,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }



}
