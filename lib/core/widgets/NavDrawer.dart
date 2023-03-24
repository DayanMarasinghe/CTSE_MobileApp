import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Market',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/images/cover.jpg'))),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => {Get.toNamed("admin")},
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Products'),
            onTap: () => {Get.toNamed("/products")},
          ),
          ListTile(
            leading: Icon(Icons.shopping_bag),
            title: Text('Stocks'),
            onTap: () => {Get.toNamed("/stocks")},
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () => {Get.toNamed("/about")},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }
}
