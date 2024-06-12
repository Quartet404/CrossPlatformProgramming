import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Courier Delivery',
      home: FutureBuilder<String?>(
        future: _checkAuthStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.data != null) {
              return HomePage(uid: snapshot.data!);
            } else {
              return SignInScreen();
            }
          }
        },
      ),
    );
  }

  Future<String?> _checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Column(
        children: [
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(labelText: 'Phone Number'),
          ),
          ElevatedButton(
            onPressed: _sendCode,
            child: Text('Send OTP'),
          ),
          TextField(
            controller: _otpController,
            decoration: InputDecoration(labelText: 'Enter OTP'),
          ),
          ElevatedButton(
            onPressed: _signIn,
            child: Text('Verify OTP'),
          ),
          Text(_statusMessage),  // Display the status message
        ],
      ),
    );
  }

  Future<void> _sendCode() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Automatic handling of the code sent
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _statusMessage = 'Failed to send code: ${e.message}';
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _statusMessage = 'Code sent successfully';
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> _signIn() async {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _otpController.text,
    );

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Send token to backend to create or authenticate user
      String? idToken = await userCredential.user?.getIdToken();
      if (idToken != null) {
        final response = await _sendTokenToBackend(idToken);
        if (response != null && response['status'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('uid', response['uid']);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(uid: response['uid'])),
          );
        }
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to sign in: ${e.toString()}';
      });
    }
  }

  Future<Map<String, dynamic>?> _sendTokenToBackend(String idToken) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/client/auth/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'idToken': idToken,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      setState(() {
        _statusMessage = 'Failed to authenticate: ${response.body}';
      });
      return null;
    }
  }
}
