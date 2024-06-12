import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'main.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  ProfileScreen({required this.uid}); // Оновіть конструктор

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/client/user/${widget.uid}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _phoneController.text = data['phone'] ?? '';
        _nameController.text = data['name'] ?? '';
        _addressController.text = data['address'] ?? '';
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to load user data: ${response.body}';
      });
    }
  }

  Future<void> _updateUserData() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/client/update/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'uid': widget.uid,
        'name': _nameController.text,
        'address': _addressController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _statusMessage = 'Successfully updated';
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to update: ${response.body}';
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyApp()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профіль'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Телефон'),
              readOnly: true,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Введіть ім\'я'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Адреса'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserData,
              child: Text('Зберегти'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align button to right
              children: [
                TextButton(
                  onPressed: _signOut,
                  child: Text('Вийти'),
                ),
              ],
            ),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}
