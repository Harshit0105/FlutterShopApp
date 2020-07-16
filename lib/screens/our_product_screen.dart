import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../providers/products_provider.dart';
import '../widgets/our_product_item.dart';
import '../screens/edit_product_screen.dart';

class OurProductScreen extends StatelessWidget {
  static const routeName = "/our-product";

  Future<void> _refreshData(BuildContext context) {
    return Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final _product = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Our Products"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshData(context),
        builder: (ctx, snapShot) =>
            snapShot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshData(context),
                    child: Consumer<ProductsProvider>(
                      builder: (ctx, _product, _) => Padding(
                        padding: EdgeInsets.all(10),
                        child: ListView.builder(
                          itemBuilder: (ctx, i) => OurProductItem(
                              id: _product.items[i].id,
                              title: _product.items[i].title,
                              imageUrl: _product.items[i].imageUrl),
                          itemCount: _product.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
