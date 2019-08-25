import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  final String _token;
  final String _userId;

  Orders(this._token, this._userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://shop-mz.firebaseio.com/orders/$_userId.json?auth=$_token';
    final response = await http.get(url);
    //print(json.decode(response.body));
    final List<OrderItem> ordersFromServer = [];
    final extratedData = json.decode(response.body) as Map<String, dynamic>;
    if (extratedData == null) {
      return;
    }
    extratedData.forEach((orderId, orderData) {
      ordersFromServer.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map(
                (cartItem) => CartItem(
                  id: cartItem['id'],
                  price: cartItem['price'],
                  quantity: cartItem['quantity'],
                  title: cartItem['title'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = ordersFromServer.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://shop-mz.firebaseio.com/orders/$_userId.json?auth=$_token';

    final timeStamp = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode(
        {
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map(
                (product) => {
                  'id': product.id,
                  'title': product.title,
                  'quantity': product.quantity,
                  'price': product.price,
                },
              )
              .toList(),
        },
      ),
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }
}
