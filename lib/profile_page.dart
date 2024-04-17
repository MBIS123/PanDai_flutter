import 'package:flutter/cupertino.dart';
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
              Text(
                customerName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
