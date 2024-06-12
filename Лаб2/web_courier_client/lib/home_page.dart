import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profile_screen.dart';
import 'orders_page.dart';
import 'categories_page.dart';
import 'cart_drawer.dart';

class HomePage extends StatefulWidget {
  final String uid;

  HomePage({required this.uid});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> stores = [];
  String _statusMessage = '';
  List<dynamic> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/client/stores/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        stores = data['stores'];
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to load stores: ${response.body}';
      });
    }
  }

  void _addToCart(dynamic item) {
    setState(() {
      bool itemExists = false;
      for (var cartItem in cartItems) {
        if (cartItem['id'] == item['id']) {
          cartItem['quantity'] += item['quantity'];
          itemExists = true;
          break;
        }
      }
      if (!itemExists) {
        cartItems.add(item);
      }
    });
  }

  void _removeFromCart(dynamic item) {
    setState(() {
      cartItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Всі магазини', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(uid: widget.uid)),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'delivery.ua © 2024',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.store, color: Colors.green),
              title: Text('Всі магазини'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.green),
              title: Text('Мої замовлення'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersPage(uid: widget.uid)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.green),
              title: Text('Профіль'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(uid: widget.uid)),
                );
              },
            ),
          ],
        ),
      ),
      body: stores.isEmpty
          ? Center(child: Text(_statusMessage))
          : ListView.builder(
        itemCount: stores.length,
        itemBuilder: (context, index) {
          var store = stores[index];
          var imageUrl = store['photo'] != null
              ? '${store['photo']}'
              : 'assets/placeholder.png'; // Локальний ресурс як заглушка
          return Card(
            margin: EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CategoriesPage(
                    storeName: store['username'],
                    cartItems: cartItems,
                    onAddToCart: _addToCart,
                    onRemoveItem: _removeFromCart,
                    customerUid: widget.uid,
                    businessId: store['username'],
                  )),
                );
              },
              child: Row(
                children: [
                  store['photo'] != null
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
                        store['username'] ?? 'No name',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(store['address'] ?? 'No address'),
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
