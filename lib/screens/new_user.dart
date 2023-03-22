import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:market/screens/cus_reg.dart';
import 'package:location/location.dart';

class NewUser extends StatefulWidget {
  const NewUser({Key? key}) : super(key: key);

  @override
  State<NewUser> createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  final CollectionReference _cusData =
      FirebaseFirestore.instance.collection('customers');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final Location _location = Location();

  String? _nameError;
  String? _passwordError;
  String? _emailError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createOrUpdate();
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: _nameError,
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText: _passwordError,
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _emailError,
              ),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                errorText: _phoneError,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // ElevatedButton(
            //   onPressed: _getLocation,
            //  child: Text('Get my location'),
            // ),
            ElevatedButton(
              child: const Text('Create'),
              onPressed: _onCreate,
            ),
          ],
        ),
      ),
    );
  }

  void _onCreate() async {
    final String? name = _nameController.text.trim();
    final String? password = _passwordController.text.trim();
    final String? email = _emailController.text.trim();
    final String? phone = _phoneController.text.trim();

    setState(() {
      _nameError = name?.isEmpty == true ? 'Please enter a name' : null;
      _passwordError =
          password?.isEmpty == true ? 'Please enter a password' : null;
      _emailError = email?.isEmpty == true ? 'Please enter an email' : null;
      _phoneError =
          phone?.isEmpty == true ? 'Please enter a phone number' : null;
    });

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

    if (_nameError == null &&
        _passwordError == null &&
        _emailError == null &&
        _phoneError == null) {
      await _cusData.add({
        "name": name,
        "password": password,
        "email": email,
        "phone": phone,
        "latitude": _locationData.latitude,
        "longitude": _locationData.longitude,
      });

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your account was successfully created")));
    
      _redirectToPage();
    }
  }

  void _redirectToPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CusReg()),
    );
  }

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    // Do nothing if there is a document snapshot
    if (documentSnapshot != null) {
      return;
    }

    _nameController.text = '';
    _passwordController.text = '';
    _emailController.text = '';
    _phoneController.text = '';
  }
}
