import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';

import '../providers/products_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  static const routeName = '/add-edit-product';
  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageurlFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _product = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );

  var _initProductValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageurlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;

      if (productId != null) {
        _product = Provider.of<Products>(context).findById(productId);
        _initProductValues = {
          'title': _product.title,
          'description': _product.description,
          'price': _product.price.toString(),
          // 'imageUrl': _product.imageUrl,
          'imageUrl': ''
        };
        _imageUrlController.text = _product.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageurlFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveProduct() async {
    final bool validation = _formKey.currentState.validate();
    if (!validation) {
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (_product.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_product.id, _product);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_product);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('An error ocurred'),
            content: Text('Alguma coisa não correu bem'),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _imageurlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageurlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProduct,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initProductValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Por favor, insira um titulo';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _product = Product(
                          title: value,
                          id: _product.id,
                          isFavorite: _product.isFavorite,
                          imageUrl: _product.imageUrl,
                          price: _product.price,
                          description: _product.description,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initProductValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Por favor, insira um preço';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Por favor, insira um numero valido';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Por favor, insira um preço maior do que zero';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _product = Product(
                          title: _product.title,
                          id: _product.id,
                          isFavorite: _product.isFavorite,
                          imageUrl: _product.imageUrl,
                          price: double.parse(value),
                          description: _product.description,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initProductValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      maxLines: 4,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Por favor, insira uma descrição do produto';
                        }
                        if (value.length < 10) {
                          return 'Por favor, insira pelo menos 10 caracteres (letras)';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _product = Product(
                          title: _product.title,
                          id: _product.id,
                          isFavorite: _product.isFavorite,
                          imageUrl: _product.imageUrl,
                          price: _product.price,
                          description: value,
                        );
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? Text(
                                  'Enter a  url',
                                  textAlign: TextAlign.center,
                                )
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageurlFocusNode,
                            onFieldSubmitted: (value) {
                              _saveProduct();
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Por favor, insira uma Url';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Por favor, insira uma Url valida';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Por favor, insira uma Url valida';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _product = Product(
                                title: _product.title,
                                id: _product.id,
                                isFavorite: _product.isFavorite,
                                imageUrl: value,
                                price: _product.price,
                                description: _product.description,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
