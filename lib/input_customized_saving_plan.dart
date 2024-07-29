
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pandai_planner_flutter/services/api_service.dart';
import 'package:pandai_planner_flutter/tempDisplayCustomizedAdvice.dart';

import 'main.dart';
import 'model/income.dart';

class CustomizedSavingPlan  extends StatefulWidget {

  final String title;
  final int userId;

  const CustomizedSavingPlan({
    Key? key,
    required this.title,
    required this.userId,
  }) : super(key: key);


  @override
  State<CustomizedSavingPlan> createState() => _CustomizedSavingPlanState();
}

class _CustomizedSavingPlanState  extends State<CustomizedSavingPlan> {
  final _formKey = GlobalKey<FormState>();
    double totalIncomeAmt =0;
   double totalBudgetSpent =0 ;
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
  String adjustBudgetExpenseAdvice ="";
  List<Income> incomeList = [];
  List<Map<String, dynamic>> incomeDataList = [];
  List<Map<String, dynamic>> budgetDataList = [];
  List<Map<String, dynamic>> transactionDataList = [];

  @override
  void initState() {
    super.initState();
    _fetchIncomeData();
    _fetchTransactionData();
    _fetchTransactionInfo();
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
      adjustBudgetExpenseAdvice = '';
    });
  }



  Future<List<Map<String, dynamic>>> _fetchIncomeData() async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/income/getAllIncome?userId=${widget.userId}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        for (var item in data) {
          Map<String, dynamic> incomeData = {
            'type': item['type'],
            'amount': item['amount'],
          };
          incomeDataList.add(incomeData);
        }
        setState(() {
          incomeDataList;
          totalIncomeAmt = incomeDataList.map((income) => income['amount']).fold(0, (prev, amount) => prev + amount);
        });
        return incomeDataList;
      } else {
        print('Failed to fetch income data. Status code: ${response.statusCode}');
        return []; // Return an empty list in case of failure
      }
    } catch (error) {
      print('Error fetching income data: $error');
      return []; // Return an empty list in case of error
    }
  }

  Future<void> _fetchBudgetData() async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/budget/budgetCurrentMonth?userId=${widget.userId}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        String responseBody = response.body;
        List<dynamic> jsonResponse = jsonDecode(responseBody);
        double newTotalBudgetSpent = 0;

        for (var data in jsonResponse) {
          Map<String, dynamic> budgetData = {
            'category': data['budgetCategory'],
            'limit': data['budgetLimit'],
            'spent': data['budgetSpent'],
          };
          budgetDataList.add(budgetData);
          double budgetSpent = (data['budgetSpent'] ?? 00).toDouble();
          newTotalBudgetSpent += budgetSpent;
        }
        setState(() {
          totalBudgetSpent = newTotalBudgetSpent;
        });
      } else {
        throw Exception('Failed to load budget data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  Future<void> _fetchTransactionData() async {
    final String apiUrl =
        'http://10.0.2.2:8080/api/v1/transaction/getTransactionInfoByCategory';
    try {
      final response = await http.get(
        Uri.parse('$apiUrl?userId=${widget.userId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        String responseBody = response.body;
        List<dynamic> jsonResponse = jsonDecode(responseBody);
        print("The jsonResponse is:" + jsonResponse.toString());
        double _totalBudgetSpent = 0;

        for (var data in jsonResponse) {
          double transactionAmount = (data['transactionAmount'] ?? 0).toDouble();
          totalBudgetSpent += transactionAmount;
        }


      } else {
        throw Exception(
            'Failed to load transaction data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  Future<void> _fetchTransactionInfo() async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/transaction/getTransactionInfo';
    try {
      // Prepare the query parameters
      Map<String, dynamic> queryParams = {
        'userId': widget.userId.toString(),
      };
      // Send the GET request
      final Uri uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        // Transaction information retrieved successfully
        List<dynamic> jsonResponse = jsonDecode(response.body);

        for (var data in jsonResponse) {
          Map<String, dynamic> transactionData = {
            'expenseDate': data['transactionDate'],
            'expensetype': data['budgetCategory'],
            'transactionAmt': data['transactionAmount'],
          };
          transactionDataList.add(transactionData);
        }
        setState(() {
          transactionDataList ;
        });        print('Transaction information: $jsonResponse');
      } else {
        // Failed to retrieve transaction information
        print('Failed to retrieve transaction information with status code: ${response.statusCode}');
        // You can handle the error here as needed
      }
    } catch (e) {
      print('Error fetching transaction information: $e');
      // Handle any exceptions that occur during the process
    }
  }


  Future<void> createAssesmentResponse() async {
    try {
      final response = await ApiService.customisedAssessment(
        purpose: _purpose,
        amount: _amount,
        months: _months,
        years: _years,
        monthlyExpense: totalBudgetSpent,
        monthlyIncome: totalIncomeAmt,
        extraTarget: _extraTarget,
        incomeDataList: incomeDataList,
        budgetDataList: budgetDataList,
        transactionDataList: transactionDataList
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
      final response = await ApiService.customizedFinancialAdvice(
        purpose: _purpose,
        amount: _amount,
        months: _months,
        years: _years,
        monthlyExpense: totalBudgetSpent,
        monthlyIncome: totalIncomeAmt,
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
      final response = await ApiService.customizedSuccessScore(
        purpose: _purpose,
        amount: _amount,
        months: _months,
        years: _years,
        monthlyExpense: totalBudgetSpent,
        monthlyIncome: totalIncomeAmt,
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

  Future<void> createBudgetExpenseAdjustResponse() async {
    try {
      final response = await ApiService.customizedBudgetExpenseAdjustment(
        purpose: _purpose,
        amount: _amount,
        months: _months,
        years: _years,
        monthlyExpense: totalBudgetSpent,
        monthlyIncome: totalIncomeAmt,
        extraTarget: _extraTarget, incomeDataList: incomeDataList,
        budgetDataList: budgetDataList,
        transactionDataList: transactionDataList,
      );

      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> choices = jsonResponse['choices'];
      if (choices.isNotEmpty) {
        final Map<String, dynamic> choice = choices.first;
        final advice = choice['message']['content'];
        setState(() {
          adjustBudgetExpenseAdvice = advice;
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
      String financialAdjustment,
      DateTime createPlanTime
     ) async {
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
        'financialAdjustment': financialAdjustment,
        'createPlanDate':  createPlanTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle a successful response here
      print(' Financial plan created successfully');
      print('Response: ${response.body}');
      final snackBar = SnackBar(
        content: Text(' Financial plan Recorded!', style: TextStyle(fontWeight: FontWeight.bold,),),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.lightGreenAccent,
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
    if (totalBudgetSpent == 0) { // fetch INCOME request haven't completed
      return Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(), // or any loading indicator
        ),
      );
    }
    else if (totalIncomeAmt == 0) { // fetch INCOME request haven't completed
      return Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(), // or any loading indicator
        ),
      );
    }
    else {
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
                    labelText: 'Total Monthly Income (\$)',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: totalIncomeAmt.toStringAsFixed(2), // Ensures the amount is displayed with two decimal places
                  readOnly: true,
                ),

                SizedBox(height: 20),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Total Monthly Expenses (\$)',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: totalBudgetSpent.toStringAsFixed(2), // Ensures the amount is displayed with two decimal places
                  readOnly: true, // Makes the text field read-only
                ),

                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Extra Saving Target (\$)',
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
                                    'Generating SMART financial advice...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: defaultColorScheme.primary,
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
                        await createBudgetExpenseAdjustResponse();
                        await _createFinancialPlan(widget.userId, _amount, _purpose, successScore,
                            assessment, financialAdvice, adjustBudgetExpenseAdvice
                            ,DateTime.now());
                        Navigator.of(context).pop(); // Dismiss the dialog
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                            TempAdvice(financialAdvice: financialAdvice ,
                          assessment: assessment,
                          successbilityScore: successScore,
                        budgetExpenseAdjustment: adjustBudgetExpenseAdvice,))
                        ).then((_){
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
}

