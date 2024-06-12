import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartDrawer extends StatelessWidget {
  final List<dynamic> cartItems;
  final Function(dynamic) onRemoveItem;
  final String customerUid;
  final String businessId;

  CartDrawer({required this.cartItems, required this.onRemoveItem, required this.customerUid, required this.businessId});

  Future<void> _createOrder(BuildContext context) async {
    final url = 'http://10.0.2.2:8000/api/client/orders/';
    final headers = {'Content-Type': 'application/json; charset=UTF-8'};
    final body = jsonEncode({
      'customer_uid': customerUid,
      'business_id': businessId,
      'items': cartItems,
    });

    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 201) {
      // Замовлення успішно створене
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Замовлення успішно створене')),
      );
    } else {
      // Помилка при створенні замовлення
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка при створенні замовлення: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.green,
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Кошик',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                var item = cartItems[index];
                return ListTile(
                  leading: item['image'] != null
                      ? Image.network(item['image'])
                      : Icon(Icons.shopping_cart),
                  title: Text(item['name']),
                  subtitle: Text('Ціна: ${item['price']} грн\nКількість: ${item['quantity']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle),
                    onPressed: () {
                      onRemoveItem(item);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _createOrder(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check, color: Colors.white),
                  SizedBox(width: 8.0),
                  Text('Оформити замовлення', style: TextStyle(color: Colors.white)),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
