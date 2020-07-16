import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final List<CartItem> products;
  final double total;
  final DateTime dateTime;

  OrderItem({
    this.id,
    this.products,
    this.total,
    this.dateTime,
  });
}

class Order with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String token;
  final String userId;

  Order(this.token,this.userId,this._orders);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = 'https://shop-data-e115d.firebaseio.com/orders/$userId.json?auth=$token';
    final response = await http.get(url);
    final List<OrderItem> loadedList = [];
    final _extractedData = json.decode(response.body) as Map<String, dynamic>;
    if(_extractedData!=null){
    _extractedData.forEach((orderId, orderData) {
      loadedList.add(OrderItem(
        id: orderId,
        dateTime: DateTime.parse(orderData['dateTime']),
        total: orderData['total'],
        products: (orderData['products'] as List<dynamic>).map((e) => CartItem(
          id: e['id'],
          price: e['price'],
          title: e['title'],
          quantity: e['quantity'],
        )).toList(),
      ));
    });
    }
    _orders=loadedList;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://shop-data-e115d.firebaseio.com/orders/$userId.json?auth=$token';
    final timeStamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'total': total,
        'dateTime': timeStamp.toIso8601String(),
        'products': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'price': cp.price,
                  'quantity': cp.quantity,
                })
            .toList(),
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        products: cartProducts,
        total: total,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }
}
