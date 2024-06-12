import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderDetailsPage extends StatefulWidget {
  final int orderId;

  OrderDetailsPage({required this.orderId});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  dynamic orderDetails;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/client/order/${widget.orderId}/details/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        orderDetails = data['order'];
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to load order details: ${response.body}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Деталі замовлення', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: orderDetails == null
          ? Center(child: Text(_statusMessage))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Замовлення № ${orderDetails['id']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            Text('Статус: ${orderDetails['status']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8.0),
            Text('Час: ${orderDetails['timestamp']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16.0),
            Text('Товари:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: orderDetails['items'].length,
                itemBuilder: (context, index) {
                  var item = orderDetails['items'][index];
                  return ListTile(
                    leading: item['image'] != null
                        ? Image.network(item['image'])
                        : Icon(Icons.shopping_cart),
                    title: Text(item['name']),
                    subtitle: Text('Ціна: ${item['price']} грн\nКількість: ${item['quantity']}'),
                  );
                },
              ),
            ),
            if (orderDetails['status'] == 'Доставляється')
              SizedBox(
                height: 300,
                child: Center(
                  child: Text('Тут буде карта з місцезнаходженням кур\'єра', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
