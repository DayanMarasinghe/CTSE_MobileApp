import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';

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
  final Location _location = Location();

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Your Profile'),
  //     ),
  //     // Using StreamBuilder to display all products from Firestore in real-time
  //     body: StreamBuilder(
  //       stream: _cusData.snapshots(),
  //       builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
  //         if (streamSnapshot.hasData) {
  //           return ListView.builder(
  //             itemCount: streamSnapshot.data!.docs.length,
  //             itemBuilder: (context, index) {
  //               final DocumentSnapshot documentSnapshot =
  //                   streamSnapshot.data!.docs[index];
  //               return Card(
  //                 margin: const EdgeInsets.all(10),
  //                 child: ListTile(
  //                   title: Text(documentSnapshot['name']),
  //                   subtitle: Text(documentSnapshot['email']),
  //                   trailing: SizedBox(
  //                     width: 100,
  //                     child: Row(
  //                       children: [
  //                         // Press this button to edit a single product
  //                         IconButton(
  //                             icon: const Icon(Icons.edit),
  //                             onPressed: () =>
  //                                 _createOrUpdate(documentSnapshot)),
  //                         IconButton(
  //                             icon: const Icon(Icons.delete),
  //                             onPressed: () =>
  //                                 _deleteProduct(documentSnapshot.id)),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //           );
  //         }

  //         return const Center(
  //           child: CircularProgressIndicator(),
  //         );
  //       },
  //     ),
  //   );
  // }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Your Profile'),
    ),
    body: FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final SharedPreferences prefs = snapshot.data as SharedPreferences;
        final String cusId = prefs.getString('cusId') ?? '';

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('customers')
              .doc(cusId)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final DocumentSnapshot documentSnapshot = snapshot.data!;
            final Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
            final String name = data['name'] as String;
            final String email = data['email'] as String;

            return ListView(
              padding: const EdgeInsets.all(10),
              children: [
                Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(email),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _createOrUpdate(documentSnapshot),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteProduct(documentSnapshot.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
  );
}


  /// Method to delete a user by id
  // Future<void> _deleteProduct(String customerId) async {
  //   await _cusData.doc(customerId).delete();

  //   // Show a snackbar
  //   ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('You have successfully deleted account')));
  // }

Future<void> _deleteProduct(String customerId) async {
  bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this account?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmDelete) {
    await _cusData.doc(customerId).delete();

    // Navigate to HomeScreen
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
      (route) => false,
    );

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have successfully deleted account')));


  }
}

  /// Method to update user details
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
                  child: Text(action == 'create' ? 'Create' : 'New Location'),
                  onPressed: () async {
                    bool _serviceEnabled;
                    PermissionStatus _permissionGranted;
                    LocationData _locationData;

                    _serviceEnabled = await _location.serviceEnabled();
                    if (!_serviceEnabled) {
                      _serviceEnabled = await _location.requestService();
                      if (!_serviceEnabled) {
                        return;
                      }
                    }

                    _permissionGranted = await _location.hasPermission();
                    if (_permissionGranted == PermissionStatus.denied) {
                      _permissionGranted = await _location.requestPermission();
                      if (_permissionGranted != PermissionStatus.granted) {
                        return;
                      }
                    }

                    // Get location data
                    _locationData = await _location.getLocation();

                      if (action == 'update') {
                        // Update the product
                        await _cusData.doc(documentSnapshot!.id).update({
                          "latitude": _locationData.latitude,
                          "longitude": _locationData.longitude,
                        });
                      }
                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Your location was successfully updated")));
                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                  },
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
                      if (action == 'update') {
                        // Update the user
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
