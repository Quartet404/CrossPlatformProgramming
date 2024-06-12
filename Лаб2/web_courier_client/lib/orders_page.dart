import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'order_details_page.dart';

class OrdersPage extends StatefulWidget {
  final String uid;

  OrdersPage({required this.uid});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List<dynamic> orders = [];
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/client/orders/${widget.uid}/'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Мої замовлення',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: orders.isEmpty
          ? Center(child: Text(_statusMessage))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          var order = orders[index];
          return ListTile(
            title: Text('№ ${order['id']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('від ${order['timestamp']}'),
                Text(
                  order['status'] == 'Доставлено' ? 'Доставлено' : 'Виконується',
                  style: TextStyle(
                    color: order['status'] == 'Доставлено' ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            trailing: Text('${order['total']} ₴'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderDetailsPage(orderId: order['id'])),
              );
            },
          );
        },
      ),
    );
  }
}
