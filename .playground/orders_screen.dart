import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false;
  @override
  void initState() {
    _isLoading = true;

    //Future.delayed(Duration.zero).then((onValue) async {
    Provider.of<Orders>(context, listen: false)
        .fetchAndSetOrders()
        .then((onValue) {
      setState(() {
        _isLoading = false;
      });
    });
    //});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _ordersData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Pay for your orders'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _ordersData.orders.length,
              itemBuilder: (context, index) => OrderItem(
                _ordersData.orders[index],
              ),
            ),
      drawer: AppDrawer(),
    );
  }
}
