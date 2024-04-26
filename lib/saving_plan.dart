import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pandai_planner_flutter/services/api_service.dart';
import 'package:pandai_planner_flutter/tempDisplayAdvice.dart';
import 'package:pandai_planner_flutter/tempDisplayScratchAdvice.dart';

class SavingPlanPage extends StatefulWidget {
  @override
  _SavingPlanPageState createState() => _SavingPlanPageState();
}

class _SavingPlanPageState extends State<SavingPlanPage> {
  final _formKey = GlobalKey<FormState>();

  String _purpose = '';
  double _amount = 0.0;
  int _months = 1;
  int _years = 1;
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
          assessment= advice;
        });
      }
    } catch (error) {
      print("error $error");
    }
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
                            child: Text('${index + 1} month${index == 0 ? '' : 's'}'),
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
                            child: Text('${index} year${index == 0 ? '' : 's'}'),
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
                      await createAssesmentResponse();
                      await createFinancialAdvice();
                      await createScoreResponse();
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  TempAdviceScratch(financialAdvice: financialAdvice , assessment: assessment,successbilityScore: successScore)));
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
