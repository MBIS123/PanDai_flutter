import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:pandai_planner_flutter/register.dart';
import 'package:pandai_planner_flutter/utilities/bottomNavigationWidget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late bool _successValidate = true;
  String? _errorMEssage;
  var rememberValue = false;
  var emailError = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkCredentials();
  }
  Future<void> _checkCredentials() async {
    final storedEmail = await storage.read(key: 'email');
    final storedPassword = await storage.read(key: 'password');

    if (storedEmail != null && storedPassword != null) {
      _emailController.text = storedEmail;
      _passwordController.text = storedPassword;
      rememberValue = true;
      _validateLogin(storedEmail, storedPassword, remember: true);
    }
  }

//Future represent a task may not complete yet but will eventually produce a result
  Future<void> _validateLogin(String email, String password, {bool remember = false}) async {
    final String apiUrl = 'http://10.0.2.2:8080/api/v1/users/login';
    if (remember) {
      await storage.write(key: 'email', value: email);
      await storage.write(key: 'password', value: password);
    } else {
      if (!rememberValue) {
        await storage.delete(key: 'email');
        await storage.delete(key: 'password');
      }
    }
    print('Try to log in');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    print('Request posted');

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Handle a successful response here
      print('login successful');
      print('Response: ${response.body}');

      // Parse the user ID from the response
      final responseData = json.decode(response.body);
      final userId = responseData['userId']; // Ensure that this is not null

      print('not null la' + userId.toString());

      // Navigate to the home page after a short delay
      // Navigate to MainWidget and pass userId
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainWidget(userId: userId),
          ),
        );
      });

    } else {
      // Handle error or validation failures here
      final snackBar = SnackBar(
        content: Text('Invalid Login please reenter!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      setState(() {
        _successValidate = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print(_successValidate);
      print('Failed to log in. Status code: ${response.statusCode}');
      print('Error response: ${response.body}');
    }
    if (response.statusCode == 500) {
      setState(() {
        // Set some state in your widget to display the error
        emailError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Sign in',
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
                      if (EmailValidator.validate(value!)) {
                        return null;
                      }
                      if (_successValidate == false) {
                        return "Email was not registered";
                      } else {
                        return "Please enter a valid email";
                      }
                    },
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    controller: _emailController,
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
                    maxLines: 1,
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text("Remember me"),
                    contentPadding: EdgeInsets.zero,
                    value: rememberValue,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (newValue) {
                      setState(() {
                        rememberValue = newValue!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String email = _emailController.text;
                        String password = _passwordController.text;
                        _validateLogin(email, password);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                    ),
                    child: const Text(
                      'Sign in',
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
                      const Text('Not registered yet?'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/registerPage');
                        },
                        child: const Text('Create an account'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

Future<void> _sendUserData(String email, String password) async {
  final String apiUrl =
      'http://10.0.2.2:8080/api/v1/users/login'; // Replace with your Spring Boot API endpoint URL

  print('hellow1aaaaaaaaaaaaaaaaaaaaaaaaa');
  final response = await http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
    }),
  );
  print('hellow2bbbbbbbbbbbbbbbbbbbbbbb');



  if (response.statusCode == 200) {
    // Handle a successful response here
    print('Login successful');
    print('Response: ${response.body}');
  } else {
    // Handle error or validation failures here
    print('Failed to log in. Status code: ${response.statusCode}');
    print('Error response: ${response.body}');
  }
}
