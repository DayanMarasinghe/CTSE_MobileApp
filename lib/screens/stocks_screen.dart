import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/widgets/NavDrawer.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({Key? key}) : super(key: key);

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  final CollectionReference _stocksData =
  FirebaseFirestore.instance.collection('stocks');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isUploading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks'),
      ),
      drawer: const NavDrawer(),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _stocksData.snapshots(),
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
                    // leading: ConstrainedBox(
                    //   constraints: const BoxConstraints(
                    //     minWidth: 44,
                    //     minHeight: 44,
                    //     maxWidth: 64,
                    //     maxHeight: 64,
                    //   ),
                    //   child: Image.network(documentSnapshot['imgURL'],
                    //       fit: BoxFit.cover),
                    // ),
                    title: Text(documentSnapshot['supplier']),
                    // subtitle: Text(documentSnapshot['price'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Press this button to edit a single product
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _showDeleteDialog(documentSnapshot)),
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

      /// Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Method to create or update product details
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
      _descriptionController.text = documentSnapshot['description'];
      // viewImg = documentSnapshot['imgURL'];
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration:
                  const InputDecoration(labelText: 'Product Description'),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                ),
                DropdownButton<String>(
                  items: <String>['A', 'B', 'C', 'D'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (_) {},
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(isUploading == true
                      ? "Uploading"
                      : action == 'create'
                      ? 'Create'
                      : 'Update'),
                  onPressed: () async {
                    final String? name = _nameController.text;
                    final String? description = _descriptionController.text;
                    final double? price =
                    double.tryParse(_priceController.text);

                    if (name != null && price != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _stocksData.add({
                          "name": name,
                          "price": price,
                          "description": description,
                          // "imgURL": uploadUrl
                        });
                      }

                      if (action == 'update') {
                        // Update the product
                        await _stocksData.doc(documentSnapshot!.id).update({
                          "name": name,
                          "price": price,
                          "description": description,
                          // "imgURL": uploadUrl.isNotEmpty ? uploadUrl : viewImg
                        });
                      }

                      // Clear the fields
                      _nameController.text = '';
                      _priceController.text = '';
                      _descriptionController.text = '';
                      // uploadUrl = '';
                      // _photo = null;

                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _showDeleteDialog(documentSnapshot) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure to delete this product'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                _deleteProduct(documentSnapshot.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Method to delete a stocks by id
  Future<void> _deleteProduct(String productId) async {
    await _stocksData.doc(productId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }
}
