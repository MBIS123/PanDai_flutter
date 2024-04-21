import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pandai_planner_flutter/budget.dart';
import 'package:pandai_planner_flutter/home_page.dart';
import 'package:pandai_planner_flutter/register.dart';
import 'package:pandai_planner_flutter/transaction_page.dart';
import '../ai_planner.dart';
import '../main.dart';
import '../profile_page.dart';

class BottomWidget extends StatefulWidget {

  final int userId;
  const BottomWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _BottomWidgetState createState() => _BottomWidgetState();


}

class _BottomWidgetState extends State<BottomWidget> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomePage(title: 'Home', userId: widget.userId),
      BudgetPage(title: 'Budget', userId: widget.userId),
      TransactionPage(title: 'Transaction', userId: widget.userId),
      SmartPlanningPage(title: 'SmartPlanning', userId: widget.userId),
      ProfilePage(title: 'Profile', userId: widget.userId),
    ];
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {  // Add this check to see if the tab is already selected
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor:  defaultColorScheme.primary, // Set the text color to the primary color from the default color scheme

        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Set to fixed for more than 3 items
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
      ),
    );
  }


}
