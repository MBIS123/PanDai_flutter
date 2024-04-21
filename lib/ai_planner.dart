import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pandai_planner_flutter/savingPlan.dart';
import 'package:pandai_planner_flutter/services/api_service.dart';

import 'login.dart';
import 'main.dart';
import 'model/FinancialPlan.dart';

class SmartPlanningPage extends StatefulWidget {
  final String title;
  final int userId;

  const SmartPlanningPage({Key? key, required this.title, required this.userId})
      : super(key: key);

  @override
  State<SmartPlanningPage> createState() => _SmartPlanningPageState();
}

class _SmartPlanningPageState extends State<SmartPlanningPage> {
  List<FinancialPlan> financialPlans = []; // Assuming this list holds existing financial plans

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: financialPlans.isEmpty
          ? Center(
        child: Text(
          'There are no financial plans.\n Please create one.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18, // Set the font size to 20
            color: defaultColorScheme.primary, // Set the text color to the primary color from the default color scheme
          ),
        ),
      )
          : ListView.builder(
        itemCount: financialPlans.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(financialPlans[index].planCategory),
              subtitle: Text('Amount: \$${financialPlans[index].planAmount.toString()}'),
              // Add more details as needed
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => FinancialPlanPage()));
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class FinancialPlanPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.account_balance), // Icon for Saving Plan
              title: Text('Saving Plan'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SavingPlanPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.directions_car), // Icon for Buy Car
              title: Text('Buy Car'),
              onTap: () {
                Navigator.of(context).pop('Buy Car');
              },
            ),
            ListTile(
              leading: Icon(Icons.house), // Icon for Buy House
              title: Text('Buy House'),
              onTap: () {
                Navigator.of(context).pop('Buy House');
              },
            ),
            // Add more financial plan options as needed
          ],
        ),
      ),
    );
  }
}
