import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nordic_lbs_client_demo/ble.dart' as ble;
import 'package:nordic_lbs_client_demo/lbs.dart' as lbs;

class DeviceScreen extends ConsumerWidget {
  final DiscoveredDevice device;

  const DeviceScreen(this.device, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(
      ble.deviceConnectionProvider(
        device: device,
        // TODO debug this
        // servicesWithCharacteristicsToDiscover: {
        //   Uuid.parse(lbs.serviceId): [
        //     Uuid.parse(lbs.buttonCharacteristicId),
        //     Uuid.parse(lbs.ledCharacteristicId),
        //   ],
        // },
      ),
    );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("${device.name} (${device.id})"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: switch (connection) {
          AsyncData(:final value) => switch (value.connectionState) {
              DeviceConnectionState.connected => Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Connected',
                      style: TextStyle(fontSize: 30),
                    ),
                    const LbsButtonState(),
                    const LbsLedControl(),
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Disconnect',
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ],
                ),
              DeviceConnectionState.connecting => const Center(
                  child: CircularProgressIndicator(),
                ),
              _ => Center(
                  child: Text(
                    'Error: ${value.failure?.message}',
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
            },
          AsyncError(:final error, :final stackTrace) => Text('Error: $error'),
          AsyncLoading() => const Text('Connecting'),
          _ => const Text('Impossible'),
        },
      ),
    );
  }
}

class LbsButtonState extends ConsumerWidget {
  const LbsButtonState({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceId = ref.watch(ble.connectedDeviceProvider)?.id;
    late String buttonStatus;
    if (deviceId == null) {
      buttonStatus = 'Not subscribed';
    } else {
      final subscription = ref.watch(
        ble.subscribeToCharacteristicProvider(
          QualifiedCharacteristic(
            characteristicId: Uuid.parse(lbs.buttonCharacteristicId),
            serviceId: Uuid.parse(lbs.serviceId),
            deviceId: deviceId,
          ),
        ),
      );
      buttonStatus = (subscription.value != null)
          ? subscription.value?.first == 0
              ? 'Released'
              : 'Pressed'
          : 'No data yet';
    }
    return Column(
      children: [
        Text(
          "LBS Button status",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          buttonStatus,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class LbsLedControl extends ConsumerStatefulWidget {
  const LbsLedControl({super.key});

  @override
  ConsumerState<LbsLedControl> createState() => _LbsLedControlState();
}

class _LbsLedControlState extends ConsumerState<LbsLedControl> {
  bool ledIsOn = false;

  @override
  Widget build(BuildContext context) {
    final deviceId = ref.watch(ble.connectedDeviceProvider)?.id;
    return Column(
      children: [
        Text(
          "LBS LED status",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ElevatedButton(
          onPressed: deviceId == null
              ? null
              : () {
                  ref.read(
                    ble.writeToCharacteristicProvider(
                      characteristic: QualifiedCharacteristic(
                        characteristicId: Uuid.parse(lbs.ledCharacteristicId),
                        serviceId: Uuid.parse(lbs.serviceId),
                        deviceId: deviceId,
                      ),
                      value: ledIsOn ? [0] : [1],
                    ),
                  );
                  setState(() {
                    ledIsOn = !ledIsOn;
                  });
                },
          child: ledIsOn ? const Text('Turn off') : const Text('Turn on'),
        ),
      ],
    );
  }
}
