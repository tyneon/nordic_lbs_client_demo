import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nordic_lbs_client_demo/ble.dart' as ble;
import 'package:nordic_lbs_client_demo/ui/widgets/device_list.dart';

class ScanPage extends ConsumerWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanner = ref.watch(ble.scannerProvider);
    final scannerNotifier = ref.read(ble.scannerProvider.notifier);
    final bleStatus = ref.watch(ble.statusProvider);

    final bleIsReady = (!bleStatus.hasError &&
        bleStatus.hasValue &&
        bleStatus.value == BleStatus.ready);
    if (!bleIsReady) {
      scannerNotifier.stop();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nordic LBS devices",
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                      scanner.scanning ? "Stop scanning" : "Start scanning"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Switch(
                    value: scanner.scanning,
                    thumbIcon: MaterialStateProperty.resolveWith<Icon>(
                        (Set<MaterialState> states) => Icon(
                            states.contains(MaterialState.selected)
                                ? Icons.bluetooth_searching
                                : Icons.bluetooth_disabled)),
                    onChanged: bleIsReady
                        ? (value) {
                            value
                                ? scannerNotifier.start([])
                                : scannerNotifier.stop();
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const DeviceList(),
        ],
      ),
    );
  }
}
