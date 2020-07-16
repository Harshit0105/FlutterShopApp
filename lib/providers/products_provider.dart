import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _item = [];

  List<Product> get items {
    return [..._item];
  }

  final String authToken;
  final String userId;
  ProductsProvider(this.authToken, this.userId, this._item);

  List<Product> get favoriteItems {
    return _item.where((element) => element.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([bool fetchByUser=false]) async {
    final fetchString=fetchByUser?'orderBy="creatorId"&equalTo="$userId"':'';
    var url =
        'https://shop-data-e115d.firebaseio.com/products.json?auth=$authToken&$fetchString';
    final resposne = await http.get(url);
    final _extractedData = json.decode(resposne.body) as Map<String, dynamic>;
    final List<Product> loadedList = [];
    if (_extractedData != null) {
      url =
          'https://shop-data-e115d.firebaseio.com/userFavorite/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final  favoriteData = json.decode(favoriteResponse.body);
      print(favoriteData);
      _extractedData.forEach((prodId, prodData) {
        loadedList.add(Product(
          id: prodId,
          title: prodData["title"],
          price: prodData['price'],
          description: prodData['description'],
          imageUrl: prodData['imageUrl'],
          isFavorite: favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _item = loadedList;
      notifyListeners();
    }
//    print(json.decode(resposne.body));
  }

  Product findById(String id) {
    return _item.firstWhere(
      (element) => element.id == id,
    );
  }

  Future<void> addProduct(Product products) async {
    const url = 'https://shop-data-e115d.firebaseio.com/products.json';
    var js = json.encode({
      'title': products.title,
      'price': products.price,
      'description': products.description,
      'imageUrl': products.imageUrl,
      'creatorId':userId,
    });
//    print(js);
    try {
      final response = await http.post(
        url,
        body: js,
        headers: {
          "Accept": "application/json",
        },
      );
      final resp = json.decode(response.body);
      final _product = Product(
        id: resp["name"],
        title: products.title,
        price: products.price,
        description: products.description,
        imageUrl: products.imageUrl,
      );
      _item.add(_product);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final _prodIndex = _item.indexWhere((element) => element.id == id);
    if (_prodIndex >= 0) {
      final url = 'https://shop-data-e115d.firebaseio.com/products/$id.json';
      try {
        await http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'price': newProduct.price,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
            }));
      } catch (error) {
        print(error);
      }
      _item[_prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://shop-data-e115d.firebaseio.com/products/$id.json';
    final existingProductIndex =
        _item.indexWhere((element) => element.id == id);
    var existingProduct = _item[existingProductIndex];
    _item.removeWhere((element) => element.id == id);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _item.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete Product");
    }
    existingProduct = null;
  }
}
