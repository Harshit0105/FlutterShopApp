import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products_provider.dart';

class OurProductItem extends StatelessWidget {
  final String id;
  final String imageUrl;
  final String title;
  OurProductItem({
    this.id,
    this.title,
    this.imageUrl,
  });
  @override
  Widget build(BuildContext context) {
    final scaffold=Scaffold.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      title: Text(title),
      trailing: FittedBox(
        child: Row(
//          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit,color: Theme.of(context).accentColor,),
              onPressed: (){
                Navigator.of(context).pushNamed(EditProductScreen.routeName,arguments: id);
              },
            ),

            IconButton(
              icon: Icon(Icons.delete,color: Theme.of(context).errorColor,),
              onPressed: () async {
                try {
                  await Provider.of<ProductsProvider>(context, listen: false,)
                      .deleteProduct(id);
                }
                catch(error){
                  scaffold.showSnackBar(SnackBar(
                    content: Text('Deleting Failed!!'),
                  ),);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
