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
      //TODO - Body should be added here

      //add new item into the cart - manual process
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdateCartItem(),
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

  //Method to create or update the cart item details
  Future<void> _createOrUpdateCartItem(
      [DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _productIdController.text = documentSnapshot['productid'];
      _customerIdController.text = documentSnapshot['customerid'];
      _quantityController.text = documentSnapshot['quantity'];
      _priceController.text = documentSnapshot['price'];
      _productName.text = documentSnapshot['productname'];
    }

    //TODO bottom prompt for user
  }
}
