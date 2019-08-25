import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  /* final String title;
  final double price;
  ProductDetailScreen(this.title, this.price); */
  static const routeName = '/product-details';
  @override
  Widget build(BuildContext context) {
    final _productId = ModalRoute.of(context).settings.arguments as String;

    final _loadedProduct =
        Provider.of<Products>(context, listen: false).findById(_productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(_loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_loadedProduct.title),
              background: Hero(
                tag: _loadedProduct.id,
                child: Image.network(
                  _loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                height: 10,
              ),
              Text(
                '${_loadedProduct.price} MT',
                style: TextStyle(color: Colors.grey, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  _loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              SizedBox(
                height: 700,
              )
            ]),
          ),
        ],
      ),
    );
  }
}
