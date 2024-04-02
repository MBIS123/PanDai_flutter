import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pandai_planner_flutter/budget.dart';
import 'package:pandai_planner_flutter/home_page.dart';
import 'package:pandai_planner_flutter/register.dart';
import 'package:pandai_planner_flutter/transaction_page.dart';

import '../ai_planner.dart';
import '../profile_page.dart';

class MainWidget extends StatefulWidget {

  final int userId; // Change type if your userId is not an int

  const MainWidget({Key? key, required this.userId}) : super(key: key);

  @override
  _MainWidgetState createState() => _MainWidgetState();

}

class _MainWidgetState extends State<MainWidget> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions; // Make it a late non-static list

  @override
  void initState() {
    super.initState();
    // Initialize your widget options here
    _widgetOptions = <Widget>[
      HomePage(title: 'Home', userId: widget.userId), // Pass userId to HomePage
      BudgetPage(title: 'Budget' ,userId: widget.userId),
      TransactionPage(title: 'Transaction', userId: widget.userId),
      SmartPlanningPage(title: 'SmartPlanning', userId: widget.userId),
      ProfilePage(title: 'Profile', userId: widget.userId),

      // Add more widgets as needed
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: GNav(
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Home',
          ),
          GButton(
            icon: Icons.wallet_giftcard,
            text: "Budget",
          ),
          GButton(
            icon: Icons.add,
            text: "Transaction",
          ),
          GButton(
            icon: Icons.account_balance,
            text: "Smart Plan",
          ),
          GButton(
            icon: Icons.manage_accounts,
            text: "Account",
          ),
        ],
      ),
    );
  }
}
