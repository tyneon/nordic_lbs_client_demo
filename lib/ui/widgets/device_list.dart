import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nordic_lbs_client_demo/ble.dart' as ble;

// import 'package:nordic_lbs_client_demo/lbs.dart' as lbs;
import 'package:nordic_lbs_client_demo/ui/device_screen.dart';

class DeviceList extends ConsumerWidget {
  const DeviceList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(ble.scannerProvider);
    final scannerNotifier = ref.read(ble.scannerProvider.notifier);

    final lbsDevices = scanner.devices;

    return Flexible(
      child: ListView(
        children: lbsDevices
            .map(
              (device) => ListTile(
                title: Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.id,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("RSSI: ${device.rssi}"),
                  ],
                ),
                leading: Icon(
                  Icons.bluetooth,
                  size: 30,
                  color: scanner.scanning ? Colors.blue : Colors.black54,
                ),
                onTap: () async {
                  scannerNotifier.stop();
                  ref.read(ble.connectedDeviceProvider.notifier).update(device);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeviceScreen(device),
                    ),
                  );
                  ref.read(ble.connectedDeviceProvider.notifier).clear();
                  scannerNotifier.start([]);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
