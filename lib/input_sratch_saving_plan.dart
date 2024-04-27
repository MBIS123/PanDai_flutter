import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pandai_planner_flutter/services/api_service.dart';
import 'package:pandai_planner_flutter/tempDisplayCustomizedAdvice.dart';
import 'package:pandai_planner_flutter/tempDisplayScratchAdvice.dart';

class SavingPlanPage extends StatefulWidget {
  final String title;
  final int userId;

  const SavingPlanPage({
    Key? key,
    required this.title,
    required this.userId,
  }) : super(key: key);

  @override
  _SavingPlanPageState createState() => _SavingPlanPageState();
}

class _SavingPlanPageState extends State<SavingPlanPage> {
  final _formKey = GlobalKey<FormState>();

  String _purpose = '';
  double _amount = 0.0;
  int _months = 1;
  int _years = 0;
  double _monthlyExpense = 0.0;
  double _monthlyIncome = 0.0;
  double _extraTarget = 0.0;
  String assessment = "";
  String financialAdvice = "";
  String successScore = "";

  Future<void> createAssesmentResponse() async {
    try {
      final response = await ApiService.scratchAssessment(
        purpose: _purpose,
        amount: _amount,
        months: _months,
        years: _years,
        monthlyExpense: _monthlyExpense,
        monthlyIncome: _monthlyIncome,
        extraTarget: _extraTarget,
      );

      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> choices = jsonResponse['choices'];

      if (choices.isNotEmpty) {
        final Map<String, dynamic> choice = choices.first;
        final advice = choice['message']['content'];

        setState(() {
          assessment = advice;
        });
      }
    } catch (error) {
      print("error $error");
    }
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset(); // Reset the form state
      _purpose = '';
      _amount = 0.0;
      _months = 1;
      _years = 0;
      _extraTarget = 0.0;
      assessment = '';
      financialAdvice = '';
      successScore = '';
    });
  }


  Future<void> createFinancialAdvice() async {
    try {
      final response = await ApiService.scratchFinancialAdvice(
        purpose: _purpose,
        amount: _amount,
        months: _months,
        years: _years,
        monthlyExpense: _monthlyExpense,
        monthlyIncome: _monthlyIncome,
        extraTarget: _extraTarget,
      );

      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> choices = jsonResponse['choices'];

      if (choices.isNotEmpty) {
        final Map<String, dynamic> choice = choices.first;
        final advice = choice['message']['content'];

        setState(() {
          financialAdvice = advice;
        });
      }
    } catch (error) {
      print("error $error");
    }
  }

  Future<void> createScoreResponse() async {
    try {
      final response = await ApiService.scratchSuccessScore(
        purpose: _purpose,
        amount: _amount,
        months: _months,
        years: _years,
        monthlyExpense: _monthlyExpense,
        monthlyIncome: _monthlyIncome,
        extraTarget: _extraTarget,
      );

      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> choices = jsonResponse['choices'];

      if (choices.isNotEmpty) {
        final Map<String, dynamic> choice = choices.first;
        final advice = choice['message']['content'];
        setState(() {
          successScore = advice;
        });
      }
    } catch (error) {
      print("error $error");
    }
  }

  Future<void> _createFinancialPlan(
      int userId,
      double targetAmount,
      String planName,
      String successScore,
      String assessment,
      String financialAdvice,
      DateTime createPlanTime) async {
    // Proceed with creating the transaction if all validations pass
    final String apiUrl =
        'http://10.0.2.2:8080/api/v1/financialPlan/createFinancialPlan'; // Replace with your actual endpoint URL
    DateTime now = DateTime.now();

    print('Creating Financial plan');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'targetAmount': targetAmount,
        'planName': planName,
        'assessment': assessment,
        'successScore': successScore,
        'financialAdvice': financialAdvice,
        'financialAdjustment': "None",
        'createPlanDate': createPlanTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle a successful response here
      print(' Financial plan created successfully');
      print('Response: ${response.body}');
      final snackBar = SnackBar(
        content: Text(' Financial plan Recorded!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Navigate to the home page after a short delay
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          print("reloaded");
        });
      });
    } else {
      // Handle error or validation failures here
      print(
          'Failed to create FinancialPlan. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saving Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Saving Plan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Purpose for Saving',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _purpose = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a purpose for saving.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Amount to Save (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _amount = double.tryParse(value) ?? 0.0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount to save.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _months,
                        items: List.generate(
                          12,
                          (index) => DropdownMenuItem<int>(
                            value: index + 1,
                            child: Text(
                                '${index + 1} month${index == 0 ? '' : 's'}'),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _months = value ?? 1;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Time to Reach Saving (Months)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _years,
                        items: List.generate(
                          31,
                          (index) => DropdownMenuItem<int>(
                            value: index,
                            child:
                                Text('${index} year${index == 0 ? '' : 's'}'),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _years = value ?? 1;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Time to Reach Saving (Years)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Current Monthly Expense (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _monthlyExpense = double.tryParse(value) ?? 0.0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the current monthly expense.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Monthly Income (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _monthlyIncome = double.tryParse(value) ?? 0.0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the monthly income.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Extra Target (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _extraTarget = double.tryParse(value) ?? 0.0;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the extra target.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      showDialog(
                        context: context,
                        barrierDismissible: false, // Prevent dialog from closing when tapped outside
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(), // Loading indicator
                                SizedBox(height: 16),
                                Text(
                                  'Generating SMART financial advice... \nNote: Generating from scratch may affect the accuracy of the plan.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                    fontSize: 14
                                  ),
                                ),

                              ],
                            ),
                          );
                        },
                      );

                      // Perform async tasks
                      await createAssesmentResponse();
                      await createFinancialAdvice();
                      await createScoreResponse();
                      await _createFinancialPlan(widget.userId, _amount, _purpose, successScore,
                          assessment, financialAdvice
                          ,DateTime.now());


                      Navigator.of(context).pop(); // Dismiss the dialog
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => TempAdviceScratch(financialAdvice: financialAdvice ,
                        assessment: assessment,
                        successbilityScore: successScore,))).then((_){
                        _resetForm();
                      });
                    }
                  },
                  child: Text('Create Saving Plan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}