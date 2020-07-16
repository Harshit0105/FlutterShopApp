import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/products_provider.dart';

import '../screens/cart_screen.dart';
import '../widgets/product_grid.dart';
import '../widgets/Badge.dart';
import '../providers/cart.dart';
import '../widgets/app_drawer.dart';

enum FilterScreen {
  Favorite,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showFavoriteOnly = false;
  var _isInit = true;
  var _isLoading=true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((value) => setState((){
        _isLoading=false;
      }));
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MyShop"),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterScreen selected) {
              setState(() {
                if (selected == FilterScreen.Favorite)
                  _showFavoriteOnly = true;
                else
                  _showFavoriteOnly = false;
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                child: Text("Only Favorite"),
                value: FilterScreen.Favorite,
              ),
              PopupMenuItem(
                child: Text("Show All"),
                value: FilterScreen.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body:_isLoading? Center(child:CircularProgressIndicator(),):ProductGridView(_showFavoriteOnly),
    );
  }
}
