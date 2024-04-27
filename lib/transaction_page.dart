import 'dart:convert';
import 'main.dart';
import 'model/transaction_info.dart';
import 'user_Data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'model/budget_category.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pandai_planner_flutter/budget.dart';
import 'package:pandai_planner_flutter/home_page.dart';
import 'package:pandai_planner_flutter/register.dart';
import 'package:pandai_planner_flutter/transaction_page.dart';
import '../smart_plan.dart';
import '../profile_page.dart';
import 'package:pandai_planner_flutter/constants/budgetIncomeCategory.dart';

class _MonthSwitcherState extends State<MonthSwitcher> {
  late DateTime currentDate;

  @override
  void initState() {
    super.initState();
    currentDate = widget.initialDate;
  }

  void _nextMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
      widget.onMonthChanged(currentDate);
    });
  }

  void _previousMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month - 1, 1);
      widget.onMonthChanged(currentDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _previousMonth,
        ),
        Text(
          DateFormat('MMMM yyyy').format(currentDate),
          style: Theme.of(context).textTheme.headline6,
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: _nextMonth,
        ),
      ],
    );
  }
}

class ViewTransactionPage extends StatefulWidget {
  final String title;
  final int userId;
  final VoidCallback fetchTransactionData;

  const ViewTransactionPage({
    Key? key,
    required this.title,
    required this.userId,
    required this.fetchTransactionData,
  }) : super(key: key);

  @override
  _ViewTransactionPageState createState() => _ViewTransactionPageState();
}

