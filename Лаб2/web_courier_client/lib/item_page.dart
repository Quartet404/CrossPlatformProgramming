import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_drawer.dart';

class ItemPage extends StatefulWidget {
  final int itemId;
  final String categoryName;
  final List<dynamic> cartItems;
  final Function(dynamic) onAddToCart;
  final Function(dynamic) onRemoveItem;
  final String customerUid;
  final String businessId;

  ItemPage({
    required this.itemId,
    required this.categoryName,
    required this.cartItems,
    required this.onAddToCart,
    required this.onRemoveItem,
    required this.customerUid,
    required this.businessId,
  });

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  dynamic item;
  String _statusMessage = '';
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/business/items/${widget.itemId}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        item = data['item'];
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to load item: ${response.body}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: CartDrawer(
        cartItems: widget.cartItems,
        onRemoveItem: widget.onRemoveItem,
        customerUid: widget.customerUid,
        businessId: widget.businessId,
      ),
      body: item == null
          ? Center(child: Text(_statusMessage))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            item['image'] != null
                ? Image.network(
              item['image'],
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            )
                : Image.asset(
              'assets/placeholder.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16.0),
            Text(
              item['name'] ?? 'No name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text('Категорія: ${widget.categoryName}'),
            SizedBox(height: 8.0),
            Text(item['description'] ?? 'No description'),
            SizedBox(height: 8.0),
            Text('\$${item['price']}',
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_quantity > 1) _quantity--;
                    });
                  },
                ),
                Text('$_quantity', style: TextStyle(fontSize: 20)),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () {
                final newItem = {
                  'id': widget.itemId,
                  'name': item['name'],
                  'price': item['price'],
                  'quantity': _quantity,
                  'image': item['image'],
                };
                widget.onAddToCart(newItem);
              },
              icon: Icon(Icons.shopping_cart, color: Colors.white),
              label: Text('Додати у кошик', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
