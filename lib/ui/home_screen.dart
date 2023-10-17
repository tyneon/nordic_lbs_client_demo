import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BleStatus?>(builder: (_, status, __) {
        if (status == BleStatus.ready) {
          return Center(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, "scan");
              },
              child: Text("Start scanning"),
            ),
          );
        } else {
          return const Center(
            child: Text("BLE is not ready"),
          );
        }
      }),
    );
  }
}
