import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../core/widgets/NavDrawer.dart';
//maintain data status through stateful
//building the page
class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}
//manage state
class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
        backgroundColor: Colors.green,
      ),
      drawer: const NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => {
                  Get.toNamed("/products")
                },
                child: Card(
                    elevation: 5,
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const SizedBox(
                      width: 180,
                      height: 180,
                      child: Center(
                          child: Text('Products', style: TextStyle(fontSize: 28, color: Colors.white))),
                    )),
              ),
              GestureDetector(
                onTap: () => {
                  Get.toNamed("/stocks")
                },
                child: Card(
                    elevation: 4,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const SizedBox(
                      width: 180,
                      height: 180,
                      child: Center(
                          child: Text('Stocks', style: TextStyle(fontSize: 28))),
                    )),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
