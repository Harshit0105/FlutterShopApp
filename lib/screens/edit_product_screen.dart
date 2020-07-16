import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "edit-product";
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocus = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _initValue = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };
  var _initSet = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_initSet) {
      final _productId = ModalRoute.of(context).settings.arguments as String;
      if (_productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(
          context,
          listen: false,
        ).findById(_productId);
        _initValue = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _initSet = false;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _imageUrlFocus.addListener(_updateUrl);
    super.initState();
  }

  void _updateUrl() {
    if (!_imageUrlFocus.hasFocus) {
      if ((!_imageUrlController.text.startsWith("http") &&
              !_imageUrlController.text.startsWith("https")) ||
          (!_imageUrlController.text.endsWith(".jpg") &&
              !_imageUrlController.text.endsWith(".png") &&
              !_imageUrlController.text.endsWith(".jpeg"))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final _isValid = _form.currentState.validate();
    if (!_isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<ProductsProvider>(
        context,
        listen: false,
      ).updateProduct(_editedProduct.id, _editedProduct);

    } else {
      try {
        await Provider.of<ProductsProvider>(
          context,
          listen: false,
        ).addProduct(_editedProduct);
      } catch (error) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Error occur"),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
//      finally{
//        setState(() {
//          _isLoading = false;
//        });
//        Navigator.of(context).pop();
//      }

    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _imageUrlFocus.removeListener(_updateUrl);
    _imageUrlFocus.dispose();
    _priceFocusNode.dispose();
    _descriptionNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(10),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValue['title'],
                      decoration: InputDecoration(
                        labelText: "Title",
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Provide Title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: value,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          description: _editedProduct.description,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue['price'],
                      decoration: InputDecoration(
                        labelText: "Price",
                      ),
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please provide price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please provide valid numbers';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please provide price greater than zero';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(_descriptionNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: _editedProduct.title,
                          price: double.parse(value),
                          imageUrl: _editedProduct.imageUrl,
                          description: _editedProduct.description,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValue['description'],
                      decoration: InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      focusNode: _descriptionNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Provide description';
                        }
                        if (value.length < 10) {
                          return 'Please Provide description more than 10 characters';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: _editedProduct.title,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          description: value,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
//                  mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              top: 5,
                              right: 8,
                            ),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            alignment: Alignment.center,
                            child: _imageUrlController.text.isEmpty
                                ? Text(
                                    "Enter URL",
                                    textAlign: TextAlign.center,
                                  )
                                : Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: "ImageUrl",
                              ),
                              keyboardType: TextInputType.url,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocus,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please provide Image Url';
                                }
                                if (!value.startsWith("http") &&
                                    !value.startsWith("https")) {
                                  return 'Please provide valid url';
                                }
                                if (!value.endsWith(".jpg") &&
                                    !value.endsWith(".png") &&
                                    !value.endsWith(".jpeg")) {
                                  return 'Please provide valid formate';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  isFavorite: _editedProduct.isFavorite,
                                  title: _editedProduct.title,
                                  price: _editedProduct.price,
                                  imageUrl: value,
                                  description: _editedProduct.description,
                                );
                              },
                              onFieldSubmitted: (value) => _saveForm(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
