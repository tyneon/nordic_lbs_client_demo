import 'package:flutter/material.dart';

class LBSPage extends StatelessWidget {
  const LBSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Connected to Nordic LED Button Service"),
          Placeholder(),
          Placeholder(),
          OutlinedButton(
            onPressed: () {},
            child: Text("Disconnect"),
          ),
        ],
      ),
    );
  }
}
