import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  var rememberValue = false;
  var emailError;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();


  Future<void> _sendUserData(
      String email, String password, String fullName) async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/users/register';
    // Replace with your Spring Boot API endpoint URL
    print('hellow1aaaaaaaaaaaaaaaaaaaaaaaaa');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'name': fullName,
      }),
    );
    print('hellow2bbbbbbbbbbbbbbbbbbbbbbb');

    if (response.statusCode == 201) {
      // Handle a successful response here
      print('register successful');
      print('Response: ${response.body}');
      Navigator.pushReplacementNamed(context, '/homePage');

      final snackBar = SnackBar(
        content: Text('Registration successful!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      // Navigate to the home page after a short delay
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context)
            .push(MaterialPageRoute(
            builder: (context) => LoginPage(
              title: widget.title,
            ))) ;
      });
    } else {
      // Handle error or validation failures here
      print('Failed to register in. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
    if (response.statusCode == 500) {
      setState(() {
        // Set some state in your widget to display the error
        emailError = true;
      });
    }
  }
  // //void showSetBudgetDialog(BuildContext context, BudgetCategory category) {
  //   TextEditingController _budgetController = TextEditingController();
  //
  //   showDialog(
  //     context: context,
  // //     builder: (BuildContext context) {
  // //       return AlertDialog(
  // //         title: Text('Create Budget for ${category.name}'),
  // //         content: Column(
  // //           mainAxisSize: MainAxisSize.min,
  // //           children: <Widget>[
  //             // Your dialog content here
  //           ],
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('CANCEL'),
  //             onPressed: () => Navigator.of(context).pop(),
  //           ),
  //           TextButton(
  //             child: Text('SET'),
  //             onPressed: () {
  //               // Handle the budget setting logic
  //               print('Budget set for ${category.name}: ${_budgetController.text}');
  //               // Here you would call your database logic to save the budget
  //               // Make sure to include both the amount and the category ID
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }




  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
    child: Container(
    padding: const EdgeInsets.all(20),
       child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 80,),
            const Text(
              'Sign up',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                    controller: _fullNameController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Full name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: (value) {
                      EmailValidator.validate(value!)
                          ? null
                          : "Please enter a valid email";
                      if (emailError == true) {
                        return "The Email was taken";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      if (emailError != null) {
                        setState(() {
                          emailError = null;
                        });
                      }
                    },
                    controller: _emailController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    controller: _passwordController,
                    maxLines: 1,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    maxLines: 1,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Re-enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String email = _emailController.text;
                        String password = _passwordController.text;
                        String fullName = _fullNameController.text;
                        // Split the full name to get first and last names if needed
                        // For now, we'll keep it as a single full name
                        _sendUserData(email, password, fullName);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                    ),

                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already registered?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const LoginPage(title: 'Login UI'),
                            ),
                          );
                        },
                        child: const Text('Sign in'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
        ) ),
    ));
  }
}
