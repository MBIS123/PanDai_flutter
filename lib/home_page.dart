import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'constants/budgetIncomeCategory.dart';
import 'package:intl/intl.dart';

// Your BudgetCategory class definition
// Your getCategoryIconByName and getCategoryColor functions

class HomePage extends StatefulWidget {
  final String title;
  final int userId;

  const HomePage({Key? key, required this.title, required this.userId})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  double totalBudget = 0;
  double totalSpent = 0;
  Map<String, double> categorySpending = {};
  int? touchedIndex;

  @override
  void initState() {
    super.initState();
    _fetchBudgetData();
    _fetchTransactionData();
  }

  Future<void> _fetchBudgetData() async {
    final String apiUrl =
        'http://10.0.2.2:8080/api/v1/budget/budgetCurrentMonth?userId=${widget.userId}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        String responseBody = response.body;
        List<dynamic> jsonResponse = jsonDecode(responseBody);
        double newTotalBudget = 0;
        for (var data in jsonResponse) {
          double budgetLimit = (data['budgetLimit'] ?? 0).toDouble();
          newTotalBudget += budgetLimit;
        }
        setState(() {
          totalBudget = newTotalBudget;
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load budget data with status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  Future<void> _fetchTransactionData() async {
    final String apiUrl =
        'http://10.0.2.2:8080/api/v1/transaction/getTransactionInfoByCategory';
    try {
      final response = await http.get(
        Uri.parse(
            '$apiUrl?userId=${widget.userId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        String responseBody = response.body;
        List<dynamic> jsonResponse = jsonDecode(responseBody);
        print("The jsonResponse is:" + jsonResponse.toString());
        Map<String, double> newCategorySpending = {};

        double budgetSpent = 0.00;
        for (var data in jsonResponse) {
           budgetSpent = (data['transactionAmount'] ?? 0).toDouble();
           totalSpent += budgetSpent;
          newCategorySpending[data['budgetCategory']] = budgetSpent;
        }

        setState(() {
          totalSpent;
          categorySpending = newCategorySpending;
          isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load transaction data with status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.home,
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
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xff1a1919),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Expenses Analysis as of ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Total Budget: \RM${totalBudget.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.lightGreenAccent,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Total Spent: \RM${totalSpent.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 35,),
                          Row(
                            children: [
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1.3,
                                  child: categorySpending.isEmpty // Check if categorySpending is empty
                                      ? Center(
                                    child: Text(
                                      'No expense data available ', // Display a message when there's no data
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.redAccent
                                      ),
                                    ),
                                  )
                                      : PieChart(
                                    PieChartData(
                                      sections: categorySpending.keys.map((category) {
                                        final value = categorySpending[category] ?? 0;
                                        return PieChartSectionData(
                                          color: Colors.primaries[categorySpending.keys.toList().indexOf(category) % Colors.primaries.length],
                                          value: value,
                                          radius: 50, // You might want to adjust this if the chart has many sections or the sections are still too large
                                          title: '${value.toStringAsFixed(1)}',
                                          titleStyle: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xffd7d4d4),
                                          ),
                                          titlePositionPercentageOffset: 0.6,
                                          badgePositionPercentageOffset: 1.1,
                                        );
                                      }).toList(),
                                      sectionsSpace: 4, // Increased space between sections
                                      centerSpaceRadius: 40,
                                      pieTouchData: PieTouchData(
                                        touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                                          if (event is FlTapUpEvent && pieTouchResponse != null && pieTouchResponse.touchedSection != null) {
                                            setState(() {
                                              touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                            });
                                          } else {
                                            setState(() {
                                              touchedIndex = null;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16, height: 30),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: categorySpending.isEmpty // Check if categorySpending is empty
                                      ? [] // Return an empty list of widgets
                                      : categorySpending.keys.map((category) {
                                    return Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Container(
                                            color: Colors.primaries[categorySpending.keys.toList().indexOf(category) % Colors.primaries.length],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(category),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15,),

                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DataTable(
                          columnSpacing: 10,
                          horizontalMargin: 10,
                          columns: [
                            DataColumn(
                              label: Text('Category', style: TextStyle(fontStyle: FontStyle.normal ,fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                            ),
                            DataColumn(
                              label: Text('Spent', style: TextStyle(fontStyle: FontStyle.normal,fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                            ),
                          ],
                          rows: categorySpending.isNotEmpty
                              ? categorySpending.entries.map((entry) {
                            final categoryName = entry.key;
                            final categoryIcon = getCategoryIconByName(categoryName);
                            final categoryColor = getCategoryColor(categoryName);

                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      Icon(categoryIcon, color: categoryColor),
                                      SizedBox(width: 8),
                                      Text(categoryName , style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14
                                      )),
                                    ],
                                  ),
                                ),
                                DataCell(Text('\RM${entry.value.toStringAsFixed(2)}' , style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                                ),)),
                              ],
                            );
                          }).toList()
                              : [
                            DataRow(
                              cells: [
                                DataCell(
                                  Text('No expense data available yet',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.redAccent
                                    ),),
                                  // You can customize the appearance of the placeholder row here
                                ),
                                DataCell(
                                  Text(''),
                                ),
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
    );
  }
}
