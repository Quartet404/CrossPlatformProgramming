import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'item_page.dart';
import 'cart_drawer.dart';

class ItemsPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final List<dynamic> cartItems;
  final Function(dynamic) onAddToCart;
  final Function(dynamic) onRemoveItem;
  final String customerUid;
  final String businessId;

  ItemsPage({
    required this.categoryId,
    required this.categoryName,
    required this.cartItems,
    required this.onAddToCart,
    required this.onRemoveItem,
    required this.customerUid,
    required this.businessId,
  });

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<dynamic> items = [];
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/business/categories/${widget.categoryId}/items/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        items = data['items'];
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to load items: ${response.body}';
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
      body: items.isEmpty
          ? Center(child: Text(_statusMessage))
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          var imageUrl = item['image'] != null
              ? '${item['image']}'
              : 'assets/placeholder.png'; // Локальний ресурс як заглушка
          return Card(
            margin: EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ItemPage(
                    itemId: item['id'],
                    categoryName: widget.categoryName,
                    cartItems: widget.cartItems,
                    onAddToCart: widget.onAddToCart,
                    onRemoveItem: widget.onRemoveItem,
                    customerUid: widget.customerUid,
                    businessId: widget.businessId,
                  )),
                );
              },
              child: Row(
                children: [
                  item['image'] != null
                      ? Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  )
                      : Image.asset(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? 'No name',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(item['description'] ?? 'No description'),
                      Text('\$${item['price']}'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
