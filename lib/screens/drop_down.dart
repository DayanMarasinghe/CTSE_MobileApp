import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DropDown extends StatefulWidget {
  const DropDown({Key? key,required this.onItemChanged}) : super(key: key);
  final Function(String) onItemChanged;
  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  List<String> list = [];
  String dropdownValue = 'Pasta';

  @override
  void initState() {
    FirebaseFirestore.instance.collection("products").get().then(
          (querySnapshot) {
        setState(() {
          for (var docSnapshot in querySnapshot.docs) {
            list.add(docSnapshot.data()['name']);
          }
        });

      },
      onError: (e) => print("Error completing: $e"),
    );
    // dropdownValue = list.first;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      // icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      // style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        widget.onItemChanged(value!);
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

}
