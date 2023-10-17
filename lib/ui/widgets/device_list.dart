import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:nordic_lbs_client_demo/lbs.dart';
import 'package:nordic_lbs_client_demo/ble/ble_scanner.dart';

class DeviceList extends StatefulWidget {
  const DeviceList(
    this.scannerState, {
    required this.startScan,
    required this.stopScan,
    super.key,
  });

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  @override
  Widget build(BuildContext context) {
    final lbsDevices = widget.scannerState.discoveredDevices
        .where((device) => device.serviceUuids.contains(Uuid.parse(lbsId)))
        .toList();
    lbsDevices.sort((a, b) => a.rssi.compareTo(b.rssi));

    return Flexible(
      child: ListView(
        children: lbsDevices
            .map(
              (device) => ListTile(
                title: Text(device.name),
                subtitle: Text("${device.id}\nRSSI: ${device.rssi}"),
                leading: const Icon(Icons.bluetooth),
                onTap: () {},
              ),
            )
            .toList(),
      ),
    );
  }
}
