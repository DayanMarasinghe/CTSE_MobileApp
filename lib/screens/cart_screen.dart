import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CollectionReference _cartData =
      FirebaseFirestore.instance.collection('cart');
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _productName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      //using the streambuilder to view all product for the particular customer
      body: StreamBuilder(
        stream: _cartData.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['productname']),
                    // ignore: prefer_interpolation_to_compose_strings
                    subtitle: Text(
                        'Price : ${documentSnapshot['price']} , Quantity : ${documentSnapshot['quantity']}'),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () => _updateItem(documentSnapshot),
                              icon: const Icon(Icons.edit)),
                          IconButton(
                              onPressed: () =>
                                  _deleteItemFromCart(documentSnapshot.id),
                              icon: const Icon(Icons.delete))
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),

      //add new item into the cart - manual process
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createItem(),
        child: const Icon(Icons.add),
      ),
    );
  }

  //Method to delete the cart item using the product id
  Future<void> _deleteItemFromCart(String productID) async {
    await _cartData.doc(productID).delete();

    //delete snackbar
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You removed a item from the cart")));
  }

  //Method to create  item details
  Future<void> _createItem([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _productIdController.text = documentSnapshot['productid'];
      _customerIdController.text = documentSnapshot['customerid'];
      _quantityController.text = documentSnapshot['quantity'];
      _priceController.text = documentSnapshot['price'];
      _productName.text = documentSnapshot['productname'];
    }

    //TODO manual input for the user
  }

  //Method to update cart item details
  Future<void> _updateItem([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _productIdController.text = documentSnapshot['productid'];
      _customerIdController.text = documentSnapshot['customerid'];
      _quantityController.text = documentSnapshot['quantity'];
      _priceController.text = documentSnapshot['price'];
      _productName.text = documentSnapshot['productname'];
    }

    //TODO bottom input to update the cart items
  }
}
