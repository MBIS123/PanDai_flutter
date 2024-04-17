import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String title;
  final int userId;

  const HomePage({Key? key, required this.title, required this.userId}) : super(key: key);

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
  }

  Future<void> _fetchBudgetData() async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/budget/budgetCurrentMonth?userId=${widget.userId}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        String responseBody = response.body;
        List<dynamic> jsonResponse = jsonDecode(responseBody);
        double newTotalBudget = 0;
        double newTotalSpent = 0;
        Map<String, double> newCategorySpending = {};

        for (var data in jsonResponse) {
          double budgetLimit = (data['budgetLimit'] ?? 0).toDouble();
          double budgetSpent = (data['budgetSpent'] ?? 0).toDouble();
          newTotalBudget += budgetLimit;
          newTotalSpent += budgetSpent;
          newCategorySpending[data['budgetCategory']] = budgetSpent;
        }
        setState(() {
          totalBudget = newTotalBudget;
          totalSpent = newTotalSpent;
          categorySpending = newCategorySpending;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load budget data with status code: ${response.statusCode}');
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
        title: Text(widget.title),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget Analysis',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              SizedBox(height: 16), // Adjust spacing between chart and legend
              Text('Total Budget: \$${totalBudget.toStringAsFixed(2)}'),
              Text('Total Spent: \$${totalSpent.toStringAsFixed(2)}'),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1.3,
                      child: PieChart(
                        PieChartData(
                          sections: categorySpending.keys.map((category) {
                            final value = categorySpending[category] ?? 0;
                            return PieChartSectionData(
                              color: Colors.primaries[categorySpending.keys.toList().indexOf(category) % Colors.primaries.length],
                              value: value,
                              radius: 50,
                              titleStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xffffffff),
                              ),
                              titlePositionPercentageOffset: 0.6,
                              badgePositionPercentageOffset: 1.1,
                            );
                          }).toList(),
                          sectionsSpace: 2,
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
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categorySpending.keys.map((category) {
                      return Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Container(color: Colors.primaries[categorySpending.keys.toList().indexOf(category) % Colors.primaries.length]),
                          ),
                          SizedBox(width: 8),
                          Text(category),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 16), // Adjust spacing between chart and legend
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavigationBar(userId: widget.userId),
    );
  }
}

class _BottomNavigationBar extends StatefulWidget {
  final int userId;

  const _BottomNavigationBar({Key? key, required this.userId}) : super(key: key);

  @override
  State<_BottomNavigationBar> createState() => _BottomNavigationBarState();
}

class _BottomNavigationBarState extends State<_BottomNavigationBar> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text('Index 0: Home'),
    Text('Index 1: Budget'),
    Text('Index 2: Transaction'),
    Text('Index 3: Smart Plan'),
    Text('Index 4: Account'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.wallet_giftcard),
          label: 'Budget',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Transaction',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance),
          label: 'Smart Plan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.manage_accounts),
          label: 'Account',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }




}
