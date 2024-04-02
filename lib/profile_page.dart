import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'login.dart';

class ProfilePage extends StatefulWidget {
  final String title;
  final int userId;

  const ProfilePage({Key? key, required this.title, required this.userId }) : super(key: key); // Provide a default value for userId

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  var rememberValue = false;
  late final int actualUserId = widget.userId;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget Analysis',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Total Budget: \$5000'),
                      Text('Total Spent: \$3500'),
                      SizedBox(height: 8),
                      AspectRatio(
                        aspectRatio: 1.7,
                        child: BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(show: false),
                            barGroups: [
                              // x = budget category
                              BarChartGroupData(x: 0, barRods: [BarChartRodData(y:2)]),
                              BarChartGroupData(x: 1, barRods: [BarChartRodData(y: 6)]),
                              BarChartGroupData(x: 2, barRods: [BarChartRodData(y: 5.5)]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Analysis',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Total Transactions: 120'),
                      Text('Highest Transaction: \$1500'),
                      SizedBox(height: 8),
                      AspectRatio(
                        aspectRatio: 1.7,
                        child: LineChart(
                          // Placeholder for your LineChart, replace with your actual data
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  // daily transaction
                                  FlSpot(0, 3),
                                  FlSpot(2.6, 2),
                                  FlSpot(4.9, 5),
                                  FlSpot(6.8, 2.5),
                                  // Add more spots as needed
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Add more cards/analysis as needed
          ],
        ),
      ),
    );
  }
}

