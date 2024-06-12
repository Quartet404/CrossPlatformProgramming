import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(CourierApp());
}

class CourierApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Courier App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginScreen(),
    );
  }
}
