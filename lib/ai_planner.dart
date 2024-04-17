import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pandai_planner_flutter/services/api_service.dart';

import 'login.dart';

class SmartPlanningPage extends StatefulWidget {
  final String title;
  final int userId;

  const SmartPlanningPage({Key? key, required this.title, required this.userId})
      : super(key: key);

  @override
  State<SmartPlanningPage> createState() => _SmartPlanningPageState();
}

class _SmartPlanningPageState extends State<SmartPlanningPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Pushes a new route onto the stack that will display the NewPage widget.
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => NewPage()));
            try {
              ApiService.postUserFinancialData();


            } catch (error) {
              print("errors $error");
            }
          },
          child: Text('Go to New Page'),
        ),
      ),
    );
  }
}

class NewPage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter new text'),
            ),
            ElevatedButton(
              onPressed: () {
                // Use the controller to retrieve the text and pop it back to the previous page.
                Navigator.of(context).pop(_controller.text);
              },
              child: Text('Completed'),
            ),
          ],
        ),
      ),
    );
  }
}
