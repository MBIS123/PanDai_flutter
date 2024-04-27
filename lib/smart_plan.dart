import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pandai_planner_flutter/input_customized_saving_plan.dart';
import 'package:pandai_planner_flutter/input_sratch_saving_plan.dart';
import 'package:pandai_planner_flutter/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:pandai_planner_flutter/tempDisplayCustomizedAdvice.dart';
import 'package:pandai_planner_flutter/tempDisplayScratchAdvice.dart';

import 'login.dart';
import 'main.dart';
import 'model/financial_plan.dart';

class SmartPlanningPage extends StatefulWidget {
  final String title;
  final int userId;



  const SmartPlanningPage({Key? key, required this.title, required this.userId})
      : super(key: key);

  @override
  State<SmartPlanningPage> createState() => _SmartPlanningPageState();
}

class _SmartPlanningPageState extends State<SmartPlanningPage> {
  List<FinancialPlan> financialPlans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFinancialPlan();
  }


  Future<void> _fetchFinancialPlan() async {
    final String apiUrl =
        'http://10.0.2.2:8080/api/v1/financialPlan/getFinancialPlanInfo';
    final response = await http.get(
      Uri.parse(
          '$apiUrl?userId=${widget.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print("fetching the financialplan");


    if (response.statusCode == 200 || response.statusCode == 201) {
      print("fetching DAPSSS financialplan");

      List<dynamic> jsonResponse = jsonDecode(response.body);
      print('JSON response: $jsonResponse'); // Add this line to print JSON response for debugging

      List<FinancialPlan> financialPlanList = jsonResponse
          .map((transactionJson) => FinancialPlan.fromJson(transactionJson))
          .toList();
      setState(() {
        financialPlans = financialPlanList;
        print("had fetch the financialplan");
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load financial plan. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }

  Future<void> _deleteFinancialPlan(int financialPlanId) async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/financialPlan/deleteFinancialPlan/$financialPlanId';
    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print("Financial plan with ID $financialPlanId has been deleted successfully.");
      // Perform any additional actions upon successful deletion if needed
    } else {
      print('Failed to delete financial plan with ID $financialPlanId. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
      // Handle error scenario
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
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

      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : financialPlans.isEmpty
          ? Center(
        child: Text(
          'There are no financial plans.\nPlease create one.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18, // Set the font size to 20
            color: Theme.of(context).colorScheme.primary, // Set the text color to the primary color from the default color scheme
          ),
        ),
      )
          : ListView.builder(
        itemCount: financialPlans.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: UniqueKey(), // Key to identify the item being dismissed
            direction: DismissDirection.startToEnd, // Swipe direction
            confirmDismiss: (DismissDirection direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Confirm"),
                    content: Text("Are you sure you want to delete this financial plan?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("CANCEL"),
                      ),
                      TextButton(
                        onPressed: () {
                          _deleteFinancialPlan(financialPlans[index].financialPlanId);
                          Navigator.of(context).pop(true);
                        },
                        child: Text("DELETE"),
                      ),

                    ],
                  );
                },
              );
            },
            onDismissed: (direction) {
              // Remove the item from the data source
              setState(() {
                financialPlans.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Financial plan deleted")),
              );
            },
            background: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20.0),
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: GestureDetector(
              onTap: () {
                if ( financialPlans[index].financialAdjustment == "None"
                ){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TempAdvice(
                        assessment: financialPlans[index].assessment,
                        financialAdvice: financialPlans[index].financialAdvice,
                        successbilityScore: financialPlans[index].successScore,
                        budgetExpenseAdjustment: financialPlans[index].financialAdjustment,
                      ),
                    ),
                  ).then((_) {
                    _fetchFinancialPlan(); // Call _fetchFinancialPlan() after TempAdvice page is popped
                  });


                }
                else{
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TempAdviceScratch(
                        assessment: financialPlans[index].assessment,
                        financialAdvice: financialPlans[index].financialAdvice,
                        successbilityScore: financialPlans[index].successScore,
                      ),
                    ),
                  ).then((_) {
                    _fetchFinancialPlan(); // Call _fetchFinancialPlan() after TempAdvice page is popped
                  });
                }



              },
              child: Card(
                margin: EdgeInsets.all(8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Color(0xff4b4848),
                child: ListTile(
                  title: Text(
                    financialPlans[index].planName,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.monetization_on, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Saving Target: \$${financialPlans[index].targetAmount.toString()}',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Creation Date: ${DateFormat('yyyy-MM-dd').format(financialPlans[index].createPlanDate)}',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.assessment, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Success Rate: ${financialPlans[index].successScore.toString()}',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          );

        },

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Create Saving Plan with'),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Use current account data logic
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => CustomizedSavingPlan(title: 'Customized Financial Plan', userId: widget.userId,)));

                    },
                    child: Text('Current Account Data'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Create saving plan from scratch logic
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SavingPlanPage(title: "Saving Plan", userId:  widget.userId)));
                    },
                    child: Text('Create Saving Plan from Scratch'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }







}





