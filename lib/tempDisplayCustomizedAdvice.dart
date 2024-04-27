import 'package:flutter/material.dart';

class TempAdvice extends StatelessWidget {
  final String assessment;
  final String financialAdvice;
  final String successbilityScore;
  final String budgetExpenseAdjustment;

  const TempAdvice({
    Key? key,
    required this.assessment,
    required this.financialAdvice,
    required this.successbilityScore,
    required this.budgetExpenseAdjustment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Advice'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSection('Achievability Score (0-100)', successbilityScore, Icons.score, Colors.orange),
              Divider(),
              _buildSection('Assessment', assessment, Icons.assessment, Colors.blue),
              Divider(),
              _buildSection('Financial Adjustment', budgetExpenseAdjustment, Icons.compare_arrows, Colors.pinkAccent),
              Divider(),
              _buildSection('Financial Advice', financialAdvice, Icons.attach_money, Colors.green),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData iconData, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: Icon(
            iconData,
            color: iconColor,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 18,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
