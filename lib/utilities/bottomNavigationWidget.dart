import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pandai_planner_flutter/budget.dart';
import 'package:pandai_planner_flutter/home_page.dart';
import 'package:pandai_planner_flutter/register.dart';


class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(title: 'Home'),
    BudgetPage(title: 'Budget'),

// Placeholder widget
  ];

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
            text: "Analytic",
          ),
          GButton(
            icon: Icons.access_alarm,
            text: "Profile",
          ),
        ],
      ),
    );
  }
}
