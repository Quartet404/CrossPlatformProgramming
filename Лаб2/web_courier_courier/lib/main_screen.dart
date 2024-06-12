import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart';
import 'dart:async';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _statusMessage = '';
  bool _isOnShift = false;
  List<dynamic> orders = [];
  Location location = new Location();
  bool _isSendingLocation = false;

  Future<void> _toggleShift() async {
    final prefs = await SharedPreferences.getInstance();
    final courierId = prefs.getString('courier_id') ?? '';

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/courier/toggle_shift/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'courier_id': courierId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _isOnShift = !_isOnShift;
        _statusMessage = _isOnShift ? 'Shift started' : 'Shift ended';
        if (_isOnShift) {
          _startSendingLocation();
        }
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to toggle shift: ${response.body}';
      });
    }
  }

  Future<void> _loadOrders() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/courier/orders/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        orders = data['orders'];
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to load orders: ${response.body}';
      });
    }
  }

  Future<void> _acceptOrder(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final courierId = prefs.getString('courier_id') ?? '';

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/courier/accept_order/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'courier_id': courierId,
        'order_id': orderId,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _statusMessage = 'Order accepted';
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to accept order: ${response.body}';
      });
    }
  }

  Future<void> _sendLocation() async {
    if (!_isOnShift) return;

    final prefs = await SharedPreferences.getInstance();
    final courierId = prefs.getString('courier_id') ?? '';

    LocationData _locationData = await location.getLocation();

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/courier/send_location/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'courier_id': courierId,
        'latitude': _locationData.latitude,
        'longitude': _locationData.longitude,
      }),
    );

    if (response.statusCode != 200) {
      setState(() {
        _statusMessage = 'Failed to send location: ${response.body}';
      });
    }
  }

  void _startSendingLocation() {
    if (!_isSendingLocation) {
      _isSendingLocation = true;
      Timer.periodic(Duration(seconds: 5), (timer) {
        if (_isOnShift) {
          _sendLocation();
        } else {
          timer.cancel();
          _isSendingLocation = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courier Main Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _toggleShift,
              child: Text(_isOnShift ? 'End Shift' : 'Start Shift'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadOrders,
              child: Text('Load Orders'),
            ),
            SizedBox(height: 20),
            Text(_statusMessage),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  var order = orders[index];
                  return ListTile(
                    title: Text('Order #${order['id']}'),
                    subtitle: Text('Status: ${order['status']}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _acceptOrder(order['id']);
                      },
                      child: Text('Accept'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