class _ViewTransactionPageState extends State<ViewTransactionPage> {
  List<TransactionInfo> transactionHistory = [];
  DateTime selectedMonth = DateTime.now();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTransactionData(selectedMonth);
  }

  Future<void> _fetchTransactionData(DateTime month) async {
    final String apiUrl =
        'http://10.0.2.2:8080/api/v1/transaction/getTransactionInfo';

    // Extract year and month from the DateTime object
    int year = month.year;
    int monthNumber = month.month;
    print('the year number:'+ year.toString());

    print('the month number:'+ monthNumber.toString());
    final response = await http.get(
      Uri.parse(
          '$apiUrl?userId=${widget.userId}&year=$year&month=$monthNumber'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      List<TransactionInfo> transactionList = jsonResponse
          .map((transactionJson) => TransactionInfo.fromJson(transactionJson))
          .toList();
      setState(() {
        transactionHistory = transactionList;
        isLoading = false;
      });
    } else {
      print('Failed to load transactions. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }

  void _showTransactionDetailsDialog(TransactionInfo transaction) {
    final defaultColorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: defaultColorScheme.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Transaction Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: defaultColorScheme.primary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading:
                      Icon(Icons.category, color: defaultColorScheme.primary),
                  title: Text(
                    'Budget Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(transaction.budgetCategory),
                ),
                ListTile(
                  leading: Icon(Icons.attach_money,
                      color: defaultColorScheme.primary),
                  title: Text(
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle:
                      Text('\$${transaction.transactionAmount.toString()}'),
                ),
                ListTile(
                  leading: Icon(Icons.note, color: defaultColorScheme.primary),
                  title: Text(
                    'Note',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(transaction.note),
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today,
                      color: defaultColorScheme.primary),
                  title: Text(
                    'Transaction Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(DateFormat('MMMM dd, yyyy')
                      .format(transaction.transactionDate)),
                ),
                ListTile(
                  leading: Icon(Icons.access_time,
                      color: defaultColorScheme.primary),
                  title: Text(
                    'Transaction Time',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      DateFormat('HH:mm').format(transaction.transactionTime)),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _editTransaction(TransactionInfo transaction) {
    Navigator.of(context)
        .push(MaterialPageRoute(
      builder: (context) => TransactionPage(
        title: 'Edit Transaction',
        userId: widget.userId,
        transactionToEdit: transaction,
      ),
    ))
        .then((_) {
      // Call your method to fetch data from the backend here
      _fetchTransactionData(selectedMonth);
    });
  }

  void _deleteTransaction(TransactionInfo transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this transaction?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _fetchTransactionData(selectedMonth);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Call the method to delete the transaction
                await _deleteTransactionRequest(transaction);
                // Remove the transaction from the local list
                setState(() {
                  transactionHistory.remove(transaction);
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTransactionRequest(TransactionInfo transaction) async {
    final String apiUrl =
        'http://10.0.2.2:8080/api/v1/transaction/deleteTransaction';

    final response = await http.delete(
      Uri.parse('$apiUrl/${transaction.transactionId}'),
      // Assuming the transaction has an id
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Transaction deleted successfully');
      setState(() {
        _fetchTransactionData(selectedMonth);
      });
    } else {
      print(
          'Failed to delete transaction. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.history,
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
          : Container(
        // Provide explicit constraints to the container
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // MonthSwitcher remains at the top
              SizedBox(
                height: 20,
              ),
              MonthSwitcher(
                initialDate: selectedMonth,
                onMonthChanged: (DateTime newMonth) {
                  setState(() {
                    selectedMonth = newMonth;
                    _fetchTransactionData(selectedMonth);
                  });
                },
              ),
              // Spacer to push the message to the center
              Expanded(
                child: transactionHistory.isEmpty
                    ? Center(
                  child: Text(
                    'No transaction made in this month .\n Please create a new record.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: defaultColorScheme.primary,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: transactionHistory.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        color: Colors.red,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        if (direction ==
                            DismissDirection.startToEnd) {
                          // Delete action
                          _deleteTransaction(
                              transactionHistory[index]);
                        } else if (direction ==
                            DismissDirection.endToStart) {
                          // Edit action
                          _editTransaction(transactionHistory[index]);
                        }
                      },
                      child: GestureDetector(
                        onTap: () {
                          _showTransactionDetailsDialog(
                              transactionHistory[index]);
                        },
                        child: Card(
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: getCategoryColor(
                                  transactionHistory[index]
                                      .budgetCategory),
                              child: Icon(
                                getCategoryIconByName(
                                    transactionHistory[index]
                                        .budgetCategory),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(transactionHistory[index]
                                .budgetCategory),
                            subtitle: Text(
                              'Amount: \$${transactionHistory[index].transactionAmount.toString()} \nDate: ${DateFormat('yyyy-MM-dd').format(transactionHistory[index].transactionDate)}',
                            ),

                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => TransactionPage(
                        title: widget.title,
                        userId: widget.userId,
                      )))
              .then((_) {
            // Call your method to fetch data from the backend here
            _fetchTransactionData(selectedMonth);
          });
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class TransactionPage extends StatefulWidget {
  final String title;
  final int userId;
  final TransactionInfo? transactionToEdit;

  const TransactionPage({
    Key? key,
    required this.title,
    required this.userId,
    this.transactionToEdit,
  }) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late String _pageTitle;
  String _selectedCategory = 'Select category';
  String _noteHeader = 'Write note';
  late DateTime _selectedDate;
  late DateTime _selectedTime;
  String formatedTime = "";
  double _transactionAmount = 0.00;

  String getFormattedDate() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('MMMM, y');
    return formatter.format(now);
  }

  Future<void> _createOrUpdateTransaction(
      int userId,
      int transactionId,
      double transactionAmount,
      String budgetCategory,
      String note,
      DateTime transactionDate,
      DateTime transactionTime) async {
    if (transactionId != null) {
      print('is not null');

      // Editing an existing transaction, call updateTransaction
      await _updateTransaction(userId, transactionId, transactionAmount,
          budgetCategory, note, transactionDate, transactionTime);
    } else {
      print('came to add new');
      await _createTransaction(userId, transactionAmount, budgetCategory, note,
          transactionDate, transactionTime);
    }
    print('no add dao');
  }

  Color getCategoryColor(String categoryName) {
    final category = budgetCategories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => BudgetCategory(
          id: 0,
          name: 'Default',
          icon: Icons.error_outline,
          color: Colors.grey),
    );
    return category.color;
  }

  IconData getCategoryIconByName(String categoryName) {
    final category = budgetCategories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => BudgetCategory(
          id: 0,
          name: 'Default',
          icon: Icons.error_outline,
          color: Colors.grey),
    );
    return category.icon;
  }

  @override
  void initState() {
    super.initState();
    _pageTitle = widget.transactionToEdit != null
        ? 'Edit Transaction'
        : 'Add Transaction';
    _selectedCategory =
        widget.transactionToEdit?.budgetCategory ?? 'Select category';
    _noteHeader = widget.transactionToEdit?.note ?? 'Write note';
    _selectedDate = widget.transactionToEdit?.transactionDate ?? DateTime.now();
    _selectedTime = widget.transactionToEdit?.transactionTime ?? DateTime.now();
    _transactionAmount = widget.transactionToEdit?.transactionAmount ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle , style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),),

      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text(_selectedCategory),
            trailing: Icon(Icons.keyboard_arrow_down),
            onTap: _showCategoryDialog,
            leading: CircleAvatar(
              backgroundColor: getCategoryColor(_selectedCategory),
              // Get the color from the selected category
              child: Icon(getCategoryIconByName(_selectedCategory),
                  color:
                  Colors.white), // Get the icon from the selected category
            ),
          ),
          ListTile(
            title: Text(_transactionAmount != null
                ? 'RM ${_transactionAmount.toStringAsFixed(2)}'
                : 'RM'),
            trailing: Icon(Icons.keyboard_arrow_down),
            onTap: _showCalculatorDialog,
          ),

          ListTile(
            title: Text(_noteHeader),
            trailing: Icon(Icons.edit),
            onTap: _showNoteDialog,
          ),
          ListTile(
            title: Text('Transaction Date'),
            subtitle: Text('${DateFormat('MMMM, dd').format(_selectedDate)}'),
            trailing: Icon(Icons.calendar_today),
            onTap: _showDatePicker,
          ),
          ListTile(
            title: Text('Transaction Time'),
            subtitle: Text('${DateFormat('HH:mm').format(_selectedTime)}'),
            trailing: Icon(Icons.calendar_today),
            onTap: _showTimePicker,
          ),
          Container(
            alignment: Alignment.bottomCenter,
            // Aligns the button at the bottom center
            padding: EdgeInsets.all(16),
            // Optional padding for spacing
            child: ElevatedButton(
              onPressed: () async {
                try {
                  print("the transcation amount is:" +
                      _transactionAmount.toString());

                  if (widget.transactionToEdit != null) {
                    try {
                      await _createOrUpdateTransaction(
                        widget.userId,
                        widget.transactionToEdit!.transactionId,
                        _transactionAmount,
                        _selectedCategory,
                        _noteHeader,
                        _selectedDate,
                        _selectedTime,
                      );
                      await recordBudgetSpent(
                        widget.userId,
                        _selectedCategory,
                        _selectedDate,
                        _transactionAmount,
                      );
                      Navigator.pop(
                          context); // Navigate back after transaction is successfully saved
                    } catch (error) {
                      // Handle errors
                      print("Error saving transaction: $error");
                    }
                  } else {
                    try {
                      await _createTransaction(
                        widget.userId,
                        _transactionAmount,
                        _selectedCategory,
                        _noteHeader,
                        _selectedDate,
                        _selectedTime,
                      );
                      await recordBudgetSpent(
                        widget.userId,
                        _selectedCategory,
                        _selectedDate,
                        _transactionAmount,
                      );

                      print("the add transaction created");
                      Navigator.pop(
                          context); // Navigate back after transaction is successfully saved
                    } catch (error) {
                      // Handle errors
                      print("Error saving transaction: $error");
                    }
                  }
                } catch (error) {
                  // Handle errors
                  print("Error saving transaction: $error");
                }
              },
              child: Text('Save'),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _createTransaction(
      int userId,
      double transactionAmount,
      String budgetCategory,
      String note,
      DateTime transactionDate,
      DateTime transactionTime) async {
    // Validate input fields
    if (transactionAmount == 0.0) {
      _showValidationError('Transaction amount cannot be zero');
      return;
    }
    if (budgetCategory == 'Select category') {
      _showValidationError('Please select a category');
      return;
    }
    if (note.isEmpty) {
      _noteHeader = "";
      return;
    }
    if (transactionTime == null) {
      _showValidationError('Please select a transaction time');
      return;
    }

    // Proceed with creating the transaction if all validations pass
    final String apiUrl =
        'http://10.0.2.2:8080/api/v1/transaction/createTransaction'; // Replace with your actual endpoint URL
    print('Creating Transaction');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'transactionAmount': transactionAmount,
        'budgetCategory': budgetCategory,
        'note': note,
        'transactionDate': transactionDate.toIso8601String(),
        'transactionTime': transactionTime.toIso8601String(),
        // Ensure backend accepts ISO 8601 string format
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle a successful response here
      print("the note is:" + note);
      print("the transactionTime is:" +
          transactionTime.toIso8601String.toString());

      print('Transaction created successfully');
      print('Response: ${response.body}');
      int userId = UserData().userId;
      final snackBar = SnackBar(
        content: Text('Transaction Recorded!'),
        duration: Duration(seconds: 2),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Navigate to the home page after a short delay
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          print("reloaded");
          _transactionAmount = 0.0; // Reset transaction amount
          _selectedCategory = 'Select category'; // Reset selected category
          _noteHeader = 'Write note'; // Reset note header
          _selectedDate = DateTime.now(); // Reset selected date
        });
      });
    } else {
      // Handle error or validation failures here
      print(
          'Failed to create transaction. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }



  Future<void> _updateTransaction(
      int userId,
      int transactionId,
      double transactionAmount,
      String budgetCategory,
      String note,
      DateTime transactionDate,
      DateTime transactionTime) async {
    // Validate input fields
    if (transactionAmount == 0.0) {
      _showValidationError('Transaction amount cannot be zero');
      return;
    }
    if (budgetCategory == 'Select category') {
      _showValidationError('Please select a category');
      return;
    }
    if (note.isEmpty) {
      _noteHeader = "";
      return;
    }
    if (transactionTime == null) {
      _showValidationError('Please select a transaction time');
      return;
    }

    // Proceed with updating the transaction if all validations pass
    final String apiUrl =
        'http://10.0.2.2:8080/api/v1/transaction/updateTransaction'; // Replace with your actual endpoint URL
    print('Updating Transaction');
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'transactionId': transactionId,
        'transactionAmount': transactionAmount,
        'budgetCategory': budgetCategory,
        'note': note,
        'transactionDate': transactionDate.toIso8601String(),
        'transactionTime': transactionTime.toIso8601String(),
        // Ensure backend accepts ISO 8601 string format
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle a successful response here
      print("the note is:" + note);
      print("the transactionTime is:" +
          transactionTime.toIso8601String.toString());

      print('Transaction updated successfully');
      print('Response: ${response.body}');
      int userId = UserData().userId;
      final snackBar = SnackBar(
        content: Text('Transaction Updated!'),
        duration: Duration(seconds: 2),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // Navigate to the home page after a short delay
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          print("reloaded");
          // Reset transaction amount, category, note, and date/time
          _transactionAmount = 0.0;
          _selectedCategory = 'Select category';
          _noteHeader = 'Write note';
          _selectedDate = DateTime.now();
          _selectedTime = DateTime.now();
        });
      });
    } else {
      // Handle error or validation failures here
      print(
          'Failed to update transaction. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Missing Input'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> recordBudgetSpent(int userId, String budgetCategory,
      DateTime budgetDate, double budgetSpent) async {
    final String apiUrl =
        'http://10.0.2.2:8080/api/v1/budget/recordBudgetSpent'; // Update with your actual endpoint URL
    print('Recording Budget Spent');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'budgetCategory': budgetCategory,
        'budgetDate': budgetDate.toIso8601String(),
        'budgetSpent': budgetSpent,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Budget spent recorded successfully');
      print('Response: ${response.body}');
    } else {
      print(
          'Failed to record budget spent. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
  }

  void _showCalculatorDialog() {
    TextEditingController _transactionController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Create a TextEditingController to capture the input from the TextField
        return AlertDialog(
          title: Text('Create Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _transactionController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              SizedBox(height: 20, width: 20),

              // Add any other input fields or widgets you need
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                print('Transaction set to: ${_transactionController.text}');
                // Fallback to 0.0 if parsing fails

                setState(() {
                  _transactionAmount =
                      double.tryParse(_transactionController.text) ??
                          0.0; // Fallback to 0.0 if parsing fails
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Category'),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: budgetCategories.length,
              itemBuilder: (context, index) {
                var category = budgetCategories[index];
                return ListTile(
                  title: Text(category.name),
                  leading: CircleAvatar(
                    backgroundColor: category.color,
                    child: Icon(
                      category.icon,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category.name;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showNoteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Write note'),
          content: TextField(
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  _noteHeader = value;
                });
              }
            },
            decoration: InputDecoration(hintText: "Enter your note here"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showTimePicker() async {
    final TimeOfDay? timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (timePicked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          timePicked.hour,
          timePicked.minute,
        );
      });
    }
  }
}
