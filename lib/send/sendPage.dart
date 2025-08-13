import 'package:flutter/material.dart';
import 'package:storegcargo/constants.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(body: SingleChildScrollView(child: Column(children: [_buildCustomAppBar()])));
  }

  Widget _buildCustomAppBar() {
    return Stack(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: kTextRedWanningColor,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
        ),
        Positioned(top: 50, left: 20, child: Text("รายการส่ง", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
        Positioned(
          top: 45,
          right: 20,
          child: TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
