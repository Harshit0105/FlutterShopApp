import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/product_item.dart';

class ProductGridView extends StatelessWidget {
  final bool showFav;
  ProductGridView(this.showFav);
  @override
  Widget build(BuildContext context) {
    final _productProvider = Provider.of<ProductsProvider>(context);
    final _product = showFav? _productProvider.favoriteItems :_productProvider.items;
    return GridView.builder(
      padding: const EdgeInsets.all(5),
      itemBuilder: (ctx, index) {
        return ChangeNotifierProvider.value(
          value: _product[index],
          child: ProductItem(),
        );
      },
      itemCount: _product.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
