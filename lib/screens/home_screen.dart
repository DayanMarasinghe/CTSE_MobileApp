import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:market/core/controllers/sampleController.dart';

import '../core/widgets/NavDrawer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(context) {
    // Instantiate your class using Get.put() to make it available for all "child" routes there.
    final SampleController c = Get.put(SampleController());

    return Scaffold(
        appBar: AppBar(title: Text("GroceryGo")),

        // Replace the 8 lines Navigator.push by a simple Get.to(). You don't need context
        body: Center(
            child: Column(
          children: [
            ElevatedButton(
                child: const Text("Go to Products"),
                onPressed: () => Get.toNamed("/products")),
            ElevatedButton(
                onPressed: () => Get.toNamed("/allprod"),
                child: const Text("All Products")),
            ElevatedButton(
                onPressed: () => Get.toNamed("/login"),
                child: const Text("Login")),
          ],
        )),);
  }
}

class Other extends StatelessWidget {
  // You can ask Get to find a Controller that is being used by another page and redirect you to it.
  final SampleController c = Get.find();

  @override
  Widget build(context) {
    // Access the updated count variable
    return Scaffold(body: Center(child: Text("${c.count}")));
  }
}
