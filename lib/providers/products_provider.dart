import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exceptions.dart';

class Products with ChangeNotifier {
  final String _token;
  final String _userId;

  Products(this._token, this._userId, this._items);

  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  //var _showFavoritiesOnly = false;

  List<Product> get items {
    // if (_showFavoritiesOnly) {
    //   return _items.where((product) => product.isFavorite).toList();
    // }
    return [..._items];
  }

  // void showFavoritiesOnly() {
  //   _showFavoritiesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritiesOnly = false;
  //   notifyListeners();
  // }

  Product findById(String productId) {
    return _items.firstWhere((product) => product.id == productId);
  }

  List<Product> get favorateItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Future<void> addProduct(Product product) async {
    final url = 'https://shop-mz.firebaseio.com/products.json?auth=$_token';

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'creatorId': _userId,
          },
        ),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String productId, Product newProduct) async {
    final url =
        'https://shop-mz.firebaseio.com/products/$productId.json?auth=$_token';

    final productToUpdateIndex =
        _items.indexWhere((product) => product.id == productId);
    await http.patch(
      url,
      body: json.encode(
        {
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
        },
      ),
    );
    if (productToUpdateIndex >= 0) {
      _items[productToUpdateIndex] = newProduct;
      notifyListeners();
    } else {
      print('O producto que está actualizar não existe');
    }
  }

  Future<void> deleteProduct(String productId) async {
    final url =
        'https://shop-mz.firebaseio.com/products/$productId.json?auth=$_token';

    final existingProductIndex =
        _items.indexWhere((product) => product.id == productId);

    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Não foi possivel apagar esse produto');
    }
    existingProduct = null;
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"' : '';

    var url =
        'https://shop-mz.firebaseio.com/products.json?auth=$_token&$filterString';
    try {
      final response = await http.get(url);
      //print(json.decode(response.body));

      final dataFromServer = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> productsFromServer = [];

      if (dataFromServer == null) {
        return;
      }
      url =
          'https://shop-mz.firebaseio.com/userFavorities/$_userId.json?auth=$_token';

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      dataFromServer.forEach((prodId, prodData) {
        productsFromServer.add(
          Product(
            id: prodId,
            title: prodData['title'],
            price: prodData['price'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
          ),
        );
      });
      _items = productsFromServer;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
