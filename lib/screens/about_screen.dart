import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/widgets/NavDrawer.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('About'),
        ),
        drawer: const NavDrawer(),
        // Using StreamBuilder to display all products from Firestore in real-time
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "Market",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20,20,10,20),
                child: Text(
                  "Welcome to our market app Admin! We are passionate bunch of people who are dedicated to creating an exceptional shopping experience for our customers",
                  style: TextStyle(fontSize: 20, color: Colors.black87,),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20,20,10,20),
                child: Text(
                  "Thank you for choosing our market admin app. We look forward to working with you and helping your market thrives.   ",
                  style: TextStyle(fontSize: 20, color: Colors.black87,),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20),
                child: Text(
                  "All right reserved ",
                  style: TextStyle(fontSize: 16, color: Colors.black45),
                ),
              ),
            ],
          ),
        ));
  }
}
