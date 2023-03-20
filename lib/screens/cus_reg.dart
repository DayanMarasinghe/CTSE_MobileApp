import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CusReg extends StatefulWidget {
  const CusReg({Key? key}) : super(key: key);

  @override
  State<CusReg> createState() => _CusRegState();
}

class _CusRegState extends State<CusReg> {
  final CollectionReference _cusData =
      FirebaseFirestore.instance.collection('customers');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Customer'),
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _cusData.snapshots(),
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
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(documentSnapshot['email']),
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
                                  _deleteProduct(documentSnapshot.id)),
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

  /// Method to delete a product by id
  Future<void> _deleteProduct(String customerId) async {
    await _cusData.doc(customerId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  /// Method to create or update product details
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _passwordController.text = documentSnapshot['password'];
      _emailController.text = documentSnapshot['email'];
      _phoneController.text = documentSnapshot['phone'];
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
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? name = _nameController.text;
                    final String? password = _passwordController.text;
                    final String? email = _emailController.text;
                    final String? phone = _phoneController.text;
                    if (name != null &&
                        password != null &&
                        email != null &&
                        phone != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _cusData.add({
                          "name": name,
                          "password": password,
                          "email": email,
                          "phone": phone
                        });
                      }

                      if (action == 'update') {
                        // Update the product
                        await _cusData.doc(documentSnapshot!.id).update({
                          "name": name,
                          "password": password,
                          "email": email,
                          "phone": phone
                        });
                      }

                      // Clear the text fields
                      _nameController.text = '';
                      _passwordController.text = '';
                      _emailController.text = '';
                      _phoneController.text = '';

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
}
