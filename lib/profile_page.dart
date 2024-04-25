import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pandai_planner_flutter/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pandai_planner_flutter/manage_incomes.dart';
import 'package:http/http.dart' as http;
import 'model/income.dart';
import 'model/user.dart';

class ProfilePage extends StatefulWidget {
  final String title;
  final int userId;
  const ProfilePage({Key? key, required this.title, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String customerName=""; // You will fetch or set this from your data source
  late double income; // You will fetch or set this from your data source
  late double expenses; // You will fetch or set this from your data source
  late String financialStatus; // You will fetch or set this from your data source
  late String accountDetails; // You will fetch or set this from your data source
  double totalBudget = 0;
  final storage = FlutterSecureStorage();
  List<Income> incomeList = [];


  @override
  void initState() {
    super.initState();
    _fetchUserData(widget.userId);
    _fetchIncomeData();
    _fetchBudgetData();
    income = 50000.0;
    financialStatus = 'Healthy';
    accountDetails = 'Premium Account';
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.person,
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

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showEditNameDialog(widget.userId);
                      },
                      child: Text(
                        customerName,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showEditNameDialog(widget.userId);
                    },
                  ),
                ],
              ),
              Divider(height: 32, thickness: 2),
              InformationTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Total Income',
                value: 'RM${income.toStringAsFixed(2)}',
                iconColor: Colors.green,
              ),
              InformationTile(
                icon: Icons.monetization_on_outlined,
                label: 'Current Month Expenses ',
                value: 'RM'+totalBudget.toString(),
                iconColor: Color(0xffCF6679),
              ),
              InformationTile(
                icon: Icons.assessment_outlined,
                label: 'Financial Status',
                value: financialStatus,
                iconColor: Colors.blue,
              ),
              InformationTile(
                icon: Icons.account_circle_outlined,
                label: 'Account',
                value: accountDetails,
                iconColor: Colors.orange,
              ),

              Divider(height: 32, thickness: 2),
              ListTile(
                leading: Icon(Icons.category_outlined, color: Colors.red),
                title: Text('Manage Monthly Incomes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ManageIncome(
                        title: 'Manage Monthly Income',
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
              ),
              // Added Logout button
              ElevatedButton(
                onPressed: () async {
                  print('Logging out...');

                  // Delete stored credentials
                  await storage.delete(key: 'email');
                  await storage.delete(key: 'password');

                  // Navigate back to the login page and clear the navigation stack
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => LoginPage(
                      title: widget.title,
                    ),
                  ));
                },
                child: Text('LogOut'),
              ),
              // ... Add more information tiles as needed ...
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchBudgetData() async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/budget/budgetCurrentMonth?userId=${widget.userId}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        String responseBody = response.body;
        List<dynamic> jsonResponse = jsonDecode(responseBody);
        double newTotalBudget = 0;
        Map<String, double> newCategorySpending = {};

        for (var data in jsonResponse) {
          double budgetLimit = (data['budgetLimit'] ?? 00).toDouble();
          double budgetSpent = (data['budgetSpent'] ?? 00).toDouble();
          newTotalBudget += budgetLimit;
          newCategorySpending[data['budgetCategory']] = budgetSpent;
        }
        setState(() {
          totalBudget = newTotalBudget;
        });
      } else {
        throw Exception('Failed to load budget data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  Future<void> _fetchIncomeData() async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/income/getAllIncome?userId=${widget.userId}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          incomeList = data.map((item) => Income.fromJson(item)).toList();
          // Calculate total income
          income = incomeList.map((income) => income.amount).fold(0, (prev, amount) => prev + amount);
        });
      } else {
        print('Failed to fetch income data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching income data: $error');
    }
  }



  Future<void> _updateUserName(int userId, String newUsername) async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/users/updateUserName'; // Replace with your Spring Boot API endpoint URL
    print('Updating username...');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id': userId,
        'name': newUsername,
      }),
    );
    print('Response status code: ${response.statusCode}');

    if (response.statusCode == 201) {
      // Handle a successful response here
      print('Username updated successfully');
      print('Response: ${response.body}');
    } else {
      // Handle error or validation failures here
      print('Failed to update username. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }
  Future<void> _fetchUserData(int userId) async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/users/currentUser';

    final response = await http.get(
      Uri.parse('$apiUrl?userId=${widget.userId}'),      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      User user = User.fromJson(jsonResponse);

      setState(() {
        customerName = user.name;
      });
      print("user name is" + customerName);
    } else if (response.statusCode == 404) {
      print('User not found.');
      return null;
    } else {
      print('Failed to load user data. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
      return null;
    }
  }




  Future<void> _showEditNameDialog( int userId) async {
    String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String editedName = customerName;
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(
            onChanged: (value) {
              editedName = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter new name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateUserName(userId, editedName);
                Navigator.of(context).pop(editedName);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName != customerName) {
      setState(() {
        customerName = newName;
      });
    }
  }
}

class InformationTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const InformationTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 28,
            color: iconColor,
          ),
          SizedBox(width: 16),
          Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Spacer(),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}