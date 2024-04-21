import 'package:flutter/material.dart';

class SavingPlanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saving Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: Add logic to use current account data
                // Navigator.of(context).push(/* Route to use current account data */);
              },
              child: Text('Use Current Account Data'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Add logic to create a new plan from scratch
                // Navigator.of(context).push(/* Route to create a new plan */);
              },
              child: Text('Create New Plan from Scratch'),
            ),
          ],
        ),
      ),
    );
  }
}
