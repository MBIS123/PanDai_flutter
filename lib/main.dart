import 'package:flutter/material.dart';
import 'package:pandai_planner_flutter/budget.dart';
import 'package:pandai_planner_flutter/home_page.dart';
import 'package:pandai_planner_flutter/register.dart';
import 'package:pandai_planner_flutter/transaction_page.dart';
import 'package:pandai_planner_flutter/user_Data.dart';
import 'package:pandai_planner_flutter/utilities/bottomNavigationWidget.dart';
import 'login.dart';


void main() => runApp(MyApp());


ColorScheme defaultColorScheme = const ColorScheme(
  primary: Color(0xffBB86FC),
  secondary: Color(0xff03DAC6),
  surface: Color(0xff100000),
  background: Color(0xff0c0000),
  error: Color(0xffCF6679),
  onPrimary: Color(0xff05000a),
  onSecondary: Color(0xff000000),
  onSurface: Color(0xffffffff),
  onBackground: Color(0xffffffff),
  onError: Color(0xff0e0000),
  brightness: Brightness.dark,
);



class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: defaultColorScheme,
        primarySwatch: Colors.blue,
      ),
      home:  LoginPage(title: "login"),
      routes: {
        '/LoginPage': (context) => LoginPage(title: "login"),
        '/registerPage': (context) => RegisterPage(title: "Register UI"),
        '/HomePage': (context) => HomePage(title: "Home page", userId: UserData().userId),
      },
    );
  }
}





