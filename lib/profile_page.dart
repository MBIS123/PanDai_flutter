import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String title;
  final int userId;

  const ProfilePage({Key? key, required this.title, required this.userId}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String customerName; // You will fetch or set this from your data source
  late double income; // You will fetch or set this from your data source
  late String financialStatus; // You will fetch or set this from your data source
  late String accountDetails; // You will fetch or set this from your data source

  @override
  void initState() {
    super.initState();
    // Initialize your variables here, maybe using data fetched from a database or API
    customerName = 'John Doe';
    income = 50000.0;
    financialStatus = 'Healthy';
    accountDetails = 'Premium Account';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50, // For the customer profile image
                backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image, replace with actual image URL
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  // Navigate to income details page
                  // Navigator.of(context).push();
                },
                child: Text(
                  customerName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(height: 32, thickness: 2),
              InformationTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Income',
                value: '\$${income.toStringAsFixed(2)}',
              ),
              InformationTile(
                icon: Icons.assessment_outlined,
                label: 'Financial Status',
                value: financialStatus,
              ),
              InformationTile(
                icon: Icons.account_circle_outlined,
                label: 'Account',
                value: accountDetails,
              ),
              InformationTile(
                icon: Icons.monetization_on_outlined,
                label: 'Other Income',
                value: accountDetails,
              ),
              // Divider to visually separate sections
              Divider(height: 32, thickness: 2),
              // Added Manage Categories section
              ListTile(
                leading: Icon(Icons.category_outlined),
                title: Text('Manage Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to Manage Categories Page
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // Start with a variable to hold the category name
                      String categoryName = '';

                      // The AlertDialog
                      return AlertDialog(
                        title: Text('Add new category'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              // Type toggle switch or segment control
                              // For simplicity, I'll just add text, you can replace it with a Toggle or SegmentControl
                              Text('Type: INCOME / EXPENSE'),

                              // TextField for the category name
                              TextField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Name',
                                ),
                                onChanged: (value) {
                                  categoryName = value; // update the category name
                                },
                              ),

                              // Icons wrap in a GridView or a horizontal ListView
                              // I'll show a simplified version using Wrap for layout
                              Wrap(
                                spacing: 8.0, // gap between adjacent chips
                                runSpacing: 4.0, // gap between lines
                                children: <Widget>[
                                  // ...Add your IconButtons or other widgets here...
                                  // Just an example icon to tap
                                  IconButton(
                                    icon: Icon(Icons.home),
                                    onPressed: () {
                                      // Set the selected icon for the category here
                                    },
                                  ),
                                  // Repeat for other icons...
                                ],
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('CANCEL'),
                            onPressed: () {
                              Navigator.of(context).pop(); // Dismiss the dialog
                            },
                          ),
                          TextButton(
                            child: Text('SAVE'),
                            onPressed: () {
                              // Save the new category here
                              // For example, call a setState and add the new category to a list
                              Navigator.of(context).pop(); // Dismiss the dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              // Added Logout button
              ElevatedButton(
                onPressed: () {
                  // Navigate back to login page
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('Logout'),
              ),
              // ... Add more information tiles as needed ...
            ],
          ),
        ),
      ),
    );
  }
}

class InformationTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InformationTile({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 28),
          SizedBox(width: 16),
          Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          Spacer(),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfilePage(title: 'Profile', userId: 123),
  ));
}
