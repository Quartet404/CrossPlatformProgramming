import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'items_page.dart';
import 'cart_drawer.dart';

class CategoriesPage extends StatefulWidget {
  final String storeName;
  final List<dynamic> cartItems;
  final Function(dynamic) onAddToCart;
  final Function(dynamic) onRemoveItem;
  final String customerUid;
  final String businessId;

  CategoriesPage({
    required this.storeName,
    required this.cartItems,
    required this.onAddToCart,
    required this.onRemoveItem,
    required this.customerUid,
    required this.businessId,
  });

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<dynamic> categories = [];
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/business/${widget.storeName}/categories/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        categories = data['categories'];
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to load categories: ${response.body}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Категорії товарів', style: TextStyle(color: Colors.white)),
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
      body: categories.isEmpty
          ? Center(child: Text(_statusMessage))
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          var category = categories[index];
          print(category['image']);
          var imageUrl = category['image'] != null
              ? '${category['image']}'
              : 'assets/placeholder.png'; // Локальний ресурс як заглушка
          return Card(
            margin: EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ItemsPage(
                    categoryId: category['id'],
                    categoryName: category['name'],
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
                  category['image'] != null
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
                        category['name'] ?? 'No name',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
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
