import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
            //calculate the total price from all the cart items according to quantity
            final total = streamSnapshot.data!.docs.fold<double>(
                0.0,
                (total, doc) =>
                    total +
                    (double.parse(doc['price']) * int.parse(doc['quantity'])));
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];
                      final priceEach = double.parse(documentSnapshot['price']);
                      final quantityEach =
                          int.parse(documentSnapshot['quantity']);
                      final totalEach = priceEach * quantityEach;
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(
                            '\n ${documentSnapshot['productname']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '\n\tPrice for each: Rs.${priceEach.toStringAsFixed(2)}/=',
                                ),
                                Text(
                                  '\n\tQuantity: $quantityEach',
                                ),
                                Text(
                                  '\n\tTotal: Rs.${totalEach.toStringAsFixed(2)}/=',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: () =>
                                        _updateItem(documentSnapshot),
                                    icon: const Icon(Icons.edit)),
                                IconButton(
                                    onPressed: () => _deleteItemFromCart(
                                        documentSnapshot.id),
                                    icon: const Icon(Icons.delete))
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  //View the total amount for all product
                  height: 50,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      'Total: Rs.${total.toStringAsFixed(2)}/=',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
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
    showToastMessage("You removed an item from the cart");
  }

  Future<void> _createItem(String productId, String productName, String price,
      String customerID, String qty) async {
    // Get the current cart items for the customer
    final cartItems = await _cartData
        .where('customerid', isEqualTo: customerID)
        .where('productid', isEqualTo: productId)
        .get();

    // Check if the item already exists in the cart
    if (cartItems.docs.isNotEmpty) {
      // Update the quantity of the existing item
      final existingCartItem = cartItems.docs.first;
      final existingQuantity = int.parse(existingCartItem['quantity']);
      final newQuantity = existingQuantity + int.parse(qty);
      await existingCartItem.reference
          .update({'quantity': newQuantity.toString()});

      // Notify user
      showToastMessage("Item quantity updated in cart");
    } else {
      // Insert the item into the cart
      await _cartData.add({
        "productid": productId,
        "customerid": customerID,
        "quantity": qty,
        "price": price,
        "productname": productName
      });

      // Notify user
      showToastMessage("Added to cart");
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

  //Method to show the toast message
  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
      fontSize: 12.0,
    );
  }
}
