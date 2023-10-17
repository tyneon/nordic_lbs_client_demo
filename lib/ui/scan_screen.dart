import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import 'package:nordic_lbs_client_demo/ble/ble.dart';
import 'package:nordic_lbs_client_demo/ble/ble_scanner.dart';
import 'package:nordic_lbs_client_demo/ui/widgets/device_list.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Nordic LBS devices",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Consumer2<BleScanner, BleScannerState?>(
        builder: (_, bleScanner, bleScannerState, __) => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    child: const Text('Scan'),
                    onPressed: !bleScannerState!.scanning
                        ? () => bleScanner.startScan([])
                        : null),
                ElevatedButton(
                  child: const Text('Stop'),
                  onPressed:
                      bleScannerState!.scanning ? bleScanner.stopScan : null,
                ),
              ],
            ),
            DeviceList(
              bleScannerState ??
                  const BleScannerState(
                    discoveredDevices: [],
                    scanning: false,
                  ),
              startScan: bleScanner.startScan,
              stopScan: bleScanner.stopScan,
            ),
          ],
        ),
      ),
    );
  }
}
