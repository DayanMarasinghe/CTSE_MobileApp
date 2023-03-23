import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CartScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String price;
  const CartScreen(
      {Key? key,
      required this.productId,
      required this.productName,
      required this.price})
      : super(key: key);

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

  var customerId = "123123";

  @override
  void initState() {
    super.initState();
    //calling adding item method to cart at the start
    _createItem(
        widget.productId, widget.productName, widget.price, customerId, "1");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      //using the streambuilder to view all product for the particular customer
      body: StreamBuilder(
        stream:
            _cartData.where('customerid', isEqualTo: customerId).snapshots(),
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
                    title: Text(
                      '\n ${documentSnapshot['productname']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // ignore: prefer_interpolation_to_compose_strings
                    subtitle: Text(
                        '\nPrice for each : ${documentSnapshot['price']} \nQuantity : ${documentSnapshot['quantity']}\n'),
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
    );
  }

  //Method to delete the cart item using the product id
  Future<void> _deleteItemFromCart(String productID) async {
    await _cartData.doc(productID).delete();

    //delete snackbar
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You removed an item from the cart")));
  }

  //Method to create  item details that will be called in the init
  Future<void> _createItem(String productId, String productName, String price,
      String customerID, String qty) async {
    _productIdController.text = productId;
    _customerIdController.text = customerID;
    _quantityController.text = qty;
    _priceController.text = price;
    _productName.text = productName;

    final String? dbProductID = _productIdController.text;
    final String? dbCustomerID = _customerIdController.text;
    final String? dbProductName = _productName.text;
    final String? dbPrice = _priceController.text;
    final String? dbQuantity = _quantityController.text;

    //validation for the passed values
    if (dbProductID != null ||
        dbCustomerID != null ||
        dbProductName != null ||
        dbPrice != null ||
        dbQuantity != null) {
      //insert to collection
      await _cartData.add({
        "productid": dbProductID,
        "customerid": dbCustomerID,
        "quantity": dbQuantity,
        "price": dbPrice,
        "productname": dbProductName
      });

      //notify user
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Added to cart")));
    } else {
      //notify user
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Oops! Can't add the item to the cart, Try again")));
    }
  }

  //Method to update cart item details
  Future<void> _updateItem([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _productIdController.text = documentSnapshot['productid'];
      _customerIdController.text = documentSnapshot['customerid'];
      _quantityController.text = documentSnapshot['quantity'];
      _priceController.text = documentSnapshot['price'];
      _productName.text = documentSnapshot['productname'];
    }

    //bottom input to update the cart items
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  //letting user only update the quantity
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter
                        .digitsOnly, //Only allow digit keyboard
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text('Update'),
                  onPressed: () async {
                    final String? quantity = _quantityController.text;
                    //validation for the quantity input
                    if (quantity != null) {
                      await _cartData
                          .doc(documentSnapshot!.id)
                          .update({"quantity": quantity});
                      //clear input field
                      _quantityController.text = '';

                      //hide the bottom prompt view
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }
}
