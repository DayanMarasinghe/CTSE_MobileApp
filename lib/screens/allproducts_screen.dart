import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market/screens/cart_screen.dart';

class ProductListView extends StatelessWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('product_view').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot product = snapshot.data!.docs[index];
              return ListTile(
                title: Text(product['name']),
                subtitle: Text('Rs.${product['price']}/='),
                trailing: IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CartScreen(
                                  productId: product.id,
                                  productName: product['name'],
                                  price: product['price'],
                                )));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
