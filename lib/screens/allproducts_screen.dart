import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:market/screens/cart_screen.dart';
import 'package:market/screens/cus_reg.dart';

class ProductListView extends StatelessWidget {
  const ProductListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
          leading: IconButton(
          icon: Icon(Icons.person),
          onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CusReg()),
                );
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
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
              return Card(
                child: ListTile(
                  leading: Image.network(
                    product['imgURL'],
                    height: 80.0,
                    width: 80.0,
                    fit: BoxFit.cover,
                  ),
                  title: Text(product['name']),
                  subtitle: Text('Rs.${product['price'].toStringAsFixed(2)}/='),
                  trailing: IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CartScreen(
                                    productId: product.id,
                                    productName: product['name'],
                                    price: product['price'].toStringAsFixed(2),
                                  )));
                    },
                  ),
                ),
              );
            },
          );

          // return ListView.builder(
          //   itemCount: snapshot.data!.docs.length,
          //   itemBuilder: (context, index) {
          //     DocumentSnapshot product = snapshot.data!.docs[index];
          //     return ListTile(
          //       title: Text(product['name']),
          //       subtitle: Text('Rs.${product['price']}/='),
          //       trailing: IconButton(
          //         icon: Icon(Icons.shopping_cart),
          //         onPressed: () {
          //           Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                   builder: (context) => CartScreen(
          //                         productId: product.id,
          //                         productName: product['name'],
          //                         price: product['price'],
          //                       )));
          //         },
          //       ),
          //     );
          //   },
          // );
        },
      ),
    );
  }
}
