import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import './product_item.dart';
import '../providers/products_provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool _showFavoritiesOnly;
  ProductsGrid(this._showFavoritiesOnly);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final _products =
        _showFavoritiesOnly ? productsData.favorateItems : productsData.items;

    return GridView.builder(
      itemCount: _products.length,
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) => ChangeNotifierProvider.value(
        value: _products[index],
        //builder: (context) => _products[index],
        child: ProductItem(
            // _products[index].id,
            // _products[index].title,
            // _products[index].imageUrl,
            ),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
