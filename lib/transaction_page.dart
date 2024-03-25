import 'package:flutter/material.dart';
// ... other necessary imports ...

class TransactionPage extends StatefulWidget {
  final String title;
  final int userId;


  const TransactionPage({Key? key, required this.title,required this.userId}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String _selectedCategory = 'Select category';
  String _note = '';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('MYR'),
            trailing: Icon(Icons.keyboard_arrow_down),
            onTap: _showCalculatorDialog,
          ),
          ListTile(
            title: Text(_selectedCategory),
            trailing: Icon(Icons.keyboard_arrow_down),
            onTap: _showCategoryDialog,
          ),
          ListTile(
            title: Text('Write note'),
            trailing: Icon(Icons.edit),
            onTap: _showNoteDialog,
          ),
          ListTile(
            title: Text('Today'),
            subtitle: Text('${_selectedDate.toLocal()}'.split(' ')[0]),
            trailing: Icon(Icons.calendar_today),
            onTap: _showDatePicker,
          ),
          // ... Additional UI elements ...
        ],
      ),
    );
  }

  void _showCalculatorDialog() {
    // TODO: Implement calculator dialog
  }

  void _showCategoryDialog() {
    // TODO: Implement category selection dialog
  }

  void _showNoteDialog() {
    // Show dialog for text input
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Write note'),
          content: TextField(
            onChanged: (value) {

              if(mounted){
                setState(() {
                  _note = value;
                });
              }





              },
            decoration: InputDecoration(hintText: "Enter your note here"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDatePicker() {
    // Show date picker dialog
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).then((date) {
      if (date != null && date != _selectedDate) {
        setState(() {
          _selectedDate = date;
        });
      }
    });
  }
}
