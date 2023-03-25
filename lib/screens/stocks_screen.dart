import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:market/screens/drop_down.dart';
import '../core/widgets/NavDrawer.dart';
import 'package:intl/intl.dart';

var list = [];

class StocksScreen extends StatefulWidget {
  const StocksScreen({Key? key}) : super(key: key);

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  //get data from Firebase
  final CollectionReference _stocksData =
      FirebaseFirestore.instance.collection('stocks');

  final CollectionReference _productsData =
      FirebaseFirestore.instance.collection('products');

  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String viewImg = "";
  String dropdownValue = '';
  late Object product = '';
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    //save product list in list object
    FirebaseFirestore.instance.collection("products").get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          list.add(docSnapshot.data());
          print(docSnapshot.data());
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print(_productsData.doc());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocks'),
        backgroundColor: Colors.green,
      ),
      drawer: const NavDrawer(),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _stocksData.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          //check isEmpty
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                        maxWidth: 64,
                        maxHeight: 64,
                      ),
                      child: Image.network(documentSnapshot['product']['imgURL'],
                          fit: BoxFit.cover),
                    ),
                    title: Row(
                      children: [
                        Text(documentSnapshot['product']['name']),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child:
                              Text('- Qty : ${documentSnapshot['quantity']}'),
                        )
                      ],
                    ),
                    subtitle:  Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(documentSnapshot['supplier']),
                        Text('Updated date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                      ],
                    ),
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
                              onPressed: () =>
                                  _showDeleteDialog(documentSnapshot)),
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

      /// Add new stocks
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Method to create or update stocks details
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    // Clear the fields
    _supplierNameController.text = '';
    _quantityController.text = '';
    product = '';
    viewImg = '';
    dropdownValue = 'Pasta';
    selectedDate = DateTime.now();
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _supplierNameController.text = documentSnapshot['supplier'];
      _quantityController.text = documentSnapshot['quantity'].toString();
      viewImg = documentSnapshot['product']['imgURL'];
      dropdownValue = documentSnapshot['product']['name'];
      product = documentSnapshot['product'];
     // selectedDate = documentSnapshot['date'];

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
                Center(
                  child:viewImg.isNotEmpty ? ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.network(
                          viewImg,
                        ),
                  ):
                      Text('')
                  ,
                ),

                TextField(
                  controller: _supplierNameController,
                  decoration: const InputDecoration(labelText: 'Supplier Name'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
                  child: DropDown(onItemChanged: (value) {
                    // filter the full object of the product
                    List outputList =
                        list.where((o) => o['name'] == value).toList();
                    product = outputList[0];
                  },selectedValue : dropdownValue),
                ),
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 16.0), // Margin for the container
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Background color for the container
                        borderRadius: BorderRadius.circular(10.0), // Rounded corners for the container
                      ),
                      padding: EdgeInsets.all(16.0), // Padding for the container
                      child: Text(
                        'Selected date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          shadows: [
                            Shadow(
                              color: Colors.grey[300]!,
                              offset: Offset(-1.0, -1.0),
                              blurRadius: 2.0,
                            ),
                            Shadow(
                              color: Colors.grey[300]!,
                              offset: Offset(1.0, 1.0),
                              blurRadius: 2.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create'
                          ? 'Create'
                          : 'Update'),
                  onPressed: () async {
                    final String? suppliner = _supplierNameController.text;
                    final String? quantity = _quantityController.text;

                    if (suppliner != null) {
                      if (action == 'create') {
                        // Persist a new stocks to Firestore
                        await _stocksData.add({
                          "supplier": suppliner,
                          "quantity": quantity,
                          "product": product,
                          "date": selectedDate,
                          // "imgURL": uploadUrl
                        });
                      }

                      if (action == 'update') {
                        // Update the stocks
                        await _stocksData.doc(documentSnapshot!.id).update({
                          "supplier": suppliner,
                          "quantity": quantity,
                          "date": selectedDate,
                          // "imgURL": uploadUrl.isNotEmpty ? uploadUrl : viewImg
                        });
                      }

                      // Clear the fields
                      _supplierNameController.text = '';
                      _quantityController.text = '';
                      product = '';
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
          title: const Text('Delete Stock'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure to delete this Stock'),
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
                _deleteStock(documentSnapshot.id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Method to delete a stocks by id
  Future<void> _deleteStock(String stockId) async {
    await _stocksData.doc(stockId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('You have successfully deleted a stock')));
  }
}
